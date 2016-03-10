% Suha Kwak, Inria-Paris, WILLOW Project

overwrite = false;
name_experiment = 'VOC2007_6x2';


% ----------------------------------------------------------------------
% configuration

root_result = './results/';
if isempty(dir(root_result))
    mkdir(root_result);
end 

% set paths
set_path;
conf.path_result  = fullfile(root_result, name_experiment);
conf.path_dataset = fullfile(db_root, 'VOC2007_6x2');
conf.postfix_feat = '_seg';
conf.postfix_gist = '_gist';

if isempty(dir(conf.path_result))
	mkdir(conf.path_result);
end

% files containing essential information
file_lda_bg_hog = './HOG/bg11.mat';
file_metadata   = 'files.mat';


% ----------------------------------------------------------------------
% list of images for co-localization

if ~exist(fullfile(conf.path_result, file_metadata)) || overwrite    
    fprintf('= Setup for %s\n', name_experiment);

    classes = dir(conf.path_dataset);
    classes = classes([classes.isdir]);
    classes = {classes(3:end).name};
    
    images = {};
    imageClass = {};
    for ci = 1:length(classes)
        ims = dir(fullfile(conf.path_dataset, classes{ci}, '*.bmp'));
        ims = [ ims; dir(fullfile(conf.path_dataset, classes{ci}, '*.jpg')) ];
        ims = [ ims; dir(fullfile(conf.path_dataset, classes{ci}, '*.png')) ];
        ims = cellfun(@(x)fullfile(conf.path_dataset,classes{ci},x),{ims.name},'UniformOutput',false) ;
        images = {images{:}, ims{:}};
        imageClass{end+1} = ci * ones(1,length(ims));        
    end
    imageClass = cat(2, imageClass{:});
    
    classes_eval  = classes;
    imageClass_eval  = imageClass;
    save(fullfile(conf.path_result, file_metadata), 'conf', 'images', ...
                                                    'classes', 'classes_eval', ...
                                                    'imageClass', 'imageClass_eval');
    
else
    load(fullfile(conf.path_result,file_metadata));
end




