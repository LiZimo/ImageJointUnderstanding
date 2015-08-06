function [output, cost_matrix] =  get_match(im1name, im2name)

%% output is a cell-array containg: {rowsol, cost, v, u, costMat}, output to assignment problem.  
%% cost_matrix is a matrix of euclidean
%% distances of the image patches.  Look to lapjv.m for more details.  

binsize = 32;
nOrients = 4;
patch_size = 128;


params = load('/home/zimo/Documents/JointImageUnderstanding/rp-master/config/rp.mat');
params = params.params;

im1 = imResample(imread(im1name), [480 480]);
im2 = imResample(imread(im2name), [480 480]);

props_1 = RP(im1, params);
props_2 = RP(im2, params);

size(props_1)
size(props_2)

min_props = min(size(props_1,1), size(props_2, 1));


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
output = {rowsol, cost, v, u, costMat};
end
