clr;
gitdir; cd 'ImageJointUnderstanding/src'
%% Load images and off-the-shelf patches.
im1_name = '../data/aeroplane_left_007.jpg';
im2_name = '../data/aeroplane_left_008.jpg';
src      = imread(im1_name);
trg      = imread(im2_name);

params = load('external/rp-master/config/rp.mat');  % Default Params for RP method.
params = params.params;

src_patches = RP(src, params);
trg_patches = RP(trg, params);

%% Extract HOG Feautures and spatial relations between patches.
bin_size    = 32;  % Hog related parameters.
n_orients   = 4;
patch_size  = 128;

src_hog      = get_hog(src_patches, src, bin_size, n_orients, patch_size);
src_overlaps = patch_overlaps(src_patches);

trg_hog      = get_hog(trg_patches, trg, bin_size, n_orients, patch_size);
trg_overlaps = patch_overlaps(trg_patches);


%% Build Affinity matrix which incorporates unary & pairwise patch affinities.
% 1st attempt, full matrix.
ns = size(src_patches, 1);
nt = size(trg_patches, 1);
W  = zeros(ns * nt, ns * nt);

% Hog based similarity (see/discuss plot)
hog_dists = pdist2(src_hog, trg_hog);
med = median(hog_dists(:));
ave = mean(hog_dists(:));
hog_sims = exp(- (hog_dists - med) ./ (2*med^2));
imagesc(hog_sims); colorbar;

%%
t  = 0;
W  = zeros(ns * nt, ns * nt);
for src_i = 1:ns
    for trg_i = 1:nt
        for src_j = 1:ns
            for trg_j = 1:nt 
                W((src_i - 1) * nt + trg_i, (src_j - 1) * nt + trg_j) = hog_sims(src_i, trg_i) + hog_sims(src_j, trg_j) + exp( - abs(src_overlaps(src_i, src_j) - trg_overlaps(trg_i, trg_j)) );
                t = t + 1;                
            end
        end
    end
end
assert(t == numel(W));
imagesc(W);

%% Solve Approximate IQP (Leordaneu Spectral '05)
X = SM(W);
greedyMapping(X, group1, group2);
%% Evaluate Matching



