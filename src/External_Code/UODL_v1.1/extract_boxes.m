% script for extracting segmentation proposals and their features
%
% written by Minsu Cho, modified by Suha Kwak

function extract_boxes(name_experiment, modk, modv)

set_path;
evalc(['setup_', name_experiment]);

% suha: parameters to filter out small proposals
%size_thres_ratio = 20;

% initialize structs
feat = struct;
boxes = struct;

% setup params for randomized prim
%'config/rp_4segs.mat' to sample from 4 segmentations (slower but higher recall)
% config/rp.mat to sample from 1 segmentations (faster but lower recall)

params_rp = LoadConfigFile(fullfile(rp_root, 'config/rp.mat'));
params_rp.approxFinalNBoxes = 100;    
% or
% params_rp = LoadConfigFile(fullfile(rp_root,'config/rp_100_final_boxes.mat'));
% or





% loop through images
for i = 1 : numel(images)
    if exist('modk') && exist('modv') && mod(i, modv) ~= modk
        continue;
    end
    path_img = images{i};

    % box-proposals and their HOG descriptors
    path_feat = [path_img(1:end-4), conf.postfix_feat, '.mat'];
    if exist(path_feat, 'file') && ~overwrite
        fprintf('Extracting boxes & descriptors (%d/%d): %s done\n', i, numel(images), path_img);
        continue;
    end

    % suha: images should have 3 channels 
    %       for running "extract_segfeat_hog" without problem.
    img_org = imread(path_img);
    if ndims(img_org) < 3
        img_col = cat(3, img_org, img_org, img_org);
    elseif size(img_org, 3) == 1
        img_col = cat(3, img_org(:, :, 1), img_org(:, :, 1), img_org(:, :, 1));
    else
        img_col = img_org;
    end
    img = standarizeImage(img_col);
    fprintf('Extracting boxes & descriptors (%d/%d): %s ', i, numel(images), path_img);

    % compute segment proposals for the given image
    seg.coords = RP(img, params_rp); %[xmin, ymin, xmax, ymax]
    seg.coords = [seg.coords; 1, 1, size(img,2), size(img,1)]; % add a whole box

    % suha: filltering too small proposals out
    %size_thres = min(size(img, 1), size(img, 2)) / size_thres_ratio;
    %seg_WH = [seg.coords(:, 3) - seg.coords(:, 1), seg.coords(:, 4) - seg.coords(:, 2)];
    %list_candidate = find(min(seg_WH, [], 2) > size_thres);
    %seg.coords = seg.coords(list_candidate, :);
    
    % compute features for proposals
    ticId = tic;
    feat = extract_segfeat_hog(img,seg);
    fprintf('took %f secs.\n',toc(ticId));

    % save feats for the given image
    save(path_feat, 'feat');

    clear img_org;
    clear img_col;
    clear seg;
    clear img;
    clear feat;
end

