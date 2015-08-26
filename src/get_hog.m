function [F] = get_hog(patches, image, bin_size, n_orients, patch_size)
% get the hog descriptors for a set of patches and the image it is on
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

    hog_size = (patch_size/bin_size)^2 * 4 * n_orients;

    F = zeros(size(patches,1), hog_size);

    for i = 1:size(patches,1) %TODO-P make parfor default wrapper function.
        xmin1 = patches(i, 1);
        ymin1 = patches(i, 2);
        xmax1 = patches(i, 3);
        ymax1 = patches(i, 4);

        box1 = imResample(single(image(ymin1:ymax1, xmin1:xmax1)), [patch_size patch_size])/255;
        H1 = hog(box1, bin_size, n_orients);
        H1 = reshape(H1, [hog_size, 1]);

        F(i,:) = H1;

    end
end
