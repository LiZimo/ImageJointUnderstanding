function [gist, nearest_neighbors ] = get_gist_nn(foldername)

%% given the folder 'foldername', this function computes the GIST descriptor for 
%% each image in that folder and then finds each images nearest-neighbor in that folder


%% output: gist is a [numImages x GIST_feature_size] matrix
%% nearest_neighbor is a vector.  nearest_neighbor(i) = j means that the ith image's nearest neighbor is j

folder = dir(strcat(foldername, '/', '*.jpg'));


images = zeros(512,512,3, length(folder));

for i = 1:length(folder)
    img = imresize(imread(strcat(foldername, '/', folder(i).name)), [512 512]);
    images(:,:,:,i) = img;
end


% GIST Parameters:

param.imageSize = [256 256]; % set a normalized image size
param.orientationsPerScale = [8 8 8 8]; % number of orientations per scale (from HF to LF)
param.numberBlocks = 4;
param.fc_prefilt = 4;

% Pre-allocate gist:
Nimages = size(images,4);
Nfeatures = sum(param.orientationsPerScale)*param.numberBlocks^2;
gist = zeros([Nimages Nfeatures]);

% Load first image and compute gist:
firstim = images(:,:,:,1);
[gist(1, :), param] = LMgist(firstim, '', param); % first call
% Loop:
for i = 2:Nimages
   image = images(:,:,:,i);
   gist(i, :) = LMgist(image, '', param); % the next calls will be faster
end

nns = knnsearch(gist, gist, 'k', 2);

nearest_neighbors = nns(:,2);
end