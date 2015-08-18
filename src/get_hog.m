function hogs= getHog(patches, im1, binsize, nOrients, patch_size)

%% get the hog descriptors for a set of patches and the image it is on
%% binsize, nOrients, and patch_size are parameters for the hog features - these are optional

% Fill in unset optional values.
switch nargin
    case 2
        binsize = 32;
        nOrients = 4;
        patch_size = 128;
    case 3
        nOrients = 4;
        patch_size = 128;
    case 4
        patch_size = 128;
end


hog_size = (patch_size/binsize)^2 * 4 * nOrients;

hogs = zeros(size(patches,1), hog_size );

parfor i = 1:size(patches,1)
    
    
    xmin1 = patches(i, 1);
    ymin1 = patches(i, 2);
    xmax1 = patches(i, 3);
    ymax1 = patches(i, 4);
   
    box1 = imResample(single(im1(ymin1:ymax1, xmin1:xmax1)), [patch_size patch_size])/255;
    H1 = hog(box1, binsize, nOrients);
    H1 = reshape(H1, [hog_size,1]);
   
    hogs(i,:) = H1;
    
end
end
