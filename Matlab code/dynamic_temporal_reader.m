function S = dynamic_temporal_reader(S)
% dynamic_temporal_reader(S)
%
% Reads Silas'es files.

% Mar 08 2016: Created
% Apr 11 2016: general update, + processing data.
% Apr 12 2016: updated for new numerical cells.

if(nargin<1) % No inputs - need to read the file
    fprintf('No inputs received , need to read the Excel file... ');
    fileName = 'C:\Users\Arseny\Documents\5_Dynamic clamp\Summer16 full data.xlsx';
    % fileName = 'C:\Users\Arseny\Documents\5_Dynamic clamp\Data\Naive dataset.xlsx';
    [dn,dt] = xlsread(fileName,'data');

    % res.n = num; res.t = text;

    nCells = size(dn,2)/3;
    if(nCells~=round(nCells))
        error('Cannot guess the number of cells');
    end

    for(iCell=1:nCells)
        col = 1+(iCell-1)*3;    % Column at which the numerical data starts
        S{iCell}.group = dn(1,col);
        S{iCell}.data = dn(3:end,col+(0:2));
        S{iCell}.name = dn(2,col);
    end
    fprintf('Done.\n');
else
    fprintf('Data provided as an argument, so NOT reading the file.\n');
end


%%% ------------- Writing reformatted outputs to a TXT file

nCells = length(S);
bagL = [];  % Labels for string data: Cell name
bagN = [];  % Storage for numerical data: group (0:4), amplitude (1:3), shape (1:4), set (1:5), nSpikes
for(iCell=1:nCells)
    for(iRep=1:5) % 5 repetitions, arranged vertically, 4 rows in each
        temp = sum(sum(S{iCell}.data((1:4)+(iRep-1)*4,:)));
        if(~isnan(temp))
            for(iAmp=1:3)
                for(iShape=1:4)
                    bagL = [bagL; S{iCell}.name];
                    bagN = [bagN; S{iCell}.group iAmp iShape iRep S{iCell}.data(iShape+(iRep-1)*4,iAmp)];
                end
            end
        else
            fprintf('Incomplete repetition found: cell %d repetition %d\n',iCell,iRep);
        end
    end
end

fprintf('Writing outputs to TXT file... ');
dateStamp = sprintf('%04d%02d%02d',year(date()),month(date()),day(date()));
fileID = fopen(['C:\Users\Arseny\Documents\5_Dynamic clamp\out ' dateStamp '.txt'],'w');
fprintf(fileID,'%s\t%s\t%s\t%s\t%s\t%s\r\n','Cell','Group','Amp','Shape','Rep','Spikes');
for(q=1:length(bagL))    
    fprintf(fileID,'%02d\t%d\t%d\t%d\t%d\t%d\r\n',bagL(q), bagN(q,:));
end
fclose(fileID);
fprintf('Done\n');

end