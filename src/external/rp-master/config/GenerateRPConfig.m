% This script stores in a file the standard configuration of RP for using
% just one segmentation in LAB colorspace. The parameters were trained with
% the VOC 2007 dataset. Further details can be found in the paper:
%
%"S. Manen, M. Guillaumin, and L. Van Gool. Prime Object Proposals with
%Randomized Prim's Algorithm. In ICCV, 2013."

clear all;

%% Parameter specification:
params.approxFinalNBoxes = 200;                                     %Approximate number of proposals  TODO-Z: Is this a good way to restrict patches to ~100?
params.rSeedForRun = -1;                                            %Random seed to be used (-1 to generate it with a hashing function)
params.q = 10;                                                      %Parameter to eliminate near duplicates (raise it to eliminate more duplicates)

% LAB segmentation
params.segmentations{1}.colorspace = 'LAB';                         %Colorspace: 'RGB', 'LAB', 'opponent', 'rg', 'HSV'
% --> Segmentation parameters:
params.segmentations{1}.superpixels.sigma = 0.8;
params.segmentations{1}.superpixels.c = 100;
params.segmentations{1}.superpixels.min_size = 100;
% --> Parameters trained from VOC07:
%   --> Feature weights:
params.segmentations{1}.simWeights.wBias = 3.0017;
params.segmentations{1}.simWeights.wCommonBorder = -1.0029;
params.segmentations{1}.simWeights.wLABColorHist = -2.6864;
params.segmentations{1}.simWeights.wSizePer = -2.3655;
%   --> Size term alpha, as explained in the paper sec. 4.2. 
%       It is quantized to contain exactly 2^16 elements for speed
%       purposes.
params.segmentations{1}.alpha = dlmread('alpha/alpha_voc07.dat');
params.segmentations{1}.verbose = false;                            %Set to true to display more information during execution

%% Save parameters:
save('rp.mat', 'params');