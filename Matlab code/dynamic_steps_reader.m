function dynamic_steps_reader()
% function dynamic_synaptic_reader
%
% Reads and processes current step files from Silas' data.


folderName = 'C:\_Data\_Silas\';
showFigures = 1;                    % Whether figures are to be shown
figureType = 'pile';                % 'full', 'pile', or 'train'
consoleOutput = 0;                  % Whether reading files should be reported
flagFitCurrent = 1;                 % Whether the depolarization curve needs to be measured (dV/dt)
flagFinalOutput = 0;                % Whether final table is to be shown


map = dynamic_what_is_where();      % Retrieve a hard-coded map of file names
% S has the following fields that are all arrays:
% id, group, prefix, folder (cell array), x, y 
% iv, minis, istep, dynamic, synaptic - these all contain the file number

nCells = length(map.id);
cellList=1:nCells;
badCells = [];                              % 84: recorded in CC
cellList = setdiff(cellList,badCells);
% cellList = 180:190;                         % Uncomment for testing (to work with selected few recordings only)
cellList = [141 198 205];                 % Some random cells for testing
% cellList = 198;
nCells = length(cellList);

xZero =  [30 4900];                         % Region ot measure zero level
xSignal = [5005 7000];                      % Region of the actual signal

zThreshold = 0.02;                          % Spike detection threshold. 0.03 is kinda medium; 0.05 is conservative, 0.02 permissive

bag = [];                                   % That's where the data will be collected

for(iCell=cellList)
    if(~isnan(map.istep(iCell)))
        fileName = [folderName map.folder{iCell} '\' num2str(map.prefix(iCell)) '_' sprintf('%03d',map.istep(iCell)) '.cfs'];
        if(consoleOutput)
            fprintf('%4d \t%4d \t%10s \t%s\n',iCell,map.id(iCell),map.folder{iCell},fileName);
        end
        ds = cfsload(fileName);         % Data structure with all data and info from the file
        % res = ds;                     % Only keep uncommented if debugging
        if(~isfield(ds,'data'))
            fprintf('Warning: cannot read file %03d in folder %s\n',map.iv(iCell),map.folder{iCell});
            continue
        end
        nSweeps = ds.info.sections;        
        iCh = 1;                                                % Which channel to use. I just happen to know it's 1
        y = [];                                                 % Signal will be kept here
        firstMax = zeros(nSweeps,1);                            % First maximum for each sweep will be kept here
        
        for(iSweep=1:nSweeps)
            y = [y ds.data(iSweep).y(:,iCh)];                   % Populate the data variable            
        end
        t = ds.data(1).x*1000;                                  % In ms
        %t = 1:size(y,1);                                       % Uncomment if you want to debug or double-check x-areas
        zero = mean(y(xZero(1):xZero(2),:));
        y = bsxfun(@plus,y,-zero);                              % Set baseline to zero
        
        [fb,fa] = butter(3,0.2);                                % Low-pass filter
        temp = y;
        temp = filter(fb,fa,temp);
        d1 = diff(temp); d1 = [d1(ones(1,nSweeps)); d1];        % First derivative
        
        if(flagFitCurrent)
            K = mean(d1(xSignal(1)+(1:30),2))*1e4/1000;         % Multiplied by 1e4 because 1tick = 0.1 ms; then translated from mV/s to V/s
            stepSize = mean(ds.data(2).y(xSignal(1)+(1:10),2)) - mean(ds.data(2).y(30+(1:10),2));
            
            % fprintf("%4d\t%f\t%3.0f\n", map.id(iCell) , K , stepSize);
            
            fprintf("%4d\t%f\t%s\t%f\t%3.0f\n", map.id(iCell) , ds.data(1).vars(35).value , ds.data(1).vars(35).units , K , stepSize);            
            % ds.data(1).vars(35).value is supposedly a total R, stored in the file itself
            % I used this nano-script to look into this metadata (once the file is loaded). Most are empty, but number 35 seems ot have R total:
            % 35	RTot1	MOhm	2.676699e+03
            % for(i=1:76); fprintf("%d\t%s\t%s\t%s\n", i, ds.data(1).vars(i).info , ds.data(1).vars(i).units , ds.data(1).vars(i).value ); end;
        end
        
        for(iSweep=1:nSweeps) % Find maxima (probably spikes)
            firstMax(iSweep) = xSignal(1) + find(d1(xSignal(1):end-1,iSweep)>0 & d1(xSignal(1)+1:end,iSweep)<=0,1)-4; % minus 4 to neutralize lag?
            %%% First maximum in the active signal region (important as we only allow 1 kink point on the 1st rising front)
        end
        d2 = diff(d1);   d2 = [d2(ones(1,nSweeps)); d2];        % Second derivative
        z = max(0,d1).*max(0,d2);                               % Special function to localize the kink point (see Ciarleglio Khakhalin 2015)
        
        points = [];
        maxSpikes = 0;   
        minInflectionV = NaN;
        for(iSweep=1:nSweeps)
            points{iSweep} = find((z(2:end,iSweep)>=zThreshold)&(z(1:end-1,iSweep)<zThreshold)); % kink points (only positive)
            points{iSweep} = points{iSweep}(points{iSweep}>xSignal(1) & points{iSweep}<xSignal(2));
            if(sum(points{iSweep}<firstMax(iSweep))>1)                                  % If there are kink points to the left from the first max, some of them may be wrong ones
                closestPoint = max(points{iSweep}(points{iSweep}<firstMax(iSweep)));    % Last kink point before max
                points{iSweep} = points{iSweep}(points{iSweep}>=closestPoint);          % Drop all other kink points before this poine
            end
            if(maxSpikes==0 && length(points{iSweep})>0)        % First sweep to have a spike
                minInflectionV = y(min(points{iSweep}),iSweep);
                firstSpikeSize = y(firstMax(iSweep),iSweep) - minInflectionV;  % Max y minus kink point
            end
            maxSpikes = max(maxSpikes,length(points{iSweep}));            
        end
        %locMin = find((d1(2:end)>0)&(d1(1:end-1)<=0));  % Local minima
        
        bag = [bag; map.id(iCell) maxSpikes minInflectionV firstSpikeSize];
           
        if(showFigures)
            figure('Color','white');
            switch(figureType)
                case 'full'
                    hold on
                    set(gca,'ColorOrder',bsxfun(@plus,get(gca,'ColorOrder')*0.3,[1 1 1]*0.5));    % Make colors lighter
                    plot(t,y);   
                    for(iSweep=1:nSweeps)
                        plot(t(points{iSweep}),y(points{iSweep},iSweep),'r.');
                    end                    
                    hold off
                    title(sprintf('Cell %d : %d spikes',map.id(iCell),maxSpikes));
                case 'pile'
                    hold on;
                    set(gca,'ColorOrder',bsxfun(@plus,get(gca,'ColorOrder')*0.3,[1 1 1]*0.5));    % Make colors lighter
                    plot(t,y);      
                    xlim((xSignal+[-100 0])/10);    
                    for(iSweep=1:nSweeps)
                        plot(t(points{iSweep}),y(points{iSweep},iSweep),'r.');
                    end
                    % plot(t(xSignal(1)+10),y(xSignal(1)+10,2),'ro');
                    hold off;
                    title(sprintf('Cell %d : %d spikes',map.id(iCell),maxSpikes));
                case 'train'
                    subplot(2,1,1);
                    hold on;                    
                    plot((1:(xSignal(2)-xSignal(1)+1)*8)' , reshape(y(xSignal(1):xSignal(2),2:end),[],1));  % Point number x-axis insstead of time (simpler this way)
                    for(iSweep=2:nSweeps)  % Starts with iSweep==2 because 1 is a flatline                      
                        plot(points{iSweep}-xSignal(1)+(xSignal(2)-xSignal(1)+1)*(iSweep-2),y(points{iSweep},iSweep),'r.');
                        plot(firstMax(iSweep)-xSignal(1)+1+(xSignal(2)-xSignal(1)+1)*(iSweep-2),y(firstMax(iSweep),iSweep),'g.');
                    end
                    hold off;
                    title(sprintf('Cell %d : %d spikes',map.id(iCell),maxSpikes));
                    subplot(2,1,2);
                    hold on;
                    plot((1:(xSignal(2)-xSignal(1)+1)*8)' , reshape(z(xSignal(1):xSignal(2),2:end),[],1));
                    for(iSweep=2:nSweeps)  % Starts with iSweep==2 because 1 is a flatline                      
                        plot(points{iSweep}-xSignal(1)+(xSignal(2)-xSignal(1)+1)*(iSweep-2),z(points{iSweep},iSweep),'r.');                        
                    end
                    hold off;
            end
            drawnow();
        end        
    end
end

nCells = size(bag,1);
if(flagFinalOutput)
    dispf(bag);
end

% id = bag(:,1);
% na = bag(:,(0:10) + 02);    % That's how the "bag" is created above, in the main function.
% kt = bag(:,(0:10) + 13);    % It starts with an id, and then we have 11 different levels of v
% ks = bag(:,(0:10) + 24);
% res = analyze(na,kt,ks,v_baseline + v, nCells, id);          % Run the analysis

% if(consoleOutput)
%     fprintf('----------- Output:\n');
%     fprintf('cell id, then Na, Kt, and Ks; %d of each:\n',length(v));
%     dispf(round(bag),'%5d');
% end


end


