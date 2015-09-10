% Suha Kwak, Inria-Paris, WILLOW Project

function run_localization_fast(name_experiment, num_max_iteration, num_NN)



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
    matlabpool open 8
end

hsfilter = fspecial3('gaussian', [5 5 5]);


% ----------------------------------------------------------------------
% HOG specification

% HOG template
hog_spec.ny = 8;
hog_spec.nx = 8;
hog_spec.nf = 31;
ndim_hog = hog_spec.nx * hog_spec.ny * hog_spec.nf;

% background HOG statistics
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

    % path to the results
    path_result = fullfile(conf.path_result, cls_name);
    if isempty(dir(path_result))
        mkdir(path_result);
    end

    fprintf('+ Co-localization of %s class -----------------\n', cls_name);
    cls_eltime = 0;

    % load "images / box proposals / GIST" on memory only once
    tic;
    view_org_list = cell(cls_nimage, 1);
    for iidx = 1 : cls_nimage
        view_org_list{iidx} = loadView_seg(cls_images{iidx}, 'conf', conf);
    end

    % whitening descriptors
    desc_wht_list = cell(cls_nimage, 1);
    parfor iidx = 1 : cls_nimage
        viewX = view_org_list{iidx};
        desc_wht = viewX.desc - repmat(hog_spec.mu_bg, 1, size(viewX.desc, 2));
        desc_wht = hog_spec.R \ (hog_spec.R' \ desc_wht);
        desc_wht = [desc_wht; (-desc_wht' * hog_spec.mu_bg)'];
        desc_wht_list{iidx} = desc_wht;
    end
    fprintf('- Load images/boxes/GISTs: %f secs \n', toc);


	for itr = 1 : num_max_iteration


% ----------------------------------------------------------------------
% preparation: box setting and NN graph construction

% for the first iteration -------------------------
        tic;
        if itr == 1            
            % whitening descriptors of voters
            view_mod_list = cell(cls_nimage, 1);
            parfor iidx = 1 : cls_nimage
                viewX = view_org_list{iidx};
                viewX.desc = desc_wht_list{iidx};
                view_mod_list{iidx} = viewX;
            end            

            % kNN search based on GIST feature
            if num_NN < cls_nimage - 1
                gist_list = cellfun(@(x) x.gist, view_org_list, 'UniformOutput', false);
                gist_list = cell2mat(gist_list)';
                gist_dist = pwdist_sq(gist_list, gist_list);
                gist_dist = gist_dist + diag(ones(cls_nimage, 1) .* inf);
                [sort_dist, sort_order] = sort(gist_dist);
                NN_list = sort_order(1:num_NN, :);
                NN_dist = sort_dist(1:num_NN, :);
                cls_nNN = num_NN;

            % all-pair matching: all images except target are source images
            else
                NN_list = repmat(1:cls_nimage, [cls_nimage, 1])';
                NN_list = reshape(NN_list(eye(cls_nimage) == 0), [cls_nimage - 1, cls_nimage]);
                NN_dist = ones(cls_nimage - 1, cls_nimage);
                cls_nNN = cls_nimage - 1;
            end

% for later iterations ----------------------------
        else
            bbox_id_list  = cell(cls_nimage, 1);
            conf_acc_list = cell(cls_nimage, 1);

            % update the box set of source images, if required
            view_mod_list = cell(cls_nimage, 1);
            for iidx = 1 : cls_nimage
                viewX = view_org_list{iidx};
                viewX.desc = desc_wht_list{iidx};   % whitening

                % load current object boxes
                load(fullfile(path_result, sprintf('sai%03d_i%02d.mat',iidx,itr-1)), 'saliency', 'conf_acc');
                bbox_id = select_kbestbox(frame2box(viewX.frame), saliency, num_object_box);
                bbox = frame2box(viewX.frame(:, bbox_id));
                
                % eliminate boxes outside of current object boxes
                if ~isempty(bbox)
                    idx_sel = crop_boxset(frame2box(viewX.frame), bbox_id, conf_acc);
                    viewX.type  = viewX.type(idx_sel);
                    viewX.frame = viewX.frame(:, idx_sel);
                    viewX.desc  = viewX.desc(:, idx_sel);
                    viewX.bbox  = bbox;
                end

                view_mod_list{iidx} = viewX;
                bbox_id_list{iidx}  = bbox_id;
                conf_acc_list{iidx} = conf_acc;
            end

            % kNN search based on HOG descriptors of object boxes
            if num_NN < cls_nimage - 1
                view_small1_list = cell(cls_nimage, 1);
                view_small2_list = cell(cls_nimage, 1);
                parfor iidx = 1 : cls_nimage
                    bbox_id  = bbox_id_list{iidx};
                    conf_acc_ = conf_acc_list{iidx};

                    viewX = view_org_list{iidx};
                    kbestbox_id = crop_kbestbox(frame2box(viewX.frame), bbox_id, conf_acc_, nKBestBox1);
                    viewX.type  = viewX.type(kbestbox_id);
                    viewX.frame = viewX.frame(:, kbestbox_id);
                    viewX.desc  = viewX.desc(:, kbestbox_id);
                    view_small1_list{iidx} = viewX;
                    
                    viewX = view_org_list{iidx};
                    kbestbox_id = kbestbox_id(1:min(nKBestBox2, length(kbestbox_id)));
                    viewX.type  = viewX.type(kbestbox_id);
                    viewX.frame = viewX.frame(:, kbestbox_id);
                    viewX.desc  = desc_wht_list{iidx}(:, kbestbox_id);
                    view_small2_list{iidx} = viewX;
                end
                
                sim_score_map = zeros(cls_nimage, cls_nimage);
                for iidx2 = 1 : cls_nimage
                    view_small2 = view_small2_list{iidx2};
                    view_small2_dup = cell(cls_nimage, 1);
                    parfor iidx = 1 : cls_nimage
                        view_small2_dup{iidx} = view_small2;
                    end
                    
                    sim_score_vec = cell(cls_nimage, 1);
                    parfor iidx = 1 : cls_nimage
                        v2 = view_small2_dup{iidx};
                        v1 = view_small1_list{iidx};
                        
                        % Hough matching >>>
                        confidenceMap = houghmatching_seg( v2, v1, hsfilter );
                        sim_score_vec{iidx} = sum(max(confidenceMap,[],2));
                    end
                    sim_score_map(:, iidx2) = cell2mat(sim_score_vec);
                end
                sim_score_map = sim_score_map + diag(ones(cls_nimage, 1) .* -inf);
                
                [sort_dist, sort_order] = sort(sim_score_map, 'descend');
                NN_list = sort_order(1:num_NN, :);
                NN_dist = sort_dist(1:num_NN, :);
                cls_nNN = num_NN;

            % all-pair matching: all images except target are source images
            else
                NN_list = repmat(1:cls_nimage, [cls_nimage, 1])';
                NN_list = reshape(NN_list(eye(cls_nimage) == 0), [cls_nimage - 1, cls_nimage]);
                NN_dist = ones(cls_nimage - 1, cls_nimage);
                cls_nNN = cls_nimage - 1;
            end
        end

        eltime = toc;
        fprintf('- Set boxes / Update kNN graphs : %f secs \n', eltime);
        cls_eltime = cls_eltime + eltime;


        for tidx = 1 : cls_nimage
            % matching only with nearest neighbors
            src_list = NN_list(:, tidx);

            fprintf('- Hough matching for image (%d/%d) of %s, iteration %d: \n', tidx, cls_nimage, cls_name, itr);

            % prepare image data for parallel computing 
            viewB = view_org_list{tidx};                % target image
            viewA_list = view_mod_list(src_list);       % source images


% ----------------------------------------------------------------------
% parallel matching of image pairs 

            tic;
            confidenceM_list = cell(cls_nNN, 1);
            confidenceB_list = cell(cls_nNN, 1);
            parfor pidx = 1 : cls_nNN
                vA = viewA_list{pidx};

                % Hough matching
                confidenceMap = houghmatching_seg( vA, viewB, hsfilter );
                confidenceB = max(confidenceMap,[],1);      % max pooling

                % store results
                confidenceM_list{pidx} = confidenceMap;
                confidenceB_list{pidx} = confidenceB;
            end
            eltime = toc;
            fprintf('    Hough matching: %f secs \n', eltime);
            cls_eltime = cls_eltime + eltime;
        

% ----------------------------------------------------------------------
% save results

            tic;
            conf_acc = zeros(1,size(viewB.frame,2));
            
            for pidx = 1 : cls_nNN
                % accumulate confidences
                confidenceB = confidenceB_list{pidx};
                conf_acc = conf_acc + confidenceB / sum(confidenceB);
            end

            % box stand-out score (contextual saliency)
            saliency = standout_box( frame2box(viewB.frame), conf_acc );
            
            % save "condifenceB_acc"
            save(fullfile(path_result, sprintf('sai%03d_i%02d.mat', tidx, itr)), 'saliency', 'conf_acc');

            eltime = toc;
            fprintf('    Saving intemediate results: %f secs \n', eltime);
            cls_eltime = cls_eltime + eltime;
        end

        % save "NN_list"
        save(fullfile(path_result, sprintf('NN_list_%d.mat', itr)), 'NN_list', 'NN_dist');
	end    

    % elapse time per class
    elapse_time_list(cidx) = cls_eltime;

    % clear large variables
    clear view_org_list;
    clear desc_wht_list;
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


