% Suha Kwak, Inria-Paris, WILLOW Project



function vis_results(name_experiment, num_max_iteration)



% =========================================================================
% PRELIMINARY

% initial setting
set_path;
evalc(['setup_', name_experiment]);
nclass_mat = length(classes);
nclass_eva = length(classes_eval);
nimage = length(images);

% for image drawing
addpath(genpath('./suha_tools'));

% list of images
load(fullfile(conf.path_result, file_metadata));

% parameters
nMaxBBoxDisp = 5;				% max # displayed bounding boxes

% path to the images and webpages
webp_path = fullfile(conf.path_result, 'Webpage');
if isempty(dir(webp_path))
	mkdir(webp_path);
end
imgs_path = fullfile(webp_path, 'img');
if isempty(dir(imgs_path))
	mkdir(imgs_path);
end

% image list per class (during Hough matching)
img_list_mat = cell(nclass_mat, 1);
for cidx = 1 : length(classes)
	img_list_mat{cidx} = find(imageClass == cidx);
end

% image list per class (during evaluation)
img_list_eva = cell(nclass_eva, 1);
for cidx = 1 : length(classes_eval)
	img_list_eva{cidx} = find(imageClass_eval == cidx);
end



% =========================================================================
% GENERATE IMAGES

img_num_list = zeros(nclass_eva, 1);
for iidx = 1 : nimage
	fprintf('Writing images: %d / %d\n', iidx, nimage);
	
	% class index (during matching/evaluation)
	cidx_mat = imageClass(iidx);
	cidx_eva = imageClass_eval(iidx);

	% class name (during matching/evaluation)
	cls_name_mat = classes{cidx_mat};
	cls_name_eva = classes_eval{cidx_eva};

	% iidx: index of image among the entire image set
	% iidx_mat: index of image during Hough matching
	% iidx_eva: index of image during evaluation
	iidx_mat = find(img_list_mat{cidx_mat} == iidx, 1, 'first');
	iidx_eva = find(img_list_eva{cidx_eva} == iidx, 1, 'first');

	% path to the co-localization results
	res_path = fullfile(conf.path_result, cls_name_mat);


	% load image/boxes ('feat.img', 'feat.boxes')
	idata   = loadView_seg(images{iidx}, 'conf', conf);
	bboxes  = frame2box(idata.frame)';
	img_org = imread(idata.fileName); % img_org = idata.img;

	% load ground-truth bounding boxes ("bbox_list")
	tt = strfind(idata.fileName, '/');
	dd = strfind(idata.fileName, '.');
	img_id = idata.fileName(tt(end) + 1 : dd(end) - 1);
	load(fullfile(conf.path_dataset, cls_name_eva, [img_id, '.mat']));	% ('bbox_list')
	gt_boxes = cell2mat(bbox_list');
	ngtboxes = size(gt_boxes, 1);

	% write original image file
	img_file_path = fullfile(imgs_path, sprintf('%s_%03d.jpg', cls_name_eva, iidx_eva));
	imwrite(img_org, img_file_path, 'jpg');


	for itr = 1 : num_max_iteration
		% load localization results ('saliency', 'conf_acc')
		load(fullfile(res_path, sprintf('sai%03d_i%02d.mat', iidx_mat, itr)));

% dense confidence image --------------------------------------------------
		% sorting raw confidences
		[saliv, ranki] = sort(conf_acc);

		% set colors
		cmap = vals2colormap(saliv, 'jet');
        cmap = ceil(cmap .* 255);

		% generate result images
		img_con = repmat(rgb2gray(img_org), [1, 1, 3]);
		for bidx = 1 : length(ranki)
			bbox = bboxes(ranki(bidx), :);
			img_con = drawBox(img_con, bbox, 2, cmap(bidx, :));
		end
		img_con_path = fullfile(imgs_path, sprintf('%s_%03d_i%02d_con.jpg', cls_name_eva, iidx_eva, itr));
		imwrite(img_con, img_con_path, 'jpg');


% top-K bounding boxes only -----------------------------------------------
		% sorting and selecting few top elements
        [ ranki, saliv ] = select_kbestbox(bboxes', saliency, nMaxBBoxDisp);
		%[saliv, ranki] = sort(saliency, 'descend');
		%saliv = saliv(1 : nMaxBBoxDisp);
		%ranki = ranki(1 : nMaxBBoxDisp);

		% set colors
        if isempty(ranki)
           img_box = repmat(rgb2gray(img_org), [1, 1, 3]);
        else
            cmap = vals2colormap(saliv, 'jet');
            cmap = ceil(cmap .* 255);

            % generate result images
            img_box = repmat(rgb2gray(img_org), [1, 1, 3]);
            for gidx = 1 : ngtboxes
                bbox = gt_boxes(gidx, :);
                img_box = drawBox(img_box, bbox, 4, [0, 0, 0]);
                img_box = drawBox(img_box, bbox, 2, [255, 255, 255]);
            end
            for bidx = numel(ranki): -1 : 1
                bbox = bboxes(ranki(bidx), :);
                img_box = drawBox(img_box, bbox, 3, cmap(bidx, :));
            end
        end
		img_box_path = fullfile(imgs_path, sprintf('%s_%03d_i%02d_box.jpg', cls_name_eva, iidx_eva, itr));
		imwrite(img_box, img_box_path, 'jpg');
    end


% final localization results ----------------------------------------------
	% load the last localization results ('saliency', 'conf_acc')
	load(fullfile(res_path, sprintf('sai%03d_i%02d.mat', iidx_mat, num_max_iteration)));

	% sorting raw confidences
	%[~, ranki] = sort(saliency, 'descend');
    [ ranki, saliv ] = select_kbestbox(bboxes', saliency, 1);
    
	% ground-truth bounding boxes
	img_res = img_org;
	for gidx = 1 : ngtboxes
		bbox = gt_boxes(gidx, :);
		img_res = drawBox(img_res, bbox, 6, [0, 0, 0]);
		img_res = drawBox(img_res, bbox, 3, [255, 255, 255]);
	end

	% estimated bounding box (top 1)
	bbox = bboxes(ranki(1), :);
	img_res = drawBox(img_res, bbox, 6, [100, 0, 0]);
	img_res = drawBox(img_res, bbox, 3, [255, 0, 0]);

	img_res_path = fullfile(imgs_path, sprintf('%s_%03d_res.jpg', cls_name_eva, iidx_eva));
	imwrite(img_res, img_res_path, 'jpg');
    
    % object box with part boxes
    img_res2 = repmat(rgb2gray(img_org), [1, 1, 3]);
    part_idx = crop_boxset(bboxes', ranki(1), conf_acc, 6);
    if numel(part_idx) > 1
        part_idx(1) = []; % eliminate the object box
        cmap = vals2colormap(conf_acc(part_idx), 'jet');
        cmap = ceil(cmap .* 255);
        for bidx = numel(part_idx): -1 : 1
            pbox = bboxes( part_idx(bidx), :);
            img_res2 = drawBox(img_res2, pbox, 6, cmap(bidx, :));
        end
    end
    img_res2 = drawBox(img_res2, bbox, 10, [100, 0, 0]);
	img_res2 = drawBox(img_res2, bbox, 6, [255, 0, 0]);
	img_res_path2 = fullfile(imgs_path, sprintf('%s_%03d_res2.jpg', cls_name_eva, iidx_eva));
	imwrite(img_res2, img_res_path2, 'jpg');
    
	img_num_list(cidx_eva) = img_num_list(cidx_eva) + 1;
end
save(fullfile(conf.path_result, 'imgspec.mat'), 'img_num_list');

