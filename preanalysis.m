clear all 

% first get path to .mat file
[file_oct,path_oct] = uigetfile('*.mat', 'Select a .mat file');

% now browse to the folder with the DICOM -files
path_tps = uigetdir('Select a folder with DICOM files');
% the following line is a shitty solution as the uigetdir does 
% not end the dir-path with a '/'

path_tps = fullfile(path_tps,'/')

% now get til OCT-data to the workspace
OCTpath = fullfile(path_oct,file_oct);
load(OCTpath);

% get the tps from the DICOM files:
% The following line will not work om a mac: dicom import will call
% dicomread that will display an error related to filepath... i think
[TPS, PixelSpacing, TPSzInc]=dicomimport(path_tps);
size_tps = size(TPS,1);
section_tps = round(size_tps/2);
displayscan(TPS,section_tps,section_tps,section_tps)
%displayscan(TPS,section_tps,section_tps,section_tps)

%
% Interpolate TPS data to match the OCT:
%%
int = 0.7429;
int2 = 0.6667; 
%%
TPS1 = TPS(9:31,3:27,10:34);
section_tps = round(size_tps/2);
displayscan(TPS1,section_tps,section_tps,section_tps)
%%
size_oct = size(OCT,1);
section_oct = round(size_oct/2);
displayscan(OCT,section_oct,section_oct,section_oct)
%%
OCT1 = OCT(25:57,23:57,9:47);
size_oct1 = size(OCT1,1);
section_oct1 = round(size_oct1/2);
displayscan(OCT1,section_oct1,section_oct1,section_oct1)
%%
[xir,yir,zir] = meshgrid(1:int:size(TPS1,1), 1:int:size(TPS1,2), 1:int2:size(TPS1,3));
TPS1=mirt3D_mexinterp(double(TPS1),xir,yir,zir);
clear xir yir zir
%%
displayscan(TPS1,round(size(TPS1,1)/2),round(size(TPS1,1)/2),round(size(TPS1,1)/2))

%% -------------% Figur 3 -----------------------
centerFixed = round(size(OCT1)/2); 
centerMoving = round(size(TPS1)/2);
figure
imshowpair(TPS1(:,:,centerMoving(3)), OCT1(:,:,centerFixed(3)));
title('Unregistered Axial slice')
%%
OCT1 = OCT1.*63-10;
%%
[optimizer,metric] = imregconfig('multimodal');
Rfixed  = imref3d(size(OCT1),1,1,1);
Rmoving = imref3d(size(TPS1),1,1,1);

optimizer.InitialRadius = 0.0001;
optimizer.Epsilon = 1.5e-4;
%optimizer.GrowthFactor = 1.01;
optimizer.MaximumIterations = 500;

movingRegisteredVolume = imregister(TPS1,Rmoving, OCT1,Rfixed, 'rigid', optimizer, metric);

figure
imshowpair(movingRegisteredVolume(:,:,15), OCT(:,:,15));
title('Axial slice of registered volume.')
%%
imtrans(movingRegisteredVolume,18,'Optical response [cm^{-1}]'); caxis auto %([0 0.7])
imtrans(OCT1,18,'Optical response [cm^{-1}]'); caxis auto

%%
geomtform =  (TPS1,Rmoving, OCT1,Rfixed, 'rigid', optimizer, metric);
%%
movingRegisteredVolume = imwarp(TPS1,Rmoving,geomtform,'bicubic','OutputView',Rfixed);
