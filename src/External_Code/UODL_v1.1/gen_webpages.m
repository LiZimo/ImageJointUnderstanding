% Suha Kwak, Inria-Paris, WILLOW Project



function gen_webpages(name_experiment, num_max_iteration)



% =========================================================================
% PRELIMINARY

% initial setting
evalc(['setup_', name_experiment]);
nclass_mat = length(classes);
nclass_eva = length(classes_eval);
nimage = length(images);

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

% path to the images and webpages
webp_path = fullfile(conf.path_result, 'Webpage');
if isempty(dir(webp_path))
	mkdir(webp_path);
end
imgs_path = fullfile(webp_path, 'img');
if isempty(dir(imgs_path))
	mkdir(imgs_path);
end

% list of images
load(fullfile(conf.path_result, 'imgspec.mat'));	% >> 'img_num_list'

% performance
load(fullfile(conf.path_result, 'perf.mat'));		% >> 'success_cls_all'

% visualization setting
iwidth_img  = 280;				% image width in webpages
iheight_img = 200;				% image height in webpages
iwidth_fig  = 500;				% figure width in webpages





% =========================================================================
% INDEX.HTML

fprintf('Writing html documents\n');

fout = fopen(fullfile(webp_path, 'index.html'), 'w');
fprintf(fout, ['<html><head><title>Hough Matching for Object Co-Localization</title></head>\n']);
fprintf(fout, ['<h1>Co-Localization in ', name_experiment, '</h1>\n']);
fprintf(fout, '<br><br>\n');

% quantitative analysis ---------------------------------------------------
fprintf(fout, ['<font size=6>Quantitative analysis</font>\n']);
fprintf(fout, '<br><br>\n');

% graphs >>>>>
% table start
fprintf(fout, '<table border="0">\n');
fprintf(fout, '<tr>\n');

img_name = fullfile('./img', 'oratio_all.png');
fprintf(fout, '<td>');
fprintf(fout, '<font size=5>Average overlap ratio vs. Iteration</font>');
fprintf(fout, '<br>');
fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_fig), '" border="1"></a>']);
fprintf(fout, '&nbsp;&nbsp;');
fprintf(fout, '</td>');

img_name = fullfile('./img', 'corloc_all.png');
fprintf(fout, '<td>');
fprintf(fout, '<font size=5>Average CorLoc score vs. Iteration</font>');
fprintf(fout, '<br>');
fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_fig), '" border="1"></a>']);
fprintf(fout, '&nbsp;&nbsp;');
fprintf(fout, '</td>');

% table end
fprintf(fout, '</tr>\n');
fprintf(fout, '</table>\n');
fprintf(fout, '<br><br>\n');

% tables >>>>>
fprintf(fout, '<font size=5>Summary of CorLoc scores</font>');
fprintf(fout, '<br>');

% table start
fprintf(fout, '<table border="1" cellspacing="2" cellpadding="5">\n');
fprintf(fout, '<tr>\n');
fprintf(fout, '<td bgcolor=#CCCCCC>Class</td>');
for iidx = 1 : num_max_iteration
	fprintf(fout, '<td>Iter %d</td>', iidx);
end
fprintf(fout, '<tr></tr>\n');
fprintf(fout, '</tr>\n');

% CorLoc per class
for cidx = 1 : nclass_eva	
	fprintf(fout, '<tr>\n');
	fprintf(fout, '<td bgcolor=#CCCCCC>%s</td>', classes_eval{cidx});
	for iidx = 1 : num_max_iteration
		fprintf(fout, '<td>%.2f</td>', corLoc_cls(cidx, iidx) .* 100);
	end
	fprintf(fout, '</tr>\n');
end


% average CorLoc
fprintf(fout, '<tr></tr>\n');
fprintf(fout, '<tr>\n');
fprintf(fout, '<td bgcolor=#CCCCCC>Average</td>');
for iidx = 1 : num_max_iteration
	fprintf(fout, '<td>%.2f</td>', corLoc_avg(iidx) .* 100);
end
fprintf(fout, '</tr>\n');


% table end
fprintf(fout, '</table>\n');
fprintf(fout, '<br><br><br>\n');




% quantitative analysis ---------------------------------------------------
fprintf(fout, ['<font size=6>Detailed results per class</font>\n']);
fprintf(fout, '<br><br>\n');

% results per class: hyperlinks
for cidx = 1 : nclass_eva
	cls_name = classes_eval{cidx};
	img_name = fullfile('./img', sprintf('%s_%03d.jpg', cls_name, 1));

	fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_img), '" border="1"></a>']);
	fprintf(fout, '<br>\n');
	fprintf(fout, ['<font size=5><a href="', cls_name, '.html">', cls_name, '</a></font>\n']);
	fprintf(fout, '<br><br><br>\n');
end

fprintf(fout, '</html>');
fclose(fout);





% =========================================================================
% HTML PAGE PER CLASS

for cidx = 1 : nclass_eva
	cls_name = classes_eval{cidx};
	success_list = success_all_cls{cidx};

	% webpage content
	fout = fopen(fullfile(webp_path, [cls_name, '.html']), 'w');
	fprintf(fout, ['<html><head><title>Hough Matching for Object Co-Localization</title></head>\n']);
	fprintf(fout, ['<h1><a href="index.html">Co-Localization in ', name_experiment, '</a> / ', cls_name, '</h1>\n']);
	fprintf(fout, '<br><br><br>\n');


% Performance -------------------------------------------------------------
	fprintf(fout, ['<font size=6>Quantitative analysis</font>\n']);

	% table start
	fprintf(fout, '<table border="0">\n');
	fprintf(fout, '<tr>\n');

	img_name = fullfile('./img', sprintf('oratio_%s.png', cls_name));
	fprintf(fout, '<td>');
	fprintf(fout, '<font size=5>Overlap ratio vs. Iteration</font>');
	fprintf(fout, '<br>');
	fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_fig), '" border="1"></a>']);
	fprintf(fout, '&nbsp;&nbsp;');
	fprintf(fout, '</td>');

	img_name = fullfile('./img', sprintf('corloc_%s.png', cls_name));
	fprintf(fout, '<td>');
	fprintf(fout, '<font size=5>CorLoc score vs. Iteration</font>');
	fprintf(fout, '<br>');
	fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_fig), '" border="1"></a>']);
	fprintf(fout, '&nbsp;&nbsp;');
	fprintf(fout, '</td>');

	% table end
	fprintf(fout, '</tr>\n');
	fprintf(fout, '</table>\n');
	fprintf(fout, '<br><br><br>\n');


% Nearest neighbor retrieval ----------------------------------------------
	fprintf(fout, ['<font size=6>Nearest neighbor retrieval</font>\n']);

	% table start
	fprintf(fout, '<table border="0">\n');
	fprintf(fout, '<tr>\n');

	img_name = fullfile('./img', sprintf('retr_acc_%s.png', cls_name));
	fprintf(fout, '<td>');
	fprintf(fout, '<font size=5>Accuracy vs. iteration</font>');
	fprintf(fout, '<br>');
	fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_fig), '" border="1"></a>']);
	fprintf(fout, '&nbsp;&nbsp;');
	fprintf(fout, '</td>');

	for itr = 1 : num_max_iteration
		img_name = fullfile('./img', sprintf('retr_cnt_%s_%d.png', cls_name, itr));
		fprintf(fout, '<td>');
		fprintf(fout, sprintf('<font size=5>Iteration %d</font>', itr));
		fprintf(fout, '<br>');
		fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_fig), '" border="1"></a>']);
		fprintf(fout, '&nbsp;&nbsp;');
		fprintf(fout, '</td>');
	end

	% table end
	fprintf(fout, '</tr>\n');
	fprintf(fout, '</table>\n');
	fprintf(fout, '<br><br><br>\n');


% Image results -----------------------------------------------------------
	fprintf(fout, ['<font size=6>Qualitative analysis</font>\n']);
	nimg = img_num_list(cidx);
	for tidx = 1 : nimg
		% table start
		fprintf(fout, '<table border="0">\n');
		fprintf(fout, '<tr>\n');

		% original image
		img_name = fullfile('./img', sprintf('%s_%03d.jpg', cls_name, tidx));
		fprintf(fout, '<td valign=top>');
		fprintf(fout, '<font size=5>Original image</font>');
		fprintf(fout, '<br>');
		fprintf(fout, ['<a href="', sprintf('%s_%d_NN.html', cls_name, tidx), '"><img src="', img_name, '" width="', num2str(iwidth_img), '" border="1"></a>']);
		fprintf(fout, '<br>');
		fprintf(fout, 'Click the image to see its nearest neighbors!');
		fprintf(fout, '&nbsp;&nbsp;&nbsp;');
		fprintf(fout, '</td>');

		% final localization result
		img_name = fullfile('./img', sprintf('%s_%03d_res.jpg', cls_name, tidx));
		fprintf(fout, '<td valign=top>');
		fprintf(fout, '<font size=5>Final localization</font>', iidx);
		fprintf(fout, '<br>');
		fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_img), '" border="1"></a>']);
		fprintf(fout, '</td>');
        
        % final localization result with parts
		img_name = fullfile('./img', sprintf('%s_%03d_res2.jpg', cls_name, tidx));
		fprintf(fout, '<td valign=top>');
		fprintf(fout, '<font size=5>Object and parts</font>', iidx);
		fprintf(fout, '<br>');
		fprintf(fout, ['<img src="', img_name, '" width="', num2str(iwidth_img), '" border="1"></a>']);
		fprintf(fout, '</td>');

		% bounding box images (top-K boxes / confidence images)
		for iidx = 1 : num_max_iteration
			img_con_name = fullfile('./img', sprintf('%s_%03d_i%02d_con.jpg', cls_name, tidx, iidx));
			img_box_name = fullfile('./img', sprintf('%s_%03d_i%02d_box.jpg', cls_name, tidx, iidx));
			if success_list(tidx, iidx) == 0
				ccode = '#FFCCCC';		% red for failures
			elseif success_list(tidx, iidx) == 1
				ccode = '#FFFFFF';		% white for correct localizations
			else
				ccode = '#CCCCCC';		% gray for negative examples
			end

			fprintf(fout, '<td bgcolor=%s>', ccode);
			fprintf(fout, '<font size=5>Iteration %d</font>', iidx);
			fprintf(fout, '<br>');			
			fprintf(fout, ['<img src="', img_con_name, '" width="', num2str(iwidth_img), '" border="1"></a>']);
			fprintf(fout, '<br>');
			fprintf(fout, ['<img src="', img_box_name, '" width="', num2str(iwidth_img), '" border="1"></a>']);
			fprintf(fout, '&nbsp;');
			fprintf(fout, '</td>');
		end

		% table end
		fprintf(fout, '</tr>\n');
		fprintf(fout, '</table>\n');
		fprintf(fout, '<br><br><br>\n');
	end

	fprintf(fout, '</html>');
	fclose(fout);
end





% =========================================================================
% SHOWING NEAREST NEIGHBORS PER TARGET IMAGE

for iidx = 1 : nimage
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


	fout = fopen(fullfile(webp_path, sprintf('%s_%d_NN.html', cls_name_eva, iidx_eva)), 'w');
	fprintf(fout, ['<html><head><title>Hough Matching for Object Co-Localization</title></head>\n']);
	fprintf(fout, ['<h1><a href="index.html">Co-Localization in ', name_experiment, '</a> / <a href="', cls_name, '.html">', cls_name_eva, '</a> / Nearest neghbors of image ', num2str(iidx_eva), '</h1>\n']);
	fprintf(fout, '<br><br><br>\n');

% -------------------------------------------------------------------------
% nearest neighbors in terms of GIST distances
	
	fprintf(fout, '<font size=6>At iteration 1 (NNs in terms of GIST distances)</font>', iidx);
	fprintf(fout, '<br><br>\n');

	% "NN_list" for this iteration number
	load(fullfile(res_path, 'NN_list_1.mat'));
	NN_list = NN_list(:, iidx_mat);
	NN_dist = NN_dist(:, iidx_mat);
	nNN = length(NN_list);

	% table start
	fprintf(fout, '<table border="0">\n');
	fprintf(fout, '<tr>\n');

	% original image
	img_name = fullfile('./img', sprintf('%s_%03d.jpg', cls_name_eva, iidx_eva));
	fprintf(fout, '<td>');
	fprintf(fout, '<font size=5>Target image</font>');
	fprintf(fout, '<br>');
	fprintf(fout, ['<img src="', img_name, '" height="', num2str(iheight_img), '" border="1"></a>']);
	fprintf(fout, '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
	fprintf(fout, '</td>');

	% nearest neighbors
	img_list_NN = img_list_mat{cidx_mat};
	for eidx = 1 : nNN
		nn_iidx = img_list_NN(NN_list(eidx));
		nn_cidx = imageClass_eval(nn_iidx);

		nn_cls_name = classes_eval{nn_cidx};
		nn_cls_list = img_list_eva{nn_cidx};
		nn_cls_iidx = find(nn_cls_list == nn_iidx);

		img_name = fullfile('./img', sprintf('%s_%03d.jpg', nn_cls_name, nn_cls_iidx));
		fprintf(fout, '<td>');
		fprintf(fout, ['<img src="', img_name, '" height="', num2str(iheight_img), '" border="1"></a>']);
		fprintf(fout, '&nbsp;');
		fprintf(fout, '<br>');
		fprintf(fout, '%f', NN_dist(eidx));
		fprintf(fout, '</td>');
	end

	% table end
	fprintf(fout, '</tr>\n');
	fprintf(fout, '</table>\n');
	fprintf(fout, '<br><br><br>\n');

% -------------------------------------------------------------------------
% nearest neighbors in terms of HOG distances

	for itr = 2 : num_max_iteration
		fprintf(fout, '<font size=6>At iteration %d (NNs in terms of HOG distances)</font>', itr);
		fprintf(fout, '<br><br>\n');

		% "NN_list" for this iteration number
		load(fullfile(res_path, sprintf('NN_list_%d.mat', itr)));
		NN_list = NN_list(:, iidx_mat);
		NN_dist = NN_dist(:, iidx_mat);
		nNN = length(NN_list);

		% table start
		fprintf(fout, '<table border="0">\n');
		fprintf(fout, '<tr>\n');

		% original image
		img_name = fullfile('./img', sprintf('%s_%03d_i%02d_box.jpg', cls_name_eva, iidx_eva, itr - 1));
		fprintf(fout, '<td>');
		fprintf(fout, '<font size=5>Target image</font>');
		fprintf(fout, '<br>');
		fprintf(fout, ['<img src="', img_name, '" height="', num2str(iheight_img), '" border="1"></a>']);
		fprintf(fout, '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
		fprintf(fout, '</td>');

		% nearest neighbors			
		for eidx = 1 : nNN
			nn_iidx = img_list_NN(NN_list(eidx));
			nn_cidx = imageClass_eval(nn_iidx);

			nn_cls_name = classes_eval{nn_cidx};
			nn_cls_list = img_list_eva{nn_cidx};
			nn_cls_iidx = find(nn_cls_list == nn_iidx);

			img_name = fullfile('./img', sprintf('%s_%03d_i%02d_box.jpg', nn_cls_name, nn_cls_iidx, itr - 1));
			fprintf(fout, '<td>');
			fprintf(fout, ['<img src="', img_name, '" height="', num2str(iheight_img), '" border="1"></a>']);
			fprintf(fout, '&nbsp;');
			fprintf(fout, '<br>');
			fprintf(fout, '%f', NN_dist(eidx));
			fprintf(fout, '</td>');
		end

		% table end
		fprintf(fout, '</tr>\n');
		fprintf(fout, '</table>\n');
		fprintf(fout, '<br><br><br>\n');
	end

	fprintf(fout, '</html>');
	fclose(fout);
end







