load mri
l = size(DoseAtPhantom);
l = uint8((l(1,1))^(1/3));
Dose = zeros(l,l,l);
LET = zeros(l,l,l);
m = 1;


size_bin = 0.6/l;

for i=1:l
    for j=1:l
        for k=1:l
            Dose(i,j,k) =  DoseAtPhantom(m,4);
            LET(i,j,k) = LETatPhantom(m,4);
            m = m + 1;
        end
    end
end

clear i j k m map siz D  size_bin

%% removes the points outside the dosimeter
binsize = 0.1; %0.1x0.1x0.1 cm3 bins
l = 160;

norm_dose = 0;
norm_OCT = 0;

OCT_backup = OCT;

%OCT = rescale(OCT);

for i=1:l
    for j=1:l
        for k=1:l
            if (i*0.1-8)^2+(j*0.1-8)^2 > 5^2
                Dose(i,j,k)=0;
                LET(i,j,k)=0;
                OCT(i,j,k)=0;
            end
            if norm_dose<Dose(i,j,k)
                norm_dose = Dose(i,j,k);
            end
            if norm_OCT<OCT(i,j,k)
                norm_OCT = OCT(i,j,k);
            end
        end
    end
end

%Dose1 = Dose*10^7;
Dose1 = Dose/norm_dose;
OCT1 = OCT/norm_OCT;

clear i j k l binsize ans 
% % 
% % % % 
% % % % 
% % % % cm = brighten(jet(length(map)),-.5);
% % % % colormap parula
% % % % Dose = double(squeeze(Dose));   
% % % % Dose(Dose==0)=nan;
% % % % figure
% % % % Ds = smooth3(Dose);
% % % % hold on
% % % % hiso = patch(isosurface(Ds,5),...
% % % %    'FaceColor','none',...
% % % %    'EdgeColor','none');
% % % % 
% % % % isonormals(Ds,hiso)
% % % % view(3);
% % % % 
% % % % hcap = patch(isocaps(Dose),...
% % % %         'FaceColor','interp',...
% % % %         'EdgeColor','none');
% % % %     
% % % % hold off
% % % % 
% % % % figure
% % % % h = slice(Ds, [], [], 1:size(Ds,3));
% % % % set(h,'EdgeColor','none','FaceColor','interp')
% % % % alpha(.1)
% % % % 
% % % % 
% % % % figure
% % % % slice(Ds,[1:size(Ds,3)/2],[1:size(Ds,3)/2],[]);
% % % % axis tight
% % % % view(3);

%% Matrix normalization and matrix alignment
%%gpu_Dose = gpuArray(single(Dose1));  % declares the matrices in GPU
%%gpu_OCT = gpuArray(single(OCT1));

% % % gpu_Dose = Dose1;
% % % gpu_OCT = OCT1;
% % % 
% % % maxIterations = 360; % maximum number of trials
% % % 
% % % % theta_val = zeros(1,maxIterations);
% % % % min_val1 = gpuArray(zeros(1,maxIterations));
% % % 
% % % theta_val = zeros(1,maxIterations);
% % % min_val1 = zeros(1,maxIterations);
% % % 
% % % DIF = sum(gpu_Dose - gpu_OCT, 'all');
% % % theta = 0;
% % % theta_guess = 0;
% % % for n=1:maxIterations
% % %     theta = uint8(rand * 360);
% % %     theta = theta + 1;
% % %    
% % %     
% % %     rot_Dose = imrotate(gpu_Dose, theta, 'bicubic','loose');
% % %     
% % %     rot_Dose_cent = rot_Dose(40:100, 40:100, 40:100);
% % %     gpu_OCT_cent = gpu_OCT(40:100, 40:100, 40:100);
% % % 
% % %     DIF1 = sum(rot_Dose_cent - gpu_OCT_cent, 'all');
% % %     
% % %     min_val1(1,n) = DIF1;
% % %     theta_val(1,n)=theta;
% % %  
% % %     if abs(DIF1)<abs(DIF)
% % %         theta_guess = theta;
% % %     end
% % % end
% % % 
% % % 
% % % clear DIF gpu_Dose1 n maxIterations DIFF ans
% % % 
% % % 
% % % plot(abs(min_val1))
% % % 
% % % 
% % % rot_Dose = imrotate(Dose1, 103, 'bilinear','crop');
% % % rot_LET = imrotate(LET, 103, 'bilinear', 'crop');



%% eroding figure 

% BW = imbinarize(OCT_crop);
% BW1 = imbinarize(Dose_crop);
% 
% skel_dose = bwskel(BW1);
% % skel_OCT = bwskel(BW);
% % % % 
% % figure(1)
% % volshow(skel_OCT)
% % 
% % figure(2)
% % volshow(skel_dose)

% for l=1:160
%     slice_dose = slice(Dose1, [], [], [l]);
%     slice_OCT = slice(OCT1, )

% % fixed = Dose1;
% % moving = OCT1;
% % 
% % [optimizer, metric] = imregconfig('multimodal')
% % 
% % movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
% % 
% % overlayVolume(fixed, movingRegistered)


%%%%%%%%%%% cropping matrices
%% the mc matrix is CENTERED, and we know that the dosimeter has 5 cm radius
%% and 10 cm height
R = 5; % dosimete radius
H = 10; % dosimeter height
l = 160 / 2; % lateral matrix size
bin_size = 0.1 % voxel lateral dimension (in cm)

xy = R / bin_size
z = H / (bin_size * 2);  % because we want the ofset from origin

OCT_crop = OCT1([l-xy:l+xy],[l-xy:l+xy],[55:130]);
Dose_crop = Dose1([l-xy: l+xy], [l-xy: l+ xy], [l-z-4: 117-4-12]);
LET_crop = LET([l-xy: l+xy], [l-xy: l+ xy], [l-z-4: 117-4-12]);

clear xy z R H l bin_size

% % 
% % % fixed = Dose_crop;
% % % moving = OCT_crop;
% % % 
% % % [optimizer, metric] = imregconfig('multimodal')
% % % movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
% % % overlayVolume(fixed, movingRegistered)


%%Dose_crop = Dose1([l-xy: l+xy], [l-xy: l+ xy], [l-z: 117]);

%overlayVolume(OCT_crop, Dose_crop)

% % 
% % 
% % maxIterations = 360;
% % theta_val = zeros(1,maxIterations);
% % min_val1 = zeros(1,maxIterations);
% % 
% % DIF = sum(skel_dose - skel_OCT, 'all');
% % theta = 0;
% % theta_guess = 0;
% % for n=1:maxIterations
% %     theta = uint8(rand * 360);
% %     theta = theta + 1;
% %    
% %     
% %     rot_Dose = imrotate(skel_dose, theta, 'bicubic','crop');
% %     
% %     rot_Dose_cent = rot_Dose;
% %     gpu_OCT_cent = skel_OCT;
% % 
% %     DIF1 = sum(rot_Dose_cent - gpu_OCT_cent, 'all');
% %     
% %     min_val1(1,n) = abs(DIF1);
% %     theta_val(1,n)=theta;
% %  
% %     if abs(DIF1)<abs(DIF)
% %         theta_guess = theta;
% %     end
% % end
% % 
% % 
% % figure(3)
% % plot(min_val1)
% % 
% % rot_Dose = imrotate(Dose1, theta_guess, 'bilinear','crop');
% % 
% % skel_dose = imrotate(skel_dose, theta_guess, 'bilinear', 'crop');


% % % % % % % % % % fixed = mat2gray(skel_dose);
% % % % % % % % % % moving = mat2gray(skel_OCT);
% % % % % % % % % % 
% % % % % % % % % % [optimizer, metric] = imregconfig('multimodal')
% % % % % % % % % % movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
% % % % % % % % % % overlayVolume(fixed, movingRegistered)

%skel_dose = imrotate(skel_dose, 105, 'bilinear', 'crop');

% 
% %skel_dose1 = imrotate3(skel_dose, 1,[0 1 0], 'cubic', 'crop');
% 
gpu_OCT = imrotate(OCT_crop, -105, 'bilinear', 'crop');


%overlayVolume(gpu_OCT, Dose_crop)
%% image registration of the simulation to the OCT
[optimizer, metric] = imregconfig('multimodal');
Rfixed = imref3d(size(gpu_OCT), 1,1,1);
Rmoving = imref3d(size(Dose_crop), 1,1,1);

optimizer.InitialRadius = 0.0001;
optimizer.Epsilon = 1.5e-4;
optimizer.MaximumIterations = 500;
% % % % % % % % 
% % % % % % % % movingRegisteredVolume = imregister(Dose_crop, Rmoving, gpu_OCT, Rfixed, 'rigid', optimizer, metric);
% % % % % % % % 
% % % % % % % % overlayVolume(movingRegisteredVolume*norm_dose, gpu_OCT*norm_OCT)
% % % % % % % % 
% % % % % % % % 
% % % % % % % % overlayVolume(movingRegisteredVolume - gpu_OCT*norm_OCT)


tform = imregtform(Dose_crop, gpu_OCT, 'rigid',optimizer, metric);
movingRegisteredVolume = imwarp(Dose_crop, tform, 'OutputView', imref3d(size(Dose_crop), 1,1,1));

overlayVolume(movingRegisteredVolume*norm_dose, gpu_OCT*norm_OCT);

overlayVolume(movingRegisteredVolume - gpu_OCT);


LET_crop = imwarp(LET_crop, tform, 'OutputView', imref3d(size(LET_crop),1,1,1));

% figure(4)
% volshow(gpu_OCT+skel_dose)
% 
% isit = gpu_OCT + Dose_crop;

%overlayVolume(gpu_OCT, Dose_crop1)
% figure(5)
% volshow(skel_dose)

% % figure(1)
% % volshow(rot_Dose_cent)
% % figure(2)
% % volshow(gpu_OCT_cent)

% % volshow(skel_dose)
% % 
% % h = slice(OCT1,[],[],[80:110]);
% % 
% % imshow(h)

%% between gpu_OCT, Dose_crop1
%% Matching LET and Optical signal
n = 0;
group_dose = zeros(1,897688);
group_let = zeros(1,897688);
group_OCT = zeros(1,897688);
for i=1:101
    for j=1:101
        for k=1:76
            if Dose_crop(i,j,k) > 0
                n = n +1;
                group_dose(1,n) = movingRegisteredVolume(i,j,k)*norm_dose*10^3;
                group_let(1,n) = LET_crop(i,j,k);
                group_OCT(1,n) = gpu_OCT(i,j,k)*norm_OCT;
            end
        end
    end
end

clear i j k n 

figure
scatter(group_dose, group_OCT,20,group_let,'filled');



% % % % % % % % % % % larger = 0;
% % % % % % % % % % % for i=1:160
% % % % % % % % % % %     for j=1:160
% % % % % % % % % % %         for k=1:160
% % % % % % % % % % %            trial = Dose(i,j,k);
% % % % % % % % % % %            if trial>larger
% % % % % % % % % % %                larger=trial;
% % % % % % % % % % %            end
% % % % % % % % % % %         end
% % % % % % % % % % %     end
% % % % % % % % % % % end
% % % % % % % % % % % 
% % % % % % % % % % % Dose1 = Dose/larger;
% % % % % % % % % % % 


% % % % % % % % % % % clear i j k larger trial
% % % % % % % % % % Dose1 = Dose/larger; % scaled volume dose to maximum


% 
% rot_Dose = imrotate(Dose1,102,'crop');
% 
% sum(abs(rot_Dose-OCT1), 'all')
% sum(abs(Dose1-OCT1),'all')
% 


clear Rfixed Rmoving



