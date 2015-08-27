clr;
gitdir; 
cd 'ImageJointUnderstanding/src'

%% Load images and off-the-shelf patches.

im1_file = '../data/input/ObjectDiscoveryDataset/Airplane100/0018.jpg';
gt1_file = '../data/input/ObjectDiscoveryDataset/Airplane100/GroundTruth/0018.png';
im2_file = '../data/input/ObjectDiscoveryDataset/Airplane100/0026.jpg';
gt2_file = '../data/input/ObjectDiscoveryDataset/Airplane100/GroundTruth/0026.png';

src      = imread(im1_file);
src_gt   = imread(gt1_file);

trg      = imread(im2_file);
trg_gt   = imread(gt2_file);

params = load('external/rp-master/config/rp.mat');  % Default Params for RP method.
params = params.params;

src_patches = RP(src, params);
trg_patches = RP(trg, params);

%%
clc
p1 = Patch(src, src_patches(1,:));
p1.plot()

%% Extract HOG Feautures and spatial relations between patches.
bin_size    = 32;  % Hog related parameters.
n_orients   = 4;
patch_size  = 128;

src_hog      = get_hog(src_patches, src, bin_size, n_orients, patch_size);
src_overlaps = patch_overlaps(src_patches);

trg_hog      = get_hog(trg_patches, trg, bin_size, n_orients, patch_size);
trg_overlaps = patch_overlaps(trg_patches);


%%
%% Build Affinity matrix which incorporates unary & pairwise patch affinities.
% 1st attempt, full matrix.
ns = size(src_patches, 1);
nt = size(trg_patches, 1);
W  = zeros(ns * nt, ns * nt);

% Hog based similarity (see/discuss plot)
hog_dists = pdist2(src_hog, trg_hog);
med = median(hog_dists(:));
ave = mean(hog_dists(:));
% hog_sims = exp(- (hog_dists - med) ./ (2*med^2));
hog_sims = exp(- (hog_dists).^2 ./ (2*med^2));
imagesc(hog_sims); colorbar;

%%
t = 0;
for src_i = 1:ns
    for trg_i = 1:nt
        for src_j = 1:ns
            for trg_j = 1:nt 
                
                if src_overlaps(src_i, src_j) == 0 && trg_overlaps(trg_i, trg_j) == 0           % if there is not overlap in both pairs, disregard spatial info.
                    W((src_i - 1) * nt + trg_i, (src_j - 1) * nt + trg_j) = hog_sims(src_i, trg_i) + hog_sims(src_j, trg_j);
                else
                    W((src_i - 1) * nt + trg_i, (src_j - 1) * nt + trg_j) = hog_sims(src_i, trg_i) + hog_sims(src_j, trg_j) + exp( - abs(src_overlaps(src_i, src_j) - trg_overlaps(trg_i, trg_j))^2 );
                end
                                
                t = t + 1;                
                
            end
        end
    end
end
assert(t == numel(W));
imagesc(W);
% hist(W(:));

%% Solve Approximate IQP (Leordaneu Spectral '05)

X                   = SM(W);
E12                 = ones(ns, nt);
[L12(:,1) L12(:,2)] = find(E12);
[group1 group2]     = make_group12(L12);
A                   = greedyMapping(X, group1, group2);

% %% Solve with RRWM
% tic
% X                   = RRWM(W, group1, group2);
% E12                 = ones(ns, nt);
% [L12(:,1) L12(:,2)] = find(E12);
% [group1 group2]     = make_group12(L12);
% A                   = greedyMapping(X, group1, group2);
% toc

%% Evaluate Matching
score           = A' * W * A             % Attained value of objective function.
[correspondence(:,1), correspondence(:,2)] = find(reshape(A, ns, nt));

linearInd = sub2ind([ns, nt], correspondence(:,1), correspondence(:,2));
%%
% Plot resulting binary matrix
corresponde_matrix = zeros(ns, nt);
corresponde_matrix(linearInd ) = 1
imagesc(corresponde_matrix)

%%
from_overlaps = overlap_with_mask(src_patches(from, :), src_gt);
to_overlaps   = overlap_with_mask(trg_patches(to, :), trg_gt);
sum(abs(from_overlaps - to_overlaps))


%% Matching based only on unitary costs. HOG discrepancy.
[x_src_trg, cost] = lapjv(hog_dists);
%%
from_overlaps = overlap_with_mask(trg_patches(x_src_trg, :), src_gt)
sum(abs(from_overlaps - to_overlaps))

