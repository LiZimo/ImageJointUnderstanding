% Suha Kwak, Inria-Paris, WILLOW Project



function vis_CorLoc(name_experiment, num_max_iteration)



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
nMaxBBoxDisp = 3;				% max # displayed bounding boxes

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

% path to the file summarizing performance
perf_path = fullfile(conf.path_result, 'perf.mat');



% =========================================================================
% CALCULATE CORLOC SCORES

% overlap ratio
overlap_list = zeros(nimage, num_max_iteration);

% success or not (0: fail, 1: success, 2: negative class)
success_list = zeros(nimage, num_max_iteration, 'uint8');

for iidx = 1 : nimage
	fprintf('Calculate scores: %d / %d\n', iidx, nimage);
	
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

	% ignore images without GT boxes (or negative images)
	if isempty(gt_boxes)
		overlap_list(iidx, :) = -1;
		success_list(iidx, :) = 2;
		continue;
	end

	% box to rect
	gt_rects = gt_boxes;
	gt_rects(:, 3:4) = gt_rects(:, 3:4) - gt_rects(:, 1:2) + 1;
	ngtrect = size(gt_rects, 1);


	for itr = 1 : num_max_iteration
		% load localization results ('saliency', 'conf_acc')
		load(fullfile(res_path, sprintf('sai%03d_i%02d.mat', iidx_mat, itr)));

		% best rectangle
		[saliv, ranki] = sort(saliency);
		best_rect = bboxes(ranki(end), :);
		best_rect(:, 3:4) = best_rect(:, 3:4) - best_rect(:, 1:2) + 1;

		% intersection/union areas
		int_area = rectint(best_rect, gt_rects);
		uni_area = zeros(1, ngtrect);
		for gidx = 1 : ngtrect
			uni_area(gidx) = prod(best_rect(3:4)) + prod(gt_rects(gidx, 3:4));
		end
		uni_area = uni_area - int_area;

		ovl_ratio = int_area ./ uni_area;
		overlap_list(iidx, itr) = max(ovl_ratio);
		if max(ovl_ratio) > 0.5
			success_list(iidx, itr) = 1;
		end
	end	
end


% summary per class
fprintf('Summarize performance\n');
oratio_all_cls  = cell(nclass_eva, 1);
success_all_cls = cell(nclass_eva, 1);
for cidx = 1 : nclass_eva
	oratio_all_cls{cidx}  = overlap_list(img_list_eva{cidx}, :);
	success_all_cls{cidx} = success_list(img_list_eva{cidx}, :);
end


% summary for all
corLoc_cls = zeros(nclass_eva, num_max_iteration);
oratio_cls = zeros(nclass_eva, num_max_iteration);

for cidx = 1 : nclass_eva
	oratio_list = oratio_all_cls{cidx};
	oratio_list = oratio_list(oratio_list(:, 1) >= 0, :);	% ignore negative images
	cls_nimage = size(oratio_list, 1);

	mean_oratio = mean(oratio_list, 1);
	oratio_cls(cidx, :) = mean_oratio;

	corLoc_val = sum(oratio_list > 0.5, 1) ./ cls_nimage;
	corLoc_cls(cidx, :) = corLoc_val;
end

corLoc_avg = mean(corLoc_cls, 1);
oratio_avg = mean(oratio_cls, 1);

save(perf_path, 'oratio_all_cls', 'success_all_cls', ...
				'corLoc_cls', 'corLoc_avg', ...
				'oratio_cls', 'oratio_avg');



% =========================================================================
% GRAPHS

fprintf('Draw figures\n');

% per class
for cidx = 1 : nclass_eva
	oratio_list = oratio_all_cls{cidx};
	oratio_list = oratio_list(oratio_list(:, 1) >= 0, :);	% ignore negative images

	cls_name = classes_eval{cidx};
	cls_nimage = size(oratio_list, 1);

	mean_ovrp_ratio = mean(oratio_list, 1);
	figure('Visible', 'off');
	plot(1:num_max_iteration, mean_ovrp_ratio, '-kd', 'LineWidth', 3, ...
								'Color', [.8, .1, .8], ...
								'MarkerSize', 7, ...
								'MarkerEdgeColor', [.8, .1, .8],...
                				'MarkerFaceColor', [.8, .1, .8]);
	xlabel('Iterations');
	ylabel('Overlap ratio');
	axis([1, num_max_iteration, 0, 1]);
	set(gcf, 'Color', 'w');
	% set(gcf, 'Position', [500, 500, 320, 200]);
	fig_path = fullfile(imgs_path, sprintf('oratio_%s.png', cls_name));
	saveas(gcf, fig_path, 'png');
	close;

	corLoc_val = sum(oratio_list > 0.5, 1) ./ cls_nimage;
	figure('Visible', 'off');
	plot(1:num_max_iteration, corLoc_val, '-kd', 'LineWidth', 3, ...
							'Color', [.8, .1, .8], ...
							'MarkerSize', 7, ...
							'MarkerEdgeColor', [.8, .1, .8],...
                			'MarkerFaceColor', [.8, .1, .8]);
	xlabel('Iterations');
	ylabel('CorLoc');
	axis([1, num_max_iteration, 0, 1]);
	set(gcf, 'Color', 'w');
	% set(gcf, 'Position', [500, 500, 320, 200]);
	fig_path = fullfile(imgs_path, sprintf('corloc_%s.png', cls_name));
	saveas(gcf, fig_path, 'png');
	close;
end

% overall
figure('Visible', 'off');
plot(1:num_max_iteration, oratio_avg, '-kd', 'LineWidth', 3, ...
							 'Color', [.8, .1, .8], ...
							 'MarkerSize', 7, ...
							 'MarkerEdgeColor', [.8, .1, .8],...
                			 'MarkerFaceColor', [.8, .1, .8]);
xlabel('Iterations');
ylabel('Overlap ratio');
axis([1, num_max_iteration, 0, 1]);
set(gcf, 'Color', 'w');
% set(gcf, 'Position', [500, 500, 320, 200]);
fig_path = fullfile(imgs_path, 'oratio_all.png');
saveas(gcf, fig_path, 'png');
close;

figure('Visible', 'off');
plot(1:num_max_iteration, corLoc_avg, '-kd', 'LineWidth', 3, ...
							 'Color', [.8, .1, .8], ...
							 'MarkerSize', 7, ...
							 'MarkerEdgeColor', [.8, .1, .8],...
                			 'MarkerFaceColor', [.8, .1, .8]);
xlabel('Iterations');
ylabel('CorLoc');
axis([1, num_max_iteration, 0, 1]);
set(gcf, 'Color', 'w');
% set(gcf, 'Position', [500, 500, 320, 200]);
fig_path = fullfile(imgs_path, 'corloc_all.png');
saveas(gcf, fig_path, 'png');
close;

