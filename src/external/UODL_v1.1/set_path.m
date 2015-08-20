
vlf_path = '/Users/optas/Dropbox/matlab_projects/External_Packages/vlfeat/toolbox/vl_setup';                % path to vlfeat
voc_devkit = '/Users/optas/Dropbox/with_others/zimo - peter - panos/Joint_Image_Understanding/Data/VOC/2007/devkit';    % path to voc devkit
db_root  = '/Users/optas/Dropbox/with_others/zimo - peter - panos/Joint_Image_Understanding/Data/VOC/2007/Train_Validate_Data';                           % path to dataset
rp_root = '../rp-master';                               % randomized prim: bounding box proposal

run(vlf_path);

% main algorithm
addpath('./hough-match');

% auxiliary functions
addpath('./commonFunctions/');
addpath(genpath('./HOG/'));

% randomized prim proposal functions
addpath(fullfile(rp_root,'cmex'));
addpath(fullfile(rp_root,'matlab'));

% misc. tools
addpath(genpath('./tools'));