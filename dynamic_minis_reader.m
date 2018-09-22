function dynamic_minis_reader()
% function dynamic_synaptic_reader
%
% reads and processes minis files from Silas' data.

% Dec 20 17: Modified from dynamic_iv_reader
% Jan 09 18: Curve fit for the alpha curve
% Jan 12 18: Modified from dynamic_synaptic_reader

folderName = 'C:\_Data\_Silas\';
showFigures = 1;                    % Whether figures are to be shown
doFit = 1;                          % Whether curve fit needs to be performed (it may be rather slow)
consoleOutput = 1;                  % Whether reading files should be reported

map = dynamic_what_is_where();      % Retrieve a hard-coded map of file names
% S has the following fields that are all arrays:
% id, group, prefix, folder (cell array), x, y 
% iv, minis, istep, dynamic, synaptic - these all contain the file number

nCells = length(map.id);
cellList=1:nCells;
badCells = [];                            % 84: recorded in CC
cellList = setdiff(cellList,badCells);
% cellList = 57;                            % Uncomment for testing (to work with one recording only)
cellList = [123 131 188 195 203]+10;   % Selected cells for testing (complicated curve shapes)
nCells = length(cellList);

x_zero =  [100 999];                        % Region ot measure zero level

bag = [];                                   % That's where the data will be collected

for(iCell=cellList)
    if(~isnan(map.synaptic(iCell)))
        fileName = [folderName map.folder{iCell} '\' num2str(map.prefix(iCell)) '_' sprintf('%03d',map.minis(iCell)) '.cfs'];
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
        iCh = 1;                        % Which channel to use. I just happen to know it's 1
        y = [];
        for(iSweep=1:nSweeps)
            y = [y ds.data(iSweep).y(:,iCh)];                   % Populate the data variable            
        end
        t = ds.data(iCh).x*1000;                                % In ms
        %t = 1:size(y,1);                                       % Uncomment if you want to debug or double-check x-areas
        zero = mean(y(x_zero(1):x_zero(2),:));
        y = bsxfun(@plus,y,-zero);                              % Set baseline to zero
        
        % ----- Fit
        
        bag = [bag; ];
           
        if(showFigures)
            figure('Color','white'); 
            hold on;
            set(gca,'ColorOrder',bsxfun(@plus,get(gca,'ColorOrder')*0.3,[1 1 1]*0.5));    % Make colors lighter
            plot(t,y);            
            title(iCell);
            drawnow();
        end        
    end
end

nCells = size(bag,1);
dispf(bag);
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


