function imtrans(matx,slice,cbartext)

imagesc(matx(:,:,slice)),
title({'Transversal plane'});
xlabel({'Right to left'})
ylabel('Anterior to posterior')
axis image
caxis([0 max(max(max(matx)))])
t=colorbar;
set(get(t,'ylabel'),'String', cbartext);
end