% Suha Kwak, Inria-Paris, WILLOW Project


function extract_gist(name_experiment, modk, modv);



% -------------------------------------------------------------------------
% configurations

evalc(['setup_', name_experiment]);

% parameters for GIST computation
addpath(genpath('./tools/gist/'));
gist_param.orientationsPerScale = [8 8 8 8];
gist_param.imageSize = [128 128];
gist_param.numberBlocks = 4;
gist_param.fc_prefilt = 4;
nfeat_gist = sum(gist_param.orientationsPerScale)*gist_param.numberBlocks^2;



% -------------------------------------------------------------------------
% calculate GIST features

for iidx = 1 : numel(images)
    if exist('modk') && exist('modv') && mod(iidx, modv) ~= modk
        continue;
    end
    path_img = images{iidx};

    % GIST as a holistic image descriptor
    path_gist = [path_img(1:end-4), conf.postfix_gist, '.mat'];
    if exist(path_gist, 'file')
        fprintf('Extracting gist feats (%d/%d): %s done\n', iidx, numel(images), path_img);
        continue;
    end

    tic;
    fprintf('Extracting gist feats (%d/%d): %s ', iidx, numel(images), path_img);
    img = imread(path_img);
    if iidx == 1
        [gist_feat, gist_param] = LMgist(img, '', gist_param);
    else
        gist_feat = LMgist(img, '', gist_param);
    end
    save(path_gist, 'gist_feat')
    eltime = toc;
    fprintf('took %f secs.\n', eltime);
end

