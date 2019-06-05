function [QRMTX,IdxVec,QSdim] = IdxSpacer_(filename)
%this function creates qr code matrix of ones and zeros.
%QR is binary matrix with each pixel representing an element, this is also
%used to find the spacing between each row
%totaldim is the total number of cells from end to end
%IdxVec vector with the pixel width of each column in the qr code

UNREDUCEDQR = imbinarize(imread(filename));%turns b/w rgb image into binary % qr code must be fully black, grey tones can cause problems

QRMTX = UNREDUCEDQR(:,:,1); %reduces multidimential image matrixes into a 2D Matrix

[~, hgt] = size(QRMTX); % records the pixel height and width
col = 1; % col refers to the # of pixels from the left side
row = 1; % row refers to the # of pixels from the top side

if QRMTX(1,1) % checks that black pixels are stored as ones and inverts if necessary
    QRMTX = ~QRMTX;
end

topquiet = 0; leftquiet = 0;
while ~QRMTX(row,col) %%find the top left corner position marker by going (1,1) (2,2) (3,3) until a pixel is hit
    row = row + 1;
    topquiet = topquiet + 1;
    col = col + 1;
    leftquiet = leftquiet + 1;
end

while QRMTX(row-1,col) % moves up until the white pixel is detected
    row = row-1;
    topquiet = topquiet - 1;
end

while QRMTX(row,col-1) % moves left until the white pixel is detected
    col = col - 1;
    leftquiet = leftquiet - 1;
end % at this point col and row define the top left pixel of the top left position marker

if leftquiet == topquiet
    QuietZone(1) = leftquiet; % Left/Top Buffer // # of white pixels on the left // These are the same becasue of diagonal sysmetry
else
    disp('the qr code is not sysmtrical along the diagonal')
end

PositionMarkerdim = 0;
while QRMTX(row,col) % counting the number of pixels in the top line of the top left box
    col = col + 1;
    PositionMarkerdim = PositionMarkerdim + 1;
end

cellsize = PositionMarkerdim/7; % positon markers are 7 cell x 7 cell blocks

if floor(cellsize) ~= cellsize
    cellsize = floor(cellsize); % correcting for rectangualr cells in the position marker
end

col = QuietZone(1) + 1; row = QuietZone(1) + cellsize*4;  % positon along the middle left side of the position marker

toggle1 = 1; count = 0; % checking the cellsize of cells in the position marker by going left to right

while toggle1 ~= 6 % as you go from right to left the value switches 5 times
    if QRMTX(row,col) == QRMTX(row,col+1) % move right if the next one is equal to the current
        col = col+1;
        count = count + 1; % add one to the cell's length
    else % there is a switch
        count=count+1;
        IdxVec(toggle1) = count; % the cell length is stored // toggle1 acts as the index of the cell length that was just measured
        count = 0;
        col = col + 1;
        toggle1 = toggle1 + 1; % a switch happened
    end
end

row = col - 1; % position for the timing line // the col is the right most edge of the position marker
while count <= cellsize % cell lengths of all the timing line cells are indexed until the position marker is reached
    if QRMTX(row,col) == QRMTX(row,col+1)
        col = col + 1;
        count = count + 1;
    else
        count = count + 1;
        IdxVec(toggle1) = count;
        count = 0;
        col = col + 1;
        toggle1 = toggle1 + 1;
    end
end

row = row - cellsize*4; % move the left middle edge of the top right position marker
col = col - cellsize - 1;

count = 0; toggle2 = 0; % a new toggle variable is created so that toggle1 can be used to index
while toggle2 ~= 5 %check top right positiong square
    if QRMTX(row,col) == QRMTX(row,col+1)
        col = col+ 1;
        count = count+1;
    else
        count = count + 1;
        IdxVec(toggle1) = count;
        count = 0;
        col = col + 1;
        toggle1 = toggle1 + 1;
        toggle2 = toggle2 + 1;
    end
end

TLCSrem = rem(IdxVec(3),cellsize); % checking the center squares of the position markers for rectangular cells
TRCSrem = rem(IdxVec(length(IdxVec)-2),cellsize);

if TLCSrem ~= 0 % if there is remaineder - the middle becomes rectangular
    IdxVec = [IdxVec(1:2) cellsize cellsize+1 cellsize IdxVec(4:end)];
else % otherwise space evenly
    IdxVec = [IdxVec(1:2) cellsize cellsize cellsize IdxVec(4:end)];
end

if TRCSrem ~= 0
    IdxVec = [IdxVec(1:length(IdxVec)-3) cellsize cellsize+1 cellsize IdxVec(length(IdxVec)-1:end)];
else
    IdxVec = [IdxVec(1:length(IdxVec)-3) cellsize cellsize cellsize IdxVec(length(IdxVec)-1:end)];
end

row = hgt; col = QuietZone(1) + 1; % postion on the bottom side of the QR and along the left edge of the bottom right Position Marker
while ~QRMTX(row,col) % count the # of white pixels on the bottom of the qr
    row = row - 1; % move up until the bottom of the bottom left positon marker is detected
end

QuietZone(2) = hgt - row; % bottom buffer

QuietZoneSpacing = floor(QuietZone/cellsize); %this inticates the amount of cells in the quiet space 
QSdim = QuietZoneSpacing(1); % used later in contruction of matrix

LeftQuietCells = repmat(cellsize,QSdim,1)'; % adding the cells in the quiet space to IdxVec
RightQuietCells = repmat(cellsize,QSdim,1)';
IdxVec = [LeftQuietCells IdxVec RightQuietCells];

Crop = mod(QuietZone,cellsize); % some codes have an asymetrical buffer, this corrects for it there is a remainder
QRMTX = QRMTX(:,1+Crop(1):end-Crop(2));
QRMTX = QRMTX(1+Crop(1):end-Crop(2),:);

recPos = find(IdxVec==cellsize+1); % index of where the rectangle cells are in IdxVec
CumVec = cumsum(IdxVec); % Pixel position of the beginging of each cell
for n = 1:length(recPos) %Here the matrix is corrected to remove rectangular cells
    QRMTX = [QRMTX( : ,1:CumVec(recPos(n)-1) ) , QRMTX( : ,CumVec(recPos(n)-1)+2:end)]; % if there is a rectangle, a column of pixels is skipped
    QRMTX = [QRMTX(1:CumVec(recPos(n)-1), : ); % a row of pixels is skipped
             QRMTX(CumVec(recPos(n)-1)+2:end, : )];
    CumVec = CumVec- 1; % all values are shifted back one
end

IdxVec(recPos) = IdxVec(recPos) - 1; % rectangle cells are removed
% IdxVec inticates the number of cell (length(IdxVec)) and the cell length

end