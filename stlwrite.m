function stlwrite(filename, varargin)
% STLWRITE   Write STL file from patch or surface data.
%
%   STLWRITE(FILE, FV) writes a stereolithography (STL) file to FILE for a
%   triangulated patch defined by FV (a structure with fields 'vertices'
%   and 'faces').
%   STLWRITE(FILE, FACES, VERTICES) takes faces and vertices separately,
%   rather than in an FV struct
%
%   STLWRITE(FILE, X, Y, Z) creates an STL file from surface data in X, Y,
%   and Z. STLWRITE triangulates this gridded data into a triangulated
%   surface using triangulation options specified below. X, Y and Z can be
%   two-dimensional arrays with the same size. If X and Y are vectors with
%   length equal to SIZE(Z,2) and SIZE(Z,1), respectively, they are passed
%   through MESHGRID to create gridded data. If X or Y are scalar values,
%   they are used to specify the X and Y spacing between grid points.
%
%   STLWRITE(...,'PropertyName',VALUE,'PropertyName',VALUE,...) writes an
%   STL file using the following property values:
%
%   MODE          - File is written using 'binary' (default) or 'ascii'.
%
%   TITLE         - Header text (max 80 chars) written to the STL file.
%
%   TRIANGULATION - When used with gridded data, TRIANGULATION is either:
%                       'delaunay'  - (default) Delaunay triangulation of X, Y
%                       'f'         - Forward slash division of grid quads
%                       'b'         - Back slash division of quadrilaterals
%                       'x'         - Cross division of quadrilaterals
%                   Note that 'f', 'b', or 't' triangulations now use an
%                   inbuilt version of FEX entry 28327, "mesh2tri".
%
%   FACECOLOR     - Single colour (1-by-3) or one-colour-per-face (N-by-3) 
%                   vector of RGB colours, for face/vertex input. RGB range
%                   is 5 bits (0:31), stored in VisCAM/SolidView format
%                   (http://en.wikipedia.org/wiki/STL_(file_format)#Color_in_binary_STL)
%
%   Example 1:
%     % Write binary STL from face/vertex data
%     tmpvol = false(20,20,20);      % Empty voxel volume
%     tmpvol(8:12,8:12,5:15) = 1;    % Turn some voxels on
%     fv = isosurface(~tmpvol, 0.5); % Make patch w. faces "out"
%     stlwrite('test.stl',fv)        % Save to binary .stl
%
%   Example 2:
%     % Write ascii STL from gridded data
%     [X,Y] = deal(1:40);             % Create grid reference
%     Z = peaks(40);                  % Create grid height
%     stlwrite('test.stl',X,Y,Z,'mode','ascii')
%
%   Example 3:
%     % Write binary STL with coloured faces
%     cVals = fv.vertices(fv.faces(:,1),3); % Colour by Z height.
%     cLims = [min(cVals) max(cVals)];      % Transform height values
%     nCols = 255;  cMap = jet(nCols);      % onto an 8-bit colour map
%     fColsDbl = interp1(linspace(cLims(1),cLims(2),nCols),cMap,cVals); 
%     fCols8bit = fColsDbl*255; % Pass cols in 8bit (0-255) RGB triplets
%     stlwrite('testCol.stl',fv,'FaceColor',fCols8bit) 

%   Original idea adapted from surf2stl by Bill McDonald. Huge speed
%   improvements implemented by Oliver Woodford. Non-Delaunay triangulation
%   of quadrilateral surface courtesy of Kevin Moerman. FaceColor
%   implementation by Grant Lohsen.
%
%   Author: Sven Holcombe, 11-24-11



% Check valid filename path
path = fileparts(filename);
if ~isempty(path) && ~exist(path,'dir')
    error('Directory "%s" does not exist.',path);
end


% Get faces, vertices, and user-defined options for writing
[faces, vertices, options] = parseInputs(varargin{:});
asciiMode = strcmp( options.mode ,'ascii');

% Create the facets
facets = single(vertices');
facets = reshape(facets(:,faces'), 3, 3, []);

% Compute their normals
V1 = squeeze(facets(:,2,:) - facets(:,1,:));
V2 = squeeze(facets(:,3,:) - facets(:,1,:));
normals = V1([2 3 1],:) .* V2([3 1 2],:) - V2([2 3 1],:) .* V1([3 1 2],:);
clear V1 V2
normals = bsxfun(@times, normals, 1 ./ sqrt(sum(normals .* normals, 1)));
facets = cat(2, reshape(normals, 3, 1, []), facets);
clear normals

% Open the file for writing
permissions = {'w','wb+'};
fid = fopen(filename, permissions{asciiMode+1});
if (fid == -1)
    error('stlwrite:cannotWriteFile', 'Unable to write to %s', filename);
end

% Write the file contents
if asciiMode
    % Write HEADER
    fprintf(fid,'solid %s\r\n',options.title);
    % Write DATA
    fprintf(fid,[...
        'facet normal %.7E %.7E %.7E\r\n' ...
        'outer loop\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'vertex %.7E %.7E %.7E\r\n' ...
        'endloop\r\n' ...
        'endfacet\r\n'], facets);
    % Write FOOTER
    fprintf(fid,'endsolid %s\r\n',options.title);
    
else % BINARY
    % Write HEADER
    fprintf(fid, '%-80s', options.title);             % Title
    fwrite(fid, size(facets, 3), 'uint32');           % Number of facets
    % Write DATA
    % Add one uint16(0) to the end of each facet using a typecasting trick
    facets = reshape(typecast(facets(:), 'uint16'), 12*2, []);
    % Set the last bit to 0 (default) or supplied RGB
    facets(end+1,:) = options.facecolor;
    fwrite(fid, facets, 'uint16');
end

% Close the file
fclose(fid);
fprintf('Wrote %d faces\n',size(faces, 2));

end




