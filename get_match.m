function [rowsol, cost, cost_matrix, intersection_ratios_im1, intersection_ratios_im2] =  get_match(im1name, im2name)

%% get_match takes in 2 images, computes potential object patches on the images, and matches the patches across the images
%% based on hog-similarity.  The function also returns a matrix which details the ratio of intersection
%% between the bounding boxes of the patches.  

%% INPUTS
%% 2 image names


%% OUTPUTS
%% rowsol gives for each row the column assigned to it per the assignment problem to minimize cost.  see lapjv.m for more details
%% cost is the total assignment cost at the end
%% cost_matrix is an N x N matrix of euclidean distances in hog-space of the image patches across images, where N is the number of patches
%% intersection_ratios_im1 (and _im2)  are N x N matrices, where (i,j)th entry is the value: area(patch_i intersect patch_j)/area(patch_i).  There is one corresponding
%% to either image

binsize = 32;
nOrients = 4;
patch_size = 128;


params = load('/home/zimo/Documents/JointImageUnderstanding/rp-master/config/rp.mat');
params = params.params;

im1 = imResample(imread(im1name), [480 480]);
im2 = imResample(imread(im2name), [480 480]);

props_1 = RP(im1, params);
props_2 = RP(im2, params);


min_props = min(size(props_1,1), size(props_2, 1));

intersection_ratios_im1 = patch_overlaps(props_1(1:min_props,:));
intersection_ratios_im2 = patch_overlaps(props_2(1:min_props,:));

hog_size = (patch_size/binsize)^2 * 4 * nOrients;
prop_hogs_1 = zeros(min_props, hog_size );
prop_hogs_2 = zeros(min_props, hog_size );

% get subimages for im1 and im2, compute hog on them
parfor i = 1:min_props
    
    
    xmin1 = props_1(i, 1);
    ymin1 = props_1(i,2);
    xmax1 = props_1(i,3);
    ymax1 = props_1(i,4);
    
    xmin2 = props_2(i, 1);
    ymin2 = props_2(i,2);
    xmax2 = props_2(i,3);
    ymax2 = props_2(i,4);
    
    
    box1 = imResample(single(im1(ymin1:ymax1, xmin1:xmax1)), [patch_size patch_size])/255;
    H1 = hog(box1, binsize, nOrients);
    H1 = reshape(H1, [hog_size,1]);
    
    box2 = imResample(single(im2(ymin2:ymax2, xmin2:xmax2)), [patch_size patch_size])/255;
    H2 = hog(box2, binsize, nOrients);
    H2 = reshape(H2, [hog_size,1]);
    
    prop_hogs_1(i,:) = H1;
    prop_hogs_2(i,:) = H2;
    
end

%% cost_matrix is a matrix of euclidean distances between
%% hog descriptors of the image proposal-patches
cost_matrix = pdist2(prop_hogs_1, prop_hogs_2);

%% lapjv solves the assignment problem of patches from im1 to patches on im2, with a 
%% 1-to-1 correspondence
[rowsol,cost,v,u,costMat] = lapjv(cost_matrix);


end
