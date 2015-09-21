img = imread('chair.jpg');


[Laplacian_n, labels, eigenvectors, eigenvalues] = compute_superpixel_basis(img);
[gx,gy] = gradient(double(labels));
lblImg = double(labels);
lblImg((gx.^2+gy.^2)==0) = 0;


figure;
colormap('hot');
set(gcf,'name','5 smallest Eigenvectors w/ intensity as Laplacian weight','numbertitle','off')
subplot(2,5,1:5);

out_im = img;
out_im(lblImg ~= 0) = 0;
imshow(out_im);

for j = 1:5
    
    
eig_vec = eigenvectors(:,j);
eig_vec = (eig_vec - min(eig_vec))/(max(eig_vec) - min(eig_vec));


eig_vis = double(labels);
for i = 1:length(eig_vec)
    eig_vis(eig_vis == i) = eig_vec(i);
end
%%;
ax = subplot(2,5,j+5);
imagesc(eig_vis);
end
