%% Load images and off-the-shelf patches.
im1_name = '../data/aeroplane_left_007.jpg';
im2_name = '../data/aeroplane_left_008.jpg';
im1      = imread(im1_name);
im2      = imread(im2_name);

params = load('external/rp-master/config/rp.mat');  % Default Params for RP method.
params = params.params;

patches1 = RP(im1, params);
patches2 = RP(im2, params);

%% Extract HOG Feautures and spatial relation between patches.
bin_size    = 32;  % Hog related parameters
n_orients   = 4;
patch_size  = 128;
get_hog()


