function features = faceFeatures(I, featureType)
% Extracts features for a given an image.
% Input:    I - Image. 
%           feautureType - (string) declaring what type of feautures is
%           requested. Elligible strigns are: 
%           'sift':
%           'lbp':     linear binary
%           'color':   Pixel's intensities.
%
% Written by Fan Wang.

    features = [];
    faceSize = size(I,1);
    h = size(I, 1); w = size(I, 2);               
    for i = 1:length(featureType)
        switch featureType{i}
            case 'sift'
                SIFTparam.grid_spacing = 1; % Distance between grid centers.
                patch_sizes = [16 12 8];
                for k = 1:length(patch_sizes)
                    SIFTparam.patch_size = patch_sizes(k); % Size of patch from which to compute SIFT descriptor (it has to be a factor of 4).
                    padSize = SIFTparam.patch_size/2-1;
                    if size(I,3) == 3
                        gray = rgb2gray(I); 
                    else
                        gray = I;
                    end
%                     I1 = [zeros(padSize, 2*padSize + faceSize); [zeros(faceSize, padSize) gray zeros(faceSize,padSize)]; zeros(padSize, 2 * padSize + faceSize)];   % Can we do it on a non-square image?
                    I1 = [zeros(padSize, 2*padSize + w); [zeros(h, padSize) gray zeros(h, padSize)]; zeros(padSize, 2 * padSize + w)];   % Can we do it on a non-square image?                    
                    v  = LMdenseSift(I1, '', SIFTparam);
                    features = cat(3, features, double(v));                             
                end
            case 'lbp'
                LBP = efficientLBP(I, [3,3]);
                features = cat(3, features, double(LBP)/255);
            case 'color'
                features = cat(3, features, double(I)/255);            % TODO-F why devide with 255?
            case 'hog'                
%                 patch_size = 16
%                 padSize = patch_size / 2;                              
                padSize  = 10;
                if size(I,3) == 3                                      % Avoid loosing color.
                    gray = rgb2gray(I);     
                else
                    gray = I;
                end                        
                
                h = size(I, 1); w = size(I, 2);                
                I1 = [zeros(padSize, 2*padSize + w); [zeros(h, padSize) gray zeros(h, padSize)]; zeros(padSize, 2 * padSize + w)];   % Can we do it on a non-square image?                    
                [y, x] = find(ones(size(I1, 1), size(I1, 2)));
                points = [x y];                
                [v, validPoints] = extractHOGFeatures(I1, points);                                
                f = zeros([size(I1), size(v, 2)]);
                
                for p = 1:length(validPoints)
                    f(validPoints(p, 2), validPoints(p, 1), :) = v(p,:);
                end
                
                v = f(padSize+1:padSize+h, padSize+1:padSize+w, :);              
%                 ind = sub2ind(size(I1), validPoints(:,1), validPoints(:,2));
%                 f(ind) = v;
                features = cat(3, features, double(v));         
        end
    end
end