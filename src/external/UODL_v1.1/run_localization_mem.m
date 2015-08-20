% Suha Kwak, Inria-Paris, WILLOW Project

function run_localization_mem(name_experiment, num_max_iteration, num_NN)



% ======================================================================
% PRELIMINARY
% ======================================================================

% ----------------------------------------------------------------------
% parameters

% name of the current experiments
if ~exist('name_experiment', 'var')
    error('No target name is given.');
end

% max # of iteration
if ~exist('num_max_iteration', 'var')
    num_max_iteration = 5;
end

% # of nearest neighbors (inf for full-pair matching)
if ~exist('num_NN', 'var')
    num_NN = 10;
end

% maximum size of the set of NN candidates
num_max_NN = 2000;

% # of object boxes of source images
num_object_box = 5;

nKBestBox1 = 20;
nKBestBox2 = 10;


% ----------------------------------------------------------------------
% initial setting

set_path;
evalc(['setup_', name_experiment]);
addpath(genpath('./tools/'));
fprintf('+ Set paths \n');
nclass = length(classes);

% for paralalle computing (12 is max)
if matlabpool('size') == 0
    matlabpool open 12
end

hsfilter = fspecial3('gaussian', [5 5 5]);


% ----------------------------------------------------------------------
% HOG Specification

% HOG template
hog_spec.ny = 8;
hog_spec.nx = 8;
hog_spec.nf = 31;
ndim_hog = hog_spec.nx * hog_spec.ny * hog_spec.nf;

% BG HOG statistics
load(file_lda_bg_hog); % variable "bg"
[R, mu_bg] = whiten(bg, hog_spec.nx, hog_spec.ny);
hog_spec.R = R; 
hog_spec.mu_bg = mu_bg;

fprintf('+ Ready \n\n');



% ======================================================================
% ALL-PAIR HOUGH MATCHING
% ======================================================================

elapse_time_list = zeros(nclass, 1);

for cidx = 1 : nclass
    cls_images = images(imageClass == cidx);
    cls_nimage = sum(imageClass == cidx);
    cls_name = classes{cidx};
    
    num_NN_cand = min(num_max_NN, cls_nimage);
    
    % path to the results
    path_result = fullfile(conf.path_result, cls_name);
    if isempty(dir(path_result))
        mkdir(path_result);
    end
    
    fprintf('+ Co-localization of %s class (%d images)-----------------\n', cls_name, cls_nimage);
    cls_eltime = 0;

    % load GIST descriptors first ("gist_list")
    tic;
    if isempty(dir(fullfile(conf.path_result, sprintf('gist_list_%d.mat', cidx))))
        gist_list = cell(cls_nimage, 1);
        for iidx = 1 : cls_nimage
            gist_list{iidx} = load_gist(cls_images{iidx});
        end
        gist_list = cell2mat(gist_list)';
        save(fullfile(conf.path_result, sprintf('gist_list_%d.mat', cidx)), 'gist_list');
    else
        load(fullfile(conf.path_result, sprintf('gist_list_%d.mat', cidx)));
    end
    fprintf('- GISTs: %f secs \n', toc);
    
    % candidate set of NNs per example
    tic;
    if isempty(dir(fullfile(conf.path_result, sprintf('NN_cand_%d.mat', cidx))))
        gist_dist = pwdist_sq(gist_list, gist_list);
        gist_dist = gist_dist + diag(ones(cls_nimage, 1) .* inf);
        [sort_dist, sort_order] = sort(gist_dist);
        NN_cand = sort_order(1:num_NN_cand, :);
        NN_cand_dist = sort_dist(1:num_NN_cand, :);
        save(fullfile(conf.path_result, sprintf('NN_cand_%d.mat', cidx)), 'NN_cand', 'NN_cand_dist');
    else
        load(fullfile(conf.path_result, sprintf('NN_cand_%d.mat', cidx)));
    end
    fprintf('- Search for candidate NNs per example: %f secs \n', toc);
    clear('gist_list');
    
    % 4 lists used to estimate nearest neighbors
    view_tgt_sm_list = cell(cls_nimage, 1);
    view_src_sm_list = cell(cls_nimage, 1);
    view_elimin_list = cell(cls_nimage, 1);
    view_elimin_list_prev = cell(cls_nimage, 1);
    
    for itr = 1 : num_max_iteration

% ----------------------------------------------------------------------
% preparation: NN graph construction

        tic;
        if itr == 1
            NN_list = NN_cand(1:num_NN, :);
            NN_dist = NN_cand_dist(1:num_NN, :);
            cls_nNN = num_NN;
            
        else
            sim_score_map = zeros(cls_nimage, cls_nimage);
            for iidx_tgt = 1 : cls_nimage
                view_tgt_sm = view_tgt_sm_list{iidx_tgt};
                
                if 1
                    % selective matching >>>
                    sim_score_vec = cell(num_NN_cand, 1);
                    view_src_sm_subset_list = view_src_sm_list(NN_cand(1:num_NN_cand, iidx_tgt));
                    parfor iidx_src = 1 : num_NN_cand
                        view_src_sm = view_src_sm_subset_list{iidx_src};
                        confidenceMap = houghmatching_seg(view_tgt_sm, view_src_sm, hsfilter);
                        sim_score_vec{iidx_src} = sum(max(confidenceMap, [], 2));
                    end
                    sim_score_map(NN_cand(1:num_NN_cand, iidx_tgt), iidx_tgt) = cell2mat(sim_score_vec);
                else
                    % all pair matching >>>
                    sim_score_vec = cell(cls_nimage, 1);
                    parfor iidx_src = 1 : cls_nimage
                        view_src_sm = view_src_sm_list{iidx_src};
                        confidenceMap = houghmatching_seg(view_tgt_sm, view_src_sm, hsfilter);
                        sim_score_vec{iidx_src} = sum(max(confidenceMap, [], 2));
                    end
                    sim_score_map(:, iidx_tgt) = cell2mat(sim_score_vec);
                end
            end
            sim_score_map = sim_score_map + diag(ones(cls_nimage, 1) .* -inf);
            [sort_dist, sort_order] = sort(sim_score_map, 'descend');
            NN_list = sort_order(1:num_NN, :);
            NN_dist = sort_dist(1:num_NN, :);
            cls_nNN = num_NN;
            view_elimin_list_prev = view_elimin_list;
        end
        fprintf('- Nearest neighbor search for class %s, iteration %d: %f secs \n', cls_name, itr, toc);

        
        for tidx = 1 : cls_nimage
            fprintf('- Hough matching for image (%d/%d) of %s, iteration %d: \n', tidx, cls_nimage, cls_name, itr);

            
% ----------------------------------------------------------------------
% prepare image data for parallel computing
            
            % load target image information
            view_tgt = loadView_seg(cls_images{tidx}, 'conf', conf);

            % source image
            if itr == 1
                view_src_list = cell(cls_nNN, 1);
                for iidx = 1 : cls_nNN
                    nidx = NN_list(iidx, tidx);
                    viewX = loadView_seg(cls_images{nidx}, 'conf', conf);
                    desc_wht = viewX.desc - repmat(hog_spec.mu_bg, 1, size(viewX.desc, 2));
                    desc_wht = hog_spec.R \ (hog_spec.R' \ desc_wht);
                    viewX.desc = [desc_wht; (-desc_wht' * hog_spec.mu_bg)'];
                    view_src_list{iidx} = viewX;
                end
            else
                view_src_list = view_elimin_list_prev(NN_list(: , tidx));
            end
            fprintf('    Preparing for parallel matching: %f secs \n', toc);


% ----------------------------------------------------------------------
% parallel matching of image pairs
            
            tic;
            confidenceM_list = cell(cls_nNN, 1);
            confidenceB_list = cell(cls_nNN, 1);
            parfor pidx = 1 : cls_nNN
                view_src = view_src_list{pidx};
                
                % Hough matching >>>
                confidenceMap = houghmatching_seg(view_src, view_tgt, hsfilter);
                confidenceB = max(confidenceMap, [], 1);      % max pooling
                
                % store results
                confidenceM_list{pidx} = confidenceMap;
                confidenceB_list{pidx} = confidenceB;
            end
            eltime = toc;
            fprintf('    Hough matching: %f secs \n', eltime);
            cls_eltime = cls_eltime + eltime;


% ----------------------------------------------------------------------
% summarize matching results

            tic;

            % accumulate confidences
            conf_acc = zeros(1, size(view_tgt.frame, 2));
            for pidx = 1 : cls_nNN                
                confidenceB = confidenceB_list{pidx};
                conf_acc = conf_acc + confidenceB / sum(confidenceB);
            end
            
            % box stand-out score (contextual saliency)
            saliency = standout_box( frame2box(view_tgt.frame), conf_acc );

            eltime = toc;
            fprintf('    Saving intemediate results: %f secs \n', eltime);
            cls_eltime = cls_eltime + eltime;

            % save results in .mat
            save(fullfile(path_result, sprintf('sai%03d_i%02d.mat', tidx, itr)), 'saliency', 'conf_acc');


% ----------------------------------------------------------------------
% prepare next matching
            
            tic;
            bbox_id = select_kbestbox(frame2box(view_tgt.frame), saliency, num_object_box);
            bbox = frame2box(view_tgt.frame(:, bbox_id));
            
            % box elimination
            viewX = view_tgt;
            if ~isempty(bbox)
                idx_sel = crop_boxset(frame2box(view_tgt.frame), bbox_id, conf_acc);
                viewX.type  = viewX.type(idx_sel);
                viewX.frame = viewX.frame(:, idx_sel);
                viewX.desc  = viewX.desc(:, idx_sel);
                desc_wht    = viewX.desc - repmat(hog_spec.mu_bg, 1, size(viewX.desc, 2));
                desc_wht    = hog_spec.R \ (hog_spec.R' \ desc_wht);
                viewX.desc  = [desc_wht; (-desc_wht' * hog_spec.mu_bg)'];
                viewX.bbox  = bbox;
            end
            view_elimin_list{tidx} = viewX;

            % for small Hough matching
            kbestbox_id_src = crop_kbestbox(frame2box(view_tgt.frame), bbox_id, conf_acc, nKBestBox1);
            kbestbox_id_tgt = kbestbox_id_src(1:min(nKBestBox2, length(kbestbox_id_src)));
            
            % small view - as a target
            viewX = view_tgt;
            viewX.frame = viewX.frame(:, kbestbox_id_tgt);
            viewX.desc  = viewX.desc(:, kbestbox_id_tgt);         
            desc_wht    = viewX.desc - repmat(hog_spec.mu_bg, 1, size(viewX.desc, 2));
            desc_wht    = hog_spec.R \ (hog_spec.R' \ desc_wht);
            viewX.desc  = [desc_wht; (-desc_wht' * hog_spec.mu_bg)'];
            viewX.bbox  = [ 1, 1, viewX.imsize(1), viewX.imsize(2) ]';   
            view_tgt_sm_list{tidx} = viewX;

            % small view - as a source
            viewX = view_tgt;
            viewX.frame = viewX.frame(:, kbestbox_id_src);
            viewX.desc  = viewX.desc(:, kbestbox_id_src);
            viewX.bbox  = [ 1, 1, viewX.imsize(1), viewX.imsize(2) ]';
            view_src_sm_list{tidx} = viewX;

            eltime = toc;
            fprintf('    Preparing next matching: %f secs \n', eltime);
            cls_eltime = cls_eltime + eltime;
        end
        
        % save "NN_list"
        save(fullfile(path_result, sprintf('NN_list_%d.mat', itr)), 'NN_list', 'NN_dist');
    end
    
    % elapse time per class
    elapse_time_list(cidx) = cls_eltime;
end



% ======================================================================
% FINISH
% ======================================================================

% display elapse times
fprintf('+ Elapse times -----------------\n');
for cidx = 1 : nclass
    fprintf('- %s: %f mins \n', classes{cidx}, elapse_time_list(cidx) / 60);
end
fprintf('- Total %f hours \n', sum(elapse_time_list) / 3600)
fprintf('\n\n\n');
save(fullfile(conf.path_result, 'elapse_time.mat'), 'elapse_time_list');

% close helpers
% matlabpool close;
rmpath(genpath('./tools/'));

% analyze/visualize the results
vis_results(name_experiment, num_max_iteration);
vis_CorLoc(name_experiment, num_max_iteration);
vis_retrieval(name_experiment, num_max_iteration);
gen_webpages(name_experiment, num_max_iteration);


