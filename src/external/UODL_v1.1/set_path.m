
vlf_path = '../vlfeat/toolbox/vl_setup';                % path to vlfeat
voc_devkit = '/local2/mcho/code/datasets/VOCdevkit';    % path to voc devkit
db_root  = '../data/VOC2007';        % path to dataset
rp_root = '../rp-master';            % randomized prim: bounding box proposal

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