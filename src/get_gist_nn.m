function [gist, nearest_neighbors ] = get_gist_nn(images, k_nearest)

%% given this function computes the GIST descriptor for 
%% output: gist is a [numImages x GIST_feature_size] matrix
%% nearest_neighbor is a vector.  nearest_neighbor(i) = j means that the ith image's nearest neighbor is j


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

    nns = knnsearch(gist, gist, 'k', k_nearest+1);
    
    nearest_neighbors = nns(:, 2:k_nearest+1);

end