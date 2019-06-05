%----------------------------QRtoSTL-----------------------%
% -Input one or two qr codes to be converted into an 3D matrix of cubes in
% stl format
% -If only one embedded code is desired then name the false QR "ONLYONE"
% -If two embedded codes are desired, they must have the same 
% cellsize, cell dimension, and quiet space size
% -This MATLAB code is designed to work with any two codes from the same
% qr generator

clear; clc;
CorrectQR = 'QR code.png'; %input('Please input the filename of the Correct QR code =>','s');
FalseQR = 'ONLYONE'; %input('Now input the filename of the False QR code =>','s');

if strcmp(FalseQR,'ONLYONE') %check to see if there are one or two qr codes
    [ARRAY]=singleEmbeddedCode_(CorrectQR);
else
    [ARRAY]=doubleEmbeddedCode_(CorrectQR,FalseQR);
end
    
stlfilename = strcat('QRstl-',CorrectQR(1:end-4),'-',FalseQR(1:end-4),'.stl'); %create a unique filename / (1:end-4) removes the .png or .jpg from the strings
fv = isosurface(~ ARRAY, 0); 
stlwrite(stlfilename,fv) %downloaded function which triangulates the data
%stlwrite should display "Wrote 3 faces" in the command line
