function imcor(matx,slice,cbartext)

imagesc(squeeze(matx(slice,:,:)));
title({'Coronal plane'})
ylabel({'Right to left'})
xlabel('Caudal to cranial')
axis image
caxis([0 abs(max(max(max(matx))))])
t=colorbar;
set(get(t,'ylabel'),'String', cbartext);

end