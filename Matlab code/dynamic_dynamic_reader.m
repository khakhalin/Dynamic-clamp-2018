function dynamic_dynamic_reader()
% Actually reads dynamic clamp data, and lets the user count spikes.

% Jun 06 2018: Updated.

map = dynamic_what_is_where();
% useful fields: folder, id, prefix, dynamic
nCells = length(map.id);
cellList=1:nCells;
%cellList = 103:105;   % Uncomment for roubleshooting

folderName = 'C:\_Data\_Silas\';

mapId = [];
mapFolder = [];
mapPrefix = [];
mapFile = [];
S = [];                                 % Create the global data structure

for(iCell=cellList)
    if(~isnan(map.dynamic(iCell)) & (map.group(iCell)<=5)) % Only leave meaningful cells in the group
        mapId = [mapId; map.id(iCell)];
        mapFolder = [mapFolder; map.folder(iCell)];
        mapPrefix = [mapPrefix; map.prefix(iCell)];
        mapFile = [mapFile; map.dynamic(iCell)];
    end
end


%%% ----------------- Now all the data is loaded and we can browse through it

% fprintf('.... Started\n');
hF = figure;
fpos = get(hF,'Position');
set(hF,'Position',[fpos(1)-fpos(3)/2 fpos(2) fpos(3)*2 fpos(4)]); drawnow; % Without 'drawnow' returns an error every now and then (when position is requested before being finalized)
set(hF,'WindowButtonMotionFcn',@hoverfunction,'ButtonDownFcn',@mousepressfunction,'KeyPressFcn',@keyfunction,'ResizeFcn',@resizefunction);
S.hA = axes;
set(S.hA,'XLim',[0 2]);         % Only show first 20% of the curve
hold on; % Pre-create high level graphic objects here
S.hPmouse = plot(1,1,'g-');     % Future mouse coursor
S.hPdata = plot(1,1,'b-');      % Future data
hold off;

% Set mouse function for all created objects, as axes function won't work for them
set(S.hPmouse,'ButtonDownFcn',@mousepressfunction);

% Initialize global variables here
S.flagUpdate = 1;               % When set to 1, the main function will be called
S.flagMakeFigure = 0;           % When this is set to 1, it generates a figure
S.readNewFile = 1;              % Set to 1 when it's time to read a new file
S.iCell = 98;                   % Current cell (equivalent to iFile in the 1st part of the code)
S.nCells = length(mapId);       % Total number of cells
S.iSweep = 1;                   % Current sweep
S.bag = [];                     % Output numbers goes here
S.bagRow = 1;                   % Which bag row we are at

% Initialize local variables here
flag = 1; % Main rotating flag

set(hF,'UserData',S); % Send the stuff there
resizefunction;

while(flag)
    try
        S = get(hF,'UserData');
    catch % Probably the figure was closed
        flag = 0; break; % Leave the cycle
    end
    
    if(S.readNewFile)
        fileName = [folderName mapFolder{S.iCell} '\' num2str(mapPrefix(S.iCell)) '_' sprintf('%03d',mapFile(S.iCell)) '.cfs'];
        fprintf('%4d \t%4d \t%10s \t%s... ',S.iCell,mapId(S.iCell),mapFolder{S.iCell},fileName);        
        ds = cfsload(fileName);         % Data structure with all data and info from the file        
        nSweeps = ds.info.sections;        
        iCh = 1;                        % Which channel to use. I just happen to know it's 1
        y = [];                         % Voltages
        z = [];                         % Currents
        for(iSweep=1:nSweeps)
            y = [y ds.data(iSweep).y(:,iCh)];                   % Populate the data
            z = [z ds.data(iSweep).y(:,2)];
        end        
        x = ds.data(iCh).x;
        S.readNewFile = 0;
        S.cellId = mapId(S.iCell);
        S.nSweeps = size(y,2);
        fprintf('Done!\n');
    end
    
    if(S.flagMakeFigure) % Time to make a figure
        hF2 = figure; 
        figureType = 2;
        switch figureType
            case 1
                for(iplot=1:20)
                    subplot(5,4,iplot); 
                    inds = floor((iplot-1)/4)*12 + [1 5 9]+mod(iplot-1,4);
                    plot(x,bsxfun(@plus,y(:,inds),-y(1,inds)+[0 1 2]*10)); xlim([0 2]);            
                end
            case 2
                for(iplot=1:12)
                    subplot(3,4,iplot); hold on;
                    plot(x,y(:,iplot)-y(1,iplot),'b-');
                    plot(x,z(:,iplot)-z(1,iplot),'r-');
                    hold off;
                    xlim([0 1]); ylim([-10 100]);
                end
        end
        figure(hF);
        S.flagMakeFigure = 0;
    end
    
    if(S.flagUpdate) % Somebody pressed the button - time to move to the next sweep    
        % Do something here
        % fprintf('Do things\n');        
        set(S.hPdata,'XData',x,'YData',y(:,S.iSweep));
        S.flagUpdate = 0;        
    end
    set(hF,'UserData',S);
    drawnow;
end

fprintf('Finished! Writing stuff down now.\n');
try % Enclosed in 'try' because the figure may be closed already by the user
    S = get(hF,'UserData');
    pause(0.1);
    close(hF);
end

fileID = fopen(['C:\Users\Arseny\Documents\5_Dynamic clamp\manualCounting.txt'],'w');
fprintf(fileID,'%s\t%s\t%s\r\n','Cell','Sweep','Spikes');
for(q=1:length(S.bag))    
    fprintf(fileID,'%02d\t%d\t%d\r\n',S.bag(q,:));
end
fclose(fileID);
fprintf('Done! Bye!\n');

end

function hoverfunction(h,event)
hF = gcf; S = get(hF,'UserData'); % Get use data
xy = get(hF,'CurrentPoint'); % Mouse location in figure coordinates
axesPos = get(S.hA,'Position');
figPos = get(hF,'Position');
S.x = (xy(1)/figPos(3)-axesPos(1))/axesPos(3); % Recalcualte into relative position within the axes
S.y = (xy(2)/figPos(4)-axesPos(2))/axesPos(4);

xLim = get(S.hA,'XLim');
yLim = get(S.hA,'YLim');
xx = (xLim(1)+(xLim(2)-xLim(1))*S.x);
yy = (yLim(1)+(yLim(2)-yLim(1))*S.y);
if((S.x>0)&&(S.x<1))
    set(S.hPmouse,'XData',[xx xx],'YData',yLim);
end

set(hF,'UserData',S); % Push data back
end

function mousepressfunction(h,event)
disp('mouse');
hF = gcf; S = get(hF,'UserData');
xy = get(hF,'CurrentPoint');
axesPos = get(S.hA,'Position');
figPos = get(hF,'Position');
S.xb = (xy(1)/figPos(3)-axesPos(1))/axesPos(3);
S.yb = (xy(2)/figPos(4)-axesPos(2))/axesPos(4);
S.flagNext = 1;
set(hF,'UserData',S);
end

function resizefunction(h,event)
hF = gcf; S = get(hF,'UserData');
% Do something here
set(hF,'UserData',S);
end

function keyfunction(h,event)
hF = gcf; S = get(hF,'UserData');
switch event.Key
    case 'a' % Note that if adsw are pressed in mark-up mode, it would break everything as they don't update bagRow!
        S.iCell = max(1,S.iCell-1);
        fprintf('New cell: %d\n',S.iCell);
        S.readNewFile = 1;
    case 'd'
        S.iCell = min(S.nCells,S.iCell+1);
        fprintf('New cell: %d\n',S.iCell);
        S.readNewFile = 1;
    case 's'
        S.iSweep = max(1,S.iSweep-1);        
        fprintf('Sweep: %d\n',S.iSweep);        
    case 'w'        
        S.iSweep = min(S.nSweeps,S.iSweep+1);
        fprintf('Sweep: %d\n',S.iSweep);        
    case {'0','1','2','3','4','5','6','7','8','9'}
        newNumber = str2num(event.Key);
        S.bag(S.bagRow,:) = [S.cellId S.iSweep newNumber];
        fprintf('%d. ',newNumber);
        if(S.iSweep<S.nSweeps)
            S.iSweep=S.iSweep+1;
            S.bagRow = S.bagRow+1;
            fprintf('Now sweep %d\n',S.iSweep);
        elseif(S.iCell<S.nCells)
            S.iCell = S.iCell+1;            
            S.iSweep = 1;
            S.bagRow = S.bagRow+1;
            fprintf('Moving to next cell: %d\n',S.iCell);
            S.readNewFile = 1;
        else
            fprintf('Hurray, you reached the other side!\n');
        end
    case 'z'
        fprintf('Returning a step back.\n');
        if(S.iSweep==1)
            if(S.iCell>1)
                S.iCell = S.iCell-1;
                S.iSweep = 60; % Huge assumption of course
                S.bagRow = S.bagRow-1;
                S.readNewFile = 1;
            end
        else
            S.iSweep = S.iSweep-1;
            S.bagRow = S.bagRow-1;
        end
    case 'p'
        S.flagMakeFigure = 1;
    case 'q' % Pring stuff
        S.bag
        fprintf('Writing the file now... ');
        fileID = fopen(['C:\Users\Arseny\Documents\5_Dynamic clamp\manualCounting.txt'],'w');
        fprintf(fileID,'%s\t%s\t%s\r\n','Cell','Sweep','Spikes');
        for(q=1:length(S.bag))    
            fprintf(fileID,'%02d\t%d\t%d\r\n',S.bag(q,:));
        end
        fclose(fileID);
        fprintf('Done!\n');
    otherwise
        fprintf('%s - :)\n',event.Key);
end
S.flagUpdate = 1;
set(hF,'UserData',S);
end