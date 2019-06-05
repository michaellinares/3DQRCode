function [ARRAY] = singleEmbeddedCode_(filename)
count=0;

[QRMTX,IdxVec,QSdim] = IdxSpacer_(filename);

[m,~] = size(QRMTX);
ARRAY = zeros(m,m,m); % ARRAY's size is based on the pixel dimension of the qr image
IdxVec=IdxVec/2
QSdim=QSdim*2
numberofcols = length(IdxVec)*2 % refeeres to the number of columns and rows in qr code
cellsize = IdxVec(1);
ZPOSMTX = nan(numberofcols,numberofcols); % stores the z coordinate of the bottom of each cell cube in same row/col that the cell cube is stored

cumVec = cumsum(IdxVec); 
Zrange = cumVec(QSdim+1:end-QSdim-1); % the positions in which cell cubes can be stored // QSdim is used here so that a square is produced // the -1 from the end accounts for posibility of a cell being placed on the final position

posVec = cumsum(IdxVec)% the pixel position of the near the top/left corner most point on each cell 

col = 1; row = 1;

while row <= numberofcols % going through all rows checking for cells
    
    while col <= numberofcols % going through all columns checking for cells
        
        if QRMTX(posVec(row),posVec(col)) % if this logical is true then a cell is detected at that row/col
            
            if row > 1 % the first row is always empty (Quiet Space)
                
                zPos = assignZpos_(ZPOSMTX,IdxVec,Zrange,row,col); % randomly selects z coordinate of the given cell // assignelev checks for corner/edge/face inteferance
                ZPOSMTX(row,col) = zPos; %zPos is saved inside ZPOSMTX
                
            end
            %these next lines select the coordanites in ARRAY
            Zcoordinates = zPos:zPos + cellsize ; % these coordiantes include compatiable zPos and the cell length number of coordanites above it 
            Rowcoordinates = posVec(row):posVec(row+1) ; % these coordinates include the row positon and the cell length number ...
            Colcoordinates = posVec(col):posVec(col+1) ; 
            ARRAY(Rowcoordinates,Colcoordinates,Zcoordinates) = 1; % the cube of coordiantes are "placed" inside the ARRAY
            count=count+1;
        end
        
        col = col + 1; % next row
        
    end
    
    col = 1; % row is done
    row = row + 1;% next row
    
end
end
%maxzpos = m - max(IdxVec) - 2*QSdim*min(IdxVec); % this can be used to 
