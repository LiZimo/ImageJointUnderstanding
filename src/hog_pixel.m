function [H1] = hog_pixel(pixel, image, bin_size, n_orients)
% get the hog descriptor centered at "pixel"; pixel is an array [xval yval]
% binsize, nOrients, and patch_size are parameters for the hog features - these are optional

    % Fill in unset optional values.
    switch nargin
        case 2
            bin_size   = 32;
            n_orients  = 4;
            patch_size = 128;
        case 3
            n_orients  = 4;
            patch_size = 128;
        case 4
            patch_size = 128;
    end
    
    
    box_size = 5;
    centerx = pixel(1);
    centery = pixel(2);
    
    
    xmin = max(1,centerx - (box_size - 1)/2);
    xmax = min(size(image,2),centerx + (box_size - 1)/2);
    ymin = max(1,centery - (box_size - 1)/2);
    ymax = min(size(image,1),centery + (box_size - 1)/2);
    
    
    Region = imResample(single(image(ymin:ymax, xmin:xmax)), [128 128])/255;
    H1 = hog(Region, bin_size, n_orients);
    
    
end