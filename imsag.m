function imsag(matx,slice,cbartext)

imagesc(squeeze(matx(:,slice,:))), 
title('Sagittal plane')
ylabel({'Anterior to posterior'})
xlabel('Caudal to cranial')
axis image
caxis([0 abs(max(max(max(matx))))])
t=colorbar;
set(get(t,'ylabel'),'String', cbartext);

end