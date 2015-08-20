
[data_path, code_path] = get_project_paths('ImageJointUnderstanding');

vlf_path   = [code_path 'vlfeat/toolbox/vl_setup'];                            % path to vlfeat
voc_devkit = [data_path 'VOC/2007/devkit'];                                    % path to voc devkit
db_root    = [data_path 'VOC/2007/Train_Validate_Data'];                       % path to dataset
rp_root    = '../rp-master';                                                   % randomized prim: bounding box proposal

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