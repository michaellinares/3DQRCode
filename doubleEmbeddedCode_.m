function [ARRAY] = doubleEmbeddedCode_(correctQRfilename,falseQRfilename)

[CORRECTQR_MTX,corIdxVec,corQSdim] = IdxSpacer_(correctQRfilename); % cor refferes to correct code
[FALSEQR_MTX,falIdxVec,falQSdim] = IdxSpacer_(falseQRfilename); % fal refferes to false code

% add line displaying how many cells there are Goal=input('You currently have  

if length(corIdxVec) ~= length(falIdxVec) || corQSdim ~= falQSdim || corIdxVec(1) ~= falIdxVec(1)
    disp('The QR Codes are not compatible')
end

[m,~] = size(CORRECTQR_MTX);
ARRAY = zeros(m,m,m); % initialize ARRAY for placing coordiantees
cellsize = corIdxVec(1);

cumVec = cumsum(corIdxVec);

totaldim = length(corIdxVec);
row = 1;
while row <= totaldim
    corRowIdx = CORRECTQR_MTX(cumVec(row),cumVec); % detects the index of all the cells in a row
    corRowPos = cumVec(corRowIdx); % lists the pixel position at which the cell starts
    
    falRowIdx = FALSEQR_MTX(cumVec(row),cumVec); % repeated for second qr code
    falRowPos = cumVec(falRowIdx);
    
    while length(corRowPos)>length(falRowPos) % in the case the correct qr has more cells in row then the false qr
        extraCell = randi([1 length(falRowPos)]); % a random cell is selected and copied to the end of the Pos 
        falRowPos = [falRowPos falRowPos(extraCell)];
        
    end
    
    while length(corRowPos)<length(falRowPos) % in case the false qr has more cells than the correct qr
        extraCell = randi([1 length(corRowPos)]);
        corRowPos = [corRowPos corRowPos(extraCell)];
        
    end % at this point the number of cells in the correct qr = false qr
    
    while sum(corRowPos)>0 % loop is run until all cells are created
        pick1 = randi([1 length(falRowPos)]); % randomly pick a random cell
        pick2 = randi([1 length(falRowPos)]);
        
        while ~falRowPos(pick1) % checking if that cell has been picked already
            pick1 = randi([1 length(falRowPos)]); % pick until a new one is selected
        end
        
        while ~corRowPos(pick2)
            pick2 = randi([1 length(corRowPos)]);
        end
        
        zPos = falRowPos(pick1); % the z position of the false one cell is the column position of the other
        falRowPos(pick1) = 0;
        colpick = corRowPos(pick2);
        corRowPos(pick2) = 0;
        
       
        Rowsel = cumVec(row):cumVec(row+1)-2; %coordinates are created for ARRAY
        Colsel = colpick:colpick+cellsize-2; % -2 insures that there is a buffer of two (1/3)
        Elevsel = zPos:zPos+cellsize-2; % unit lengths between each cell in every direction (2/3)
        ARRAY(Rowsel,Colsel,Elevsel) = 1; % so that there is no corner/edge/face interference (3/3)
    
    end
    
    row = row+1; % next row
    
end
end