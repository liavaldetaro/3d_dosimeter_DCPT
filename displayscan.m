% displayscan takes 4 parameters:
%   1. the OCT or TPS as a n*m*l matrix
%   2. the slice in the transversal plane
%   3. the slice in the Saggital plane
%   4. the slice in the coronal plane
%
% The data will be plottet in the Jet color scheme of the 3 projections in
% a horizontal fashion. The range will be automatic  between the
% highest and the lowest value of the matrix
%
% Dosimetry AU - 2019 by Janus Kramer Møller
% For questions or problems, e-mail: au521597@post.au.dk

function displayscan(Matrix,trans, sag, cor)
proj1 = trans;
proj2 = sag;
proj3 = cor;

figure
subplot(1,3,1); imtrans(Matrix,proj1,'Optical response [cm^{-1}]'); caxis auto
subplot(1,3,2); imsag(Matrix,proj2,'Optical response [cm^{-1}]');   caxis auto
subplot(1,3,3); imcor(Matrix,proj3,'Optical response [cm^{-1}]');   caxis auto
colormap jet
end