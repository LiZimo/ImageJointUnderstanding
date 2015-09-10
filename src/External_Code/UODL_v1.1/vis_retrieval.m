% Suha Kwak, Inria-Paris, WILLOW Project



function vis_retrieval(name_experiment, num_max_iteration)



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
% CALCULATE RETRIEVAL PERFORMANCE

retr_cls = zeros(nclass_eva, nclass_eva, num_max_iteration);
for cidx_mat = 1 : nclass_mat

	% path to the co-localization results
	class_name_mat = classes{cidx_mat};
	res_path = fullfile(conf.path_result, class_name_mat);

	fprintf('Calculating retrieval performance for %s class\n', class_name_mat);
	
	% evaluation classes of the images in this matching class
	clist_eva = imageClass_eval(img_list_mat{cidx_mat});

	for itr = 1 : num_max_iteration

		% load nearest neighbor lists ('NN_list', 'NN_dist')
		load(fullfile(res_path, sprintf('NN_list_%d.mat', itr)));

		% evaluation classes of the queries = clist_eva
		% evaluation classes of the NNs     = NN_clist_eva
		NN_clist_eva = clist_eva(NN_list);

		for cidx_eva = 1 : nclass_eva
			tg = clist_eva == cidx_eva;
			if sum(tg) == 0
				continue;
			end
			tg_NN_clist = NN_clist_eva(:, tg);
			retr_cls(:, cidx_eva, itr) = retr_cls(:, cidx_eva, itr) + ...
										 histc(tg_NN_clist(:), (1 : (nclass_eva + 1) - 0.5));
		end
	end
end
retr_cls = retr_cls ./ nclass_mat;



% =========================================================================
% GRAPHS

fprintf('Draw graphs for retrieval performance\n');
classes_eval_dsp = cellfun(@(x) x(1:3), classes_eval, 'UniformOutput', false);

% retrieval results per evaluation-class
for cidx = 1 : nclass_eva
	class_name_eva = classes_eval{cidx};

	for itr = 1 : num_max_iteration
		retr_cls_tg = retr_cls(:, cidx, itr);
		retr_cls_tg_em = zeros(size(retr_cls_tg));
		retr_cls_tg_em(cidx) = retr_cls_tg(cidx);

		figure('Visible', 'off');
		bar(retr_cls_tg);
		hold on;
		bar(retr_cls_tg_em, 'r')
		hold off;		
		ylabel('Class count');
		set(gcf, 'Color', 'w');
		set(gca, 'XTick', [1:nclass_eva]);
		set(gca, 'XTickLabel', classes_eval_dsp);

		fig_path = fullfile(imgs_path, sprintf('retr_cnt_%s_%d.png', class_name_eva, itr));
		saveas(gcf, fig_path, 'png');
		close;
	end
end

% retrieval accuracy over iteration
retr_acc = zeros(nclass_eva, num_max_iteration);
for itr = 1 : num_max_iteration
	cls_cnt_itr = retr_cls(:, :, itr);
	retr_acc(:, itr) = diag(cls_cnt_itr) ./ sum(cls_cnt_itr, 1)';
end

for cidx = 1 : nclass_eva
	class_name_eva = classes_eval{cidx};

	figure('Visible', 'off');
	plot(1 : num_max_iteration, retr_acc(cidx, :),	...
			'-kd', 'LineWidth', 3, ...
			'Color', [.8, .1, .8], ...
			'MarkerSize', 7, ...
			'MarkerEdgeColor', [.8, .1, .8],...
			'MarkerFaceColor', [.8, .1, .8]);
	xlabel('Iterations');
	ylabel('Class retrieval accuracy');
	axis([1, num_max_iteration, 0, 1]);
	set(gcf, 'Color', 'w');

	fig_path = fullfile(imgs_path, sprintf('retr_acc_%s.png', class_name_eva));
	saveas(gcf, fig_path, 'png');
	close;
end

save(fullfile(conf.path_result, 'retr.mat'), 'retr_cls', 'retr_acc');






