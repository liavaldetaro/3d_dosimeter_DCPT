UserInfoPath='C:\Users\au521597\Desktop\170201stor\DICOMfiler\';

listCT=ls([UserInfoPath,'CT*']);
for i=1:size(listCT,1)
    DI = dicominfo([UserInfoPath,listCT(i,:)]);
    TPS(:,:,:,i)=squeeze(dicomread([UserInfoPath,listCT(i,:)]));
    TPS=double(TPS);
    TPS(:,:,:,i)=TPS(:,:,:,i)*DI.DoseGridScaling;
    TPSinfo(i,:)=[DI.ImagePositionPatient;DI.PixelSpacing];
    %zOffset=DI.GridFrameOffsetVector;
end
TPSzInc=DI.GridFrameOffsetVector(2)-DI.GridFrameOffsetVector(1);
TPS=sum(TPS,4);%*DI.DoseGridScaling;

PixelSpacing =DI.PixelSpacing(1);
% clear DI h i listCT listRD