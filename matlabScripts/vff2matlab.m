% - vff to matlab takes vff files from Modus QA Vista 16 Cone Beam Scanner
% and makes them into a .mat file with the scanned matrix. The output will
% be a n*n*n matrix. 
%
% - Just run the file from the command window
%
% - The function does not take any variables, but it will leave a variable
% similar to the saved data in the Workspace, always with the name OCT. 
%
% - the user will be promted first for the file and placement on the disc of the
% vff-file, then for the name of the .mat-file and where it should be
% placed.
%
% Dosimetry AU - 2019 by Janus Kramer Møller
% For questions or problems, e-mail: au521597@post.au.dk

function vff2matlab()
% get filepath and name  - Path currently redundant
[file_open,path_open] = uigetfile('*.vff', 'Select a vff file');

% get size from vff header
openpath = fullfile(path_open,file_open);
fileID = fopen(openpath);

% the following line finds the line where size is defined in the vff-file
% notice that the '%s %d %s' part is written only to get the dimension of
% the scan - it is always a n*n*n matrix unless you cropped it in
% reconstruction
fileinfo = textscan(fileID,'%s %d %s','headerlines',6,'CollectOutput',true);
size = fileinfo{2};
n = size(1);

% set size - if the conversion fails this could indicate that the size is
% wrong
volumeDim = [n n n];
fclose(fileID);

% open and read vff file
fid = fopen(openpath,'r');
data = fread(fid,inf,'*uint8'); % read and output as uint8
fclose(fid);

% calculate offset - important this will exclude the header data
% length used instead of size - if you get problems maybe try size
offset = length(data) - prod(volumeDim) * 4 + 1; % calculate offset position of image data

assert((offset >= 0) && (offset <= 1000), 'offset should be within range 0 - 1000, check that volumeDim is set correctly');

% format image data
data_img = data(offset:end);             % need to remove header from data
data_img = typecast(data_img, 'single'); % convert to 32-bit float
data_img = swapbytes(data_img);          % swap to little endian for little-endian machines
img = reshape(data_img, volumeDim);

OCT = double(img);

% save file to .mat format
[file_save, path_save] = uiputfile('*.mat');
savepath = fullfile(path_save,file_save);
save(savepath, 'OCT');

% end of program
%clear data data_img fid file_open file_save fileID fileinfo img n offset openpath path_open path_save savepath size volumeDim 
sprintf('file successfully converted to .mat format')
end
