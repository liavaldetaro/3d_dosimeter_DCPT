function [TPS PixelSpacing TPSzInc]=dicomimport(UserInfoPath)
%% import dicom


listRD=ls([UserInfoPath,'RD*']);
for i=1:size(listRD,1)
    DI=dicominfo([UserInfoPath,listRD(i,:)]);
    TPS(:,:,:,i)=squeeze(dicomread([UserInfoPath,listRD(i,:)]));
    TPS=double(TPS);
    TPS(:,:,:,i)=TPS(:,:,:,i)*DI.DoseGridScaling;
    TPSinfo(i,:)=[DI.ImagePositionPatient;DI.PixelSpacing];
    %zOffset=DI.GridFrameOffsetVector;
end
TPSzInc=DI.GridFrameOffsetVector(2)-DI.GridFrameOffsetVector(1);
TPS=sum(TPS,4);%*DI.DoseGridScaling;

PixelSpacing =DI.PixelSpacing(1);
% clear DI h i listCT listRD


end
