function dynamic_iv_reader()
% function dynamic_iv_reader
%
% reads and processes IV curve files for Silas' data.

% Oct 29 2017: last improved

folderName = 'C:\_Data\_Silas\';
showFigures = 1;                    % Whether figures are to be shown
consoleOutput = 1;                  % Whether reading files should be reported
doFit = 0;                          % If fancy exponential fit is to be used. Set to 0 if averaging is enough

map = dynamic_what_is_where();      % Retrieve a hard-coded map of file names
% S has the following fields that are all arrays:
% id, group, prefix, folder (cell array), x, y 
% iv, minis, istep, dynamic, synaptic - these all contain the file number

nCells = length(map.id);
cellList=1:nCells;

cellList = 51; % Uncomment for testing. First 2 rows don't have an iv file

z_l =  [100 450];           % Zero level
prestep_l =  [504 1000];    % Test step area
step_l = [2303 7302];       % Voltage step area
na_l = [2307 2330];     % Window for Na current peak measurement
kt_l = [2360 2500];     %            K transient mean
ks_l = [6600 7200];     %            K stable mean
v_prestep = -10;            % Voltage pre-step amplitude (that small one in the beginning), mV
v_baseline = -60;           % Voltage baseline, mV
v = (0:10)*10;              % Test voltage steps, mV
bag = [];                   % That's where data will be collected

fit_f = fittype('exp(-x/a)*b+c','independent','x');         % Fitting parameters; only important of doFit is set to 1
fit_s = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',     [1      0       0],...
               'Upper',     [1000   1000    1000],...
               'Startpoint',[100  	10      10]);

nCells = length(cellList);
for(iCell=cellList)
    if(~isnan(map.iv(iCell)))
        fileName = [folderName map.folder{iCell} '\' num2str(map.prefix(iCell)) '_' sprintf('%03d',map.iv(iCell)) '.cfs'];
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
        x = ds.data(iCh).x;
        zero = mean(y(z_l(1):z_l(2),:));
        y = bsxfun(@plus,y,-zero);                              % Zero baselines
        passiveCurve = -mean(y(prestep_l(1):prestep_l(2),:),2);
        if(doFit)
            [coeff,gof2] = fit((1:length(passiveCurve))',passiveCurve,fit_f,fit_s);
            if(1)
                figure; hold on; plot(passiveCurve,'b-'); plot(exp(-(1:(prestep_l(2)-prestep_l(1)))/coeff.a)*coeff.b + coeff.c,'r-'); hold off;
                error();
            end
            passivePrediction = exp(-(1:(step_l(2)-step_l(1)))/coeff.a)*coeff.b+coeff.c;        
        else
            passivePrediction = [passiveCurve; mean(passiveCurve((end-100):end))*ones(step_l(2)-step_l(1)-length(passiveCurve)+1,1)];
        end
        for(iSweep=1:nSweeps)
            y(step_l(1):step_l(2),iSweep) = y(step_l(1):step_l(2),iSweep) - passivePrediction/-v_prestep*v(iSweep); % Minus here coz I inverted passiveCurve above
        end
        na = min(y(na_l(1):na_l(2),:));
        ks = mean(y(ks_l(1):ks_l(2),:));
        kt = mean(y(kt_l(1):kt_l(2),:))-ks;
        na = -na;                                                   % Flip INa, to have it positive        
        try
            bag = [bag; map.id(iCell) na kt ks];                    % Keep all data to fprintf it later
        catch
            fprintf('Error with file %03d in folder %s:\n',map.iv(iCell),map.folder{iCell});
            fprintf('Concatenation problem, while storing data. ');
            temp = size(na);
            fprintf('Bag size: %d %d ; new line size: %d %d\n',size(bag),temp(1),temp(2)*3+1);            
        end        
        if(showFigures)
            figure('Color','white'); subplot(3,4,[1 2 3 5 6 7 9 10 11]); plot(y); ylim([-200 inf]);
            xlabel('Time ticks, 0.1 ms each'); ylabel('pA'); title(sprintf('Cell %d,  %d',map.id(iCell),map.prefix(iCell)));
            ha = subplot(3,4,4); plot(v,na,'.-'); ylabel('Na current'); set(ha,'FontSize',8);
            ha = subplot(3,4,8); plot(v,kt,'.-'); ylabel('K transient'); set(ha,'FontSize',8);
            ha = subplot(3,4,12); plot(v,ks,'.-'); ylabel('K stable'); xlabel('V'); set(ha,'FontSize',8);
            drawnow();
        end        
    end
end

nCells = size(bag,1);
id = bag(:,1);
na = bag(:,(0:10) + 02);    % That's how the "bag" is created above, in the main function.
kt = bag(:,(0:10) + 13);    % It starts with an id, and then we have 11 different levels of v
ks = bag(:,(0:10) + 24);
res = analyze(na,kt,ks,v_baseline + v, nCells, id);          % Run the analysis

% if(consoleOutput)
%     fprintf('----------- Output:\n');
%     fprintf('cell id, then Na, Kt, and Ks; %d of each:\n',length(v));
%     dispf(round(bag),'%5d');
% end


end


function res = analyze(dataNa, dataKt, dataKs, v, nCells, cellId)
doNa = 0;
doKt = 0;
doKs = 1;
showFigures = 1;

maxX = 60;                          % Maximal voltage that can be proposed as a fit result
plotN = 4; plotM = 6;               % How many plots per figure (NxM) would we like to have
vv = linspace(min(v),max(v),100);   % Linear space for smooth fitting
res = [];                           % As of now the function returns nothing, but rather outputs everything in the console

if(doNa)
    [f,s] = myfittypes('sigmoidoid',maxX);
    fprintf('Na data\n');
    fprintf('      id\tXhalf\tAmp\n');
    if(showFigures); figure('Color','w'); end
    for(iCell=1:nCells)
        try
            [c2,gof2] = fit(v',dataNa(iCell,:)',f,s);
        catch
            dispf('An error happened');
            dispf('data:')
            dispf(dataNa(iCell,:));
            error();                        % Let's generate some kind of an error anyway (I don't remember how to do it properly)
        end
        fmaxx = fminbnd(@(x)(-c2(x)),min(v),max(v));                % Using anonymous function to find curve maximum
        fmid  = fminbnd(@(x)(abs(c2(x)-c2(fmaxx)/2)),min(v),fmaxx); % Using anonymous function to find curve middle point

        if(showFigures)
            subplot(plotN,plotM,mod(iCell-1,plotN*plotM)+1);            % Complex formula to make multi-plating possible
            hold on;
            plot(vv,c2(vv'),'r-');
            plot(v,dataNa(iCell,:),'b.');    
            plot(fmaxx,c2(fmaxx),'ko');
            plot(fmid,c2(fmid),'kx');
            set(gca,'FontSize',6,'XTick',[]);
            if(plotM>10); set(gca,'YTick',[]); end;
            title(cellId(iCell));
            hold off;
            drawnow;
        end
        fprintf('%8d\t%5.1f\t%5.1f\n',[cellId(iCell) fmid c2(fmaxx)]);

        if((iCell<nCells) && showFigures)
            if(mod(iCell,plotN*plotM)==0);            % Time to get a new figure window
                figure('Color','w');
            end
        end
    end
    if(showFigures); supertitle('Na data'); end
end


if(doKs)
    [f,s] = myfittypes('cutexp',maxX);
    fprintf('Ks data\n');
    fprintf('      id\tFirst\tAmp\n');
    figure('Color','w');
    for(iCell=1:nCells)
        [c2,gof2] = fit(v',dataKs(iCell,:)',f,s);

        subplot(plotN,plotM,mod(iCell-1,plotN*plotM)+1); 
        hold on;    
        plot(vv,c2(vv'),'r-');
        plot(v,dataKs(iCell,:),'b.');        
        set(gca,'FontSize',6,'XTick',[]);
        if(plotM>10); set(gca,'YTick',[]); end;
        title(cellId(iCell));
        hold off;
        drawnow;
        fprintf('%8d\t%5.1f\t%5.1f\n',[cellId(iCell) c2.a+log(c2.e)*c2.b max(dataKs(iCell,:))]);
        if(iCell<nCells)
            if(mod(iCell,plotN*plotM)==0);            % Time to get a new figure window
                figure('Color','w');
            end
        end
    end
    %supertitle('Ks data');
end


if(doKt)
    [f,s] = myfittypes('sigmoidoid',maxX);
    fprintf('Kt data\n');
    fprintf('      id\tXhalf\tAmp\n');
    figure('Color','w');
    for(iCell=1:nCells)
        [c2,gof2] = fit(v',dataKt(iCell,:)',f,s);
        fmaxx = fminbnd(@(x)(-c2(x)),min(v),max(v)); % Using anonymous function to find curve maximum
        fmid  = fminbnd(@(x)(abs(c2(x)-c2(fmaxx)/2)),min(v),fmaxx); % Using anonymous function to find curve maximum

        subplot(plotN,plotM,mod(iCell-1,plotN*plotM)+1); 
        hold on;
        plot(vv,c2(vv'),'r-');
        plot(v,dataKt(iCell,:),'b.');    
        plot(fmaxx,c2(fmaxx),'ko');
        plot(fmid,c2(fmid),'kx');
        set(gca,'FontSize',6,'XTick',[]);
        if(plotM>10); set(gca,'YTick',[]); end;
        title(cellId(iCell));
        hold off;
        drawnow;
        fprintf('%8d\t%5.1f\t%5.1f\n',[cellId(iCell) fmid c2(fmaxx)]);
        if(iCell<nCells)
            if(mod(iCell,plotN*plotM)==0);            % Time to get a new figure window
                figure('Color','w');
            end
        end
    end
    %supertitle('Kt data');
end

end

function [f,s] = myfittypes(kind,maxX)
switch(kind)
    case 'exp'
        f = fittype('exp((x-a)/b)*c+d','independent','x');
        s = fitoptions('Method','NonlinearLeastSquares',...
                       'Lower',     [-maxX   1   0   0],...
                       'Upper',     [maxX    maxX Inf Inf],...
                       'Startpoint',[0      10  1   1]);
    case 'cutexp'
        f = fittype('max(0,exp((x-a)/b)-e)*c+d','independent','x');
        s = fitoptions('Method','NonlinearLeastSquares',...
                       'Lower',     [-maxX   1      0   0   0],...
                       'Upper',     [maxX    maxX   Inf Inf 1],...
                       'Startpoint',[0       10     1   1   0.1]);
    case 'sigmoid'
        f = fittype('c/(1+exp(-(x-a)/b)+d)','independent','x');
        s = fitoptions('Method','NonlinearLeastSquares',...
                       'Lower',     [-maxX   1   0   0],...
                       'Upper',     [maxX    maxX Inf Inf],...
                       'Startpoint',[0      10  1   1]);
       case 'sigmoidoid'
        f = fittype('c*exp(x/b1)./(1+exp(-(a-x)/b2))','independent','x');
        s = fitoptions('Method','NonlinearLeastSquares',...
                       'Lower',     [-maxX   .1      .1        0   ],...
                       'Upper',     [0     maxX    maxX     Inf ],...
                       'Startpoint',[-1       10     10       1   ]);
   case 'xexp'
        f = fittype('(x-a)*exp(-(x-b)/c)*d+e','independent','x');
        s = fitoptions('Method','NonlinearLeastSquares',...
                       'Lower',     [-maxX   -maxX   1   0   0],...
                       'Upper',     [maxX    maxX    maxX Inf Inf],...
                       'Startpoint',[0      0      100  1   1]);
end
end