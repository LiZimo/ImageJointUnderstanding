% Suha Kwak, Inria-Paris, WILLOW Project


% -------------------------------------------------------------------------
% Configurations 

% target classes
classes = {'aeroplane', 'bicycle', 'boat', 'bus', 'horse', 'motorbike'};
nclass  = length(classes);

% target views (object poses)
views = {'left', 'right'};
nview = length(views);

% for GIST computation
addpath(genpath('./tools/gist/'));
gist_param.orientationsPerScale = [8 8 8 8];
gist_param.imageSize = [128 128];
gist_param.numberBlocks = 4;
gist_param.fc_prefilt = 4;
nfeat_gist = sum(gist_param.orientationsPerScale)*gist_param.numberBlocks^2;



% -------------------------------------------------------------------------
% Set Path 

voc.devkit = fullfile(voc_devkit);
voc.images = fullfile(db_root, 'JPEGImages');
voc.imglist = fullfile(pwd, 'VOC2007_6x2_imglist');
voc.annotations = fullfile(db_root, 'Annotations');
addpath(genpath(voc.devkit));

% path for results
voc.dataset = fullfile(db_root, 'VOC2007_6x2');
if isempty(dir(voc.dataset))
	mkdir(voc.dataset);
end



% -------------------------------------------------------------------------
% Indexing Image-List Files 

file_list = dir(fullfile(voc.imglist, '*.imgres'));
file_list = {file_list.name};
imgset_fnames = cell(nclass, nview);

for cidx = 1 : nclass
	class_name = classes{cidx};
	class_idx  = cellfun(@(x) ~isempty(x), strfind(file_list, class_name));

	for vidx = 1 : nview
		view_name = views{vidx};
		view_idx  = cellfun(@(x) ~isempty(x), strfind(file_list, view_name));

		fidx = find(class_idx & view_idx);
		if length(fidx) ~= 1
			disp('Wrong names of imgset specification files');
			return;
		end
		imgset_fnames{cidx, vidx} = file_list{fidx};
	end
end



% -------------------------------------------------------------------------
% Prepare Images for Testing

nimg_all = zeros(nview, nclass);
for cidx = 1 : nclass
	class_name = classes{cidx};
	class_path = cell(nview);
	for vidx = 1 : nview
		view_name = views{vidx};
		class_path{vidx} = fullfile(voc.dataset, [class_name, '_', view_name]);
		if isempty(dir(class_path{vidx}))
			mkdir(class_path{vidx});
		end
	end

	for vidx = 1 : nview
		view_name = views{vidx};
		
		% list of images of this category
		img_id_list = cell(0);
		fin = fopen(fullfile(voc.imglist, imgset_fnames{cidx, vidx}), 'r');
		tline = fgets(fin);
		while ischar(tline)
			ss = find(tline == '/');
			dd = find(tline == '.');
			if isempty(ss)
				break;
			end
			img_id_list = [img_id_list; tline(ss(end) + 1 : dd(end) - 1)];
			tline = fgets(fin);
		end
		fclose(fin);
		nimg = length(img_id_list);

		for iidx = 1 : nimg
			img_id = img_id_list{iidx};
			img_name = [img_id, '.jpg'];
			ann_name = [img_id, '.xml'];
			mat_name = [img_id, '.mat'];			
			img_path = fullfile(voc.images, img_name);
			ann_path = fullfile(voc.annotations, ann_name);

			% annotation: classes and poses of objects
			anno = PASreadrecord(ann_path);
			obj_list = anno.objects;
			obj_class_list = {obj_list.class};
			obj_bbox_list  = {obj_list.bbox};	% [xmin, ymin, xmax, ymax]

			% find objects of the target class, and their bboxes
			obj_oidx  = cellfun(@(x) strcmpi(x, class_name), obj_class_list);
			bbox_list = obj_bbox_list(obj_oidx);

			% copy this image into the folder corresponding to the class/pose
			class_path_v = class_path{vidx};
			copyfile(img_path, fullfile(class_path_v, img_name));
			save(fullfile(class_path_v, mat_name), 'bbox_list');

			% compute GIST
			img = imread(img_path);
			gist_name = [img_id, '_gist.mat'];
			if iidx == 1
				[gist_feat, gist_param] = LMgist(img, '', gist_param);
			else
				gist_feat = LMgist(img, '', gist_param);
			end
			save(fullfile(class_path_v, gist_name), 'gist_feat');
		end

		nimg_all(vidx, cidx) = nimg;
	end

	disp(['Searching for the "', class_name, '" class.']);
	for vidx = 1 : nview
		disp(['-- ', views{vidx}, ' view: ', num2str(nimg_all(vidx, cidx)), ' images']);
	end
end
disp(['Total ', num2str(sum(nimg_all(:))), ' images copied'])
clear;



% -------------------------------------------------------------------------
% Finish

rmpath(genpath('./tools/gist/'));
% clear;


