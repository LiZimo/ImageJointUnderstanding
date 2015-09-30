function myfig = draw_lines (pixel_indices, im1, im2)



howmany = size(pixel_indices,1);
middle_buffer = uint8(ones(size(im1,1), 30,3));
final_im = [im1 middle_buffer im2];

plot_X_start = zeros(1,howmany);
plot_X_end = zeros(1,howmany);
plot_Y_start = zeros(1,howmany);
plot_Y_end = zeros(1, howmany);

for i = 1:size(pixel_indices,1)
    
    X0 = pixel_indices(i,2);
    Y0 = pixel_indices(i,1);
    X1 = pixel_indices(i,4) + size(middle_buffer,2) + size(im1,2);
    Y1 = pixel_indices(i,3);
    
    final_im(Y0,X0,:) = [255 255 255];
    final_im(Y1, X1,:) = [255 255 255];
    
    plot_X_start(i) = X0;
    plot_X_end(i) = X1;
    plot_Y_start(i) = Y0;
    plot_Y_end(i) = Y1;
end

myfig = figure;
set(myfig,'Visible', 'off', 'name','hi','numbertitle','off') 
imagesc(final_im);
hold on;
for j = 1:howmany
    Xs = [plot_X_start(j) plot_X_end(j)];
    Ys = [plot_Y_start(j) plot_Y_end(j)];
    plot(Xs, Ys);


end
end