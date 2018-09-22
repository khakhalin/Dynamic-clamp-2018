function dynamic_synaptic_reader()
% function dynamic_synaptic_reader
%
% reads and processes synaptic files from Silas' data.

% Dec 20 17: Modified from dynamic_iv_reader
% Jan 09 18: Curve fit for the alpha curve

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
badCells = [84];                            % 84: recorded in CC
cellList = setdiff(cellList,badCells);
cellList = 57;                            % Uncomment for testing (to work with one recording only)
cellList = [123 131 188 195 203];   % Selected cells for testing (complicated curve shapes)
nCells = length(cellList);

x_zero =  [100 999];                        % Region ot measure zero level
x_end = 9999;                               % Last x point
x_end_fit = x_end;                          % last point to fit (may be shorter than the full fit)
x_show = [2600 x_end];                      % Region to show on a plot
x_art = 3003;                               % Artifact position
x_art_safe = 3010;                          % By this point the artifact is almost zero
x_mono = x_art + [5 15]*10 + [0 -1];        % Monosynaptic area, after [ciarleglio khakhalin 2015]
x_poly = x_art + [15 145]*10;               % Polysynaptic area

% g*t/tau*exp(1-t/tau)
fitToUse = 'single';
switch fitToUse
    case 'single'
        fit_f = fittype('min(0,-a*(x-b)/c*exp(1-(x-b)/c))','independent','x');         % Fitting parameters for double alpha-curve fit
        fit_s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',     [0      0          1       ],...
               'Upper',     [Inf    200       1000     ],...
               'Startpoint',[100    2          10      ]);
    case 'double'
        fit_f = fittype('min(0,-a*(x-b)/c*exp(1-(x-b)/c) - d*(x-b)/e*exp(1-(x-b)/e))','independent','x');         % Fitting parameters for double alpha-curve fit
        fit_s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',     [0      0          1        0       200],...
               'Upper',     [Inf    200       1000     Inf     1000],...
               'Startpoint',[100    2          10       10      200]);
end

bag = [];                                   % That's where the data will be collected

for(iCell=cellList)
    if(~isnan(map.synaptic(iCell)))
        fileName = [folderName map.folder{iCell} '\' num2str(map.prefix(iCell)) '_' sprintf('%03d',map.synaptic(iCell)) '.cfs'];
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
        
        mono_m = mean(mean(y(x_mono(1):x_mono(2),:)));          % Short-latency (presumably monosynaptic) amplitude
        poly_m = mean(mean(y(x_poly(1):x_poly(2),:)));          % Long latency (polysynaptic) amplitude
        mono_s =  std(mean(y(x_mono(1):x_mono(2),:)));          % Amplitude variability (sd)
        poly_s =  std(mean(y(x_poly(1):x_poly(2),:)));
        k = sum(min(0,y(x_art_safe:x_end,:)));                  % Coeff for the center-of-mass calculation (below); only looks at negative (meaningful) data
        lat = sum(bsxfun(@times,1./k,bsxfun(@times,min(0,y(x_art_safe:x_end,:)),(x_art_safe:x_end)')));    % Centers of mass of synaptic responses        
        lat_m =  t(round(mean(lat))-x_art);                     % Center of mass translated into ms, and measured from artifact
        lat_s =  t(round(std(lat)));                            % Trial-to-trial variation in center of mass position, also in ms
        
        % ----- Fit
        if(doFit)
            % min(0,-a*(x-b)/c*exp(1-(x-b)/c))
            [coeff,gof2] = fit(t(x_art:x_end_fit)-t(x_art),mean(y(x_art:x_end_fit,:),2),fit_f,fit_s);
            g = coeff.a;     d = coeff.b;   tau = coeff.c;             
        else
            g = NaN; d = NaN; tau = NaN; 
        end
        
        bag = [bag; map.id(iCell) mono_m mono_s poly_m poly_s lat_m lat_s g d tau];
           
        if(showFigures)
            figure('Color','white'); 
            hold on;
            set(gca,'ColorOrder',bsxfun(@plus,get(gca,'ColorOrder')*0.3,[1 1 1]*0.5));    % Make colors lighter
            plot(t,y);
            plot(t,mean(y'),'b-');
            plot(t(x_art:x_end),coeff(t(x_art:x_end)-t(x_art)),'r-');
            plot(t(x_mono),[1 1]*mono_m,'k.-');
            plot(t(round(mean(x_mono)))*[1 1],mono_m+[-1 1]*mono_s,'k.-');
            plot(t(x_poly),[1 1]*poly_m,'k.-');
            plot(t(round(mean(x_poly)))*[1 1],poly_m+[-1 1]*poly_s,'k.-');
            plot(t(round(lat)),10*ones(size(lat)),'r.');
            plot(t(x_art)+lat_m,0,'ko');
            plot(t(x_art)+lat_m+[-1 1]*lat_s,[0 0],'k.-');                        
            set(gca,'XLim',t(x_show),'YLim',[-60 20]);
            hold off;
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


function res = analyze(dataNa, dataKt, dataKs, v, nCells, cellId)
showFigures = 1;

end
