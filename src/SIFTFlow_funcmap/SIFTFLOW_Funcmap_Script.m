%% A big unruly script to visualize the output of the 
%% func_map optimization over sift correspondences


%% ===== Set up Parameters: section 1 =====%

fprintf('Section 1: Setting up Parameters ... \n');
imgsize = 64;
sigmax = sqrt(2)*imgsize;
sigmav = 20;
radius = 2;

cellsize=3;
gridspacing=1;
SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;

num_eigenvecs = 64;

fprintf('Finished Section 1 \n');


%% =========== Section 2: Load Images, compute Laplacian basis, and proposal_correspondences : section 2================%
fprintf('Section 2: Loading images, computing Laplacian basis and correspondences... \n');


% here, we load a specific directory of images to optimize funcmaps over.  
% You can change "images" and "segs" to any directories of images
% with corresponding ground truth segmentations

classname = 'cow';
images = dir(['/home/zimo/Documents/dense_functional_map_matching/data/' classname '/*.bmp']);
segs = dir(['/home/zimo/Documents/dense_functional_map_matching/data/' classname '/GroundTruth/*.bmp']);

% p designates for how many pairs for the script to run.  Which pair of images is determined at random
for p = 1:10

z = randi([1 length(images)]);
y = randi([1 length(images)]);
        
im1_whole = imread(['/home/zimo/Documents/dense_functional_map_matching/data/' classname '/' images(z).name]);
im2_whole = imread(['/home/zimo/Documents/dense_functional_map_matching/data/' classname '/' images(y).name]);
seg1_whole = imread(['/home/zimo/Documents/dense_functional_map_matching/data/' classname '/GroundTruth/' images(z).name]);
seg2_whole = imread(['/home/zimo/Documents/dense_functional_map_matching/data/' classname '/GroundTruth/' images(y).name]);
im1 = imresize(im1_whole, [imgsize imgsize]);
im2 = imresize(im2_whole, [imgsize imgsize]);
seg1 = imresize(seg1_whole, [imgsize imgsize]);
seg2 = imresize(seg2_whole, [imgsize imgsize]);


fprintf('Computing Laplacian of Image 1 ... \n');
tic; [laplcn1, D_half1] = image_laplacian(im1, radius, sigmax, sigmav); toc;
fprintf('Done \n');
fprintf('Computing Laplacian of Image 2 ... \n');
tic; [laplcn2, D_half2] = image_laplacian(im2, radius, sigmax, sigmav); toc;
fprintf('Done \n');


fprintf('Computing Eigenvalues of Laplacian for image 1 ... \n');
tic; [eig_vecs1, eig_vals1] = eigs(laplcn1, num_eigenvecs, 1e-20); toc;
fprintf('Done \n');
fprintf('Computing Eigenvalues of Laplacian for image 2 ... \n');
tic; [eig_vecs2, eig_vals2] = eigs(laplcn2, num_eigenvecs, 1e-20); toc;
fprintf('Done \n');


fprintf('Computing correspondences ... \n');
tic;
[C, D] = get_sift_correspondences(im1, im2, SIFTflowpara, cellsize,gridspacing);
toc;
fprintf('Done \n');
fprintf('Finished Section 2 \n');

%% Section 3: solve for the change of basis matrix row by row

fprintf('Section 3: Starting Quadratic Program to optimize Functional Map \n');

img1_projected_indicators = normalize_columns(eig_vecs1'* C);
img2_projected_indicators = normalize_columns(eig_vecs2'* D);


% set some parameters.  "Mu" is coefficient in front of ||X*eigs1 -eigs2*X||
% sig is the "sigma squared" inside "zimo.pdf" to update the weights
% lambda correspond to the term "lambda*(alpha_c - 1)^2", also in zimo.pdf%
% these defaults work decently well

num_iters = 10;
mu = 10000;
lambda = 10;
sig = 1;

% next initialize weights and alphas
weights = eye(size(C,2));
alphas = eye(size(C,2));
All_X = zeros(num_iters, num_eigenvecs, num_eigenvecs);
All_W = zeros(num_iters, size(weights,1));
All_A = zeros(size(All_W));

% here is where the optimization is happening
for i = 1:num_iters;

X = update_X(weights, mu, alphas, img1_projected_indicators, img2_projected_indicators, eig_vals1, eig_vals2);
alphas = update_alpha(weights, lambda, X, img1_projected_indicators, img2_projected_indicators);
weights =  update_weights(X, sig, img1_projected_indicators, img2_projected_indicators, alphas);

All_X(i,:,:) = X;
All_W(i,:) = diag(weights);
All_A(i,:) = diag(alphas);

fprintf('finished iteration %d \n', i);
end

fprintf('Recording changes \n');

% we record the change in norm of the weights, the alphas, and functional map between iterations

changes_X = zeros(1,num_iters-1);
changes_W = zeros(1, num_iters-1);
changes_A = zeros(1, num_iters - 1);
for iters = 1:num_iters-1
    changes_X(iters) = norm(squeeze(All_X(iters+1,:,:)) - squeeze(All_X(iters,:,:)));
    changes_W(iters) = norm(squeeze(All_W(iters+1,:)) - squeeze(All_W(iters,:)));
    changes_A(iters) = norm(squeeze(All_A(iters+1,:)) - squeeze(All_A(iters,:)));
end
fprintf('Done \n');
fprintf('Finished Section 3 \n');
%% section 4: compute the best pixel correspondences based on weights

fprintf('Section 4: marking best correspondences \n');
% these next little bits find the best pixel-correspondences of the optimziation, according
% to the final weights of the optimization.  The final output are images,
% 'best_im' and 'worst_im', show the best pixel-wise and worst pixel-wise
% correspondences, respectively, as two images.  
% these two images get passed into the final figure below
best_indices = find_good_bad_correspondences(C,D,All_W(num_iters,:),10, imgsize, 'good');
worst_indices = find_good_bad_correspondences(C,D,All_W(num_iters,:),10, imgsize, 'bad');
best_corres_fig = draw_lines (best_indices, im1, im2);
worst_corres_fig = draw_lines (worst_indices, im1, im2);
best = getframe(best_corres_fig);
worst = getframe(worst_corres_fig);
[best_im, ~] = frame2im(best);
[worst_im, ~] = frame2im(worst);
fprintf('Finished Section 4 \n');

%% Section 5: Project gt_segmentation onto basis, send it through the f-map, and create the final figure to visualize everything
% I project 3 channels here so you can visualize the rgb projection of the
% original image if you like.  It is convenient that the gt_segmentation of
% image 1, "seg1" has three identical channels for the MSRC
% dataset, so the code can be recycled for this dataset
% 


fprintf('Section 5: making figures...\n');

h = figure;
set(h,'Visible', 'on', 'name','hi','numbertitle','off') 

F = squeeze(All_X(num_iters,:,:));


r = seg1(:,:,1);
g = seg1(:,:,2);
b = seg1(:,:,3);
    
r_proj_coeff = double(reshape(r,1,[])) * eig_vecs1;
g_proj_coeff = double(reshape(g,1,[])) * eig_vecs1;
b_proj_coeff = double(reshape(b,1,[])) * eig_vecs1;

r_proj = eig_vecs1*r_proj_coeff';
g_proj = eig_vecs1*g_proj_coeff';
b_proj = eig_vecs1*b_proj_coeff';
rgb_proj = zeros(size(seg1));

rgb_proj(:,:,1) = reshape(r_proj, size(seg1,1), []);
rgb_proj(:,:,2) = reshape(g_proj, size(seg1,1), []);
rgb_proj(:,:,3) = reshape(b_proj, size(seg1,1), []);

Fr = F*r_proj_coeff';
Fg = F*g_proj_coeff';
Fb = F*b_proj_coeff';

newR = eig_vecs2 * Fr;
newG = eig_vecs2 * Fg;
newB = eig_vecs2 * Fb;

newR = (newR - min(newR))/(max(newR) - min(newR));
newG = (newG - min(newG))/(max(newG) - min(newG));
newB = (newB - min(newB))/(max(newB) - min(newB));


mapped_proj = zeros(imgsize, imgsize, 3);
mapped_proj(:,:,1) = reshape(newR, imgsize, []);
mapped_proj(:,:,2) = reshape(newG, imgsize, []);
mapped_proj(:,:,3) = reshape(newB, imgsize, []);


subplot(5,4,1)
imshow(im1);
title('Original Source Image', 'FontSize', 7.5);

subplot(5,4,2)
imshow(im2)
title('Original Target Image', 'FontSize', 7.5);

s1 = subplot(5,4,3);
imshow(best_im);
title('Best Correspondences with final weights', 'FontSize', 7.5);

s2 = subplot(5,4,4);
imshow(worst_im);
title('worst Correspondences with final weights', 'FontSize', 7.5);

subplot(5,4,5)
imshow(seg1);
title('GT Segmentation of img1', 'FontSize', 7.5);

subplot(5,4,6)
imshow(seg2);
title('GT Segmentation of img2', 'FontSize', 7.5);

subplot(5,4,7)
imshow(rgb_proj/255);
title('Projected in Original Basis', 'FontSize', 7.5);

subplot(5,4,8)
imshow(mapped_proj)
title('After transfer across F-map', 'FontSize', 7.5);

colormap('hot');

subplot(5,4,9)
plot(changes_X);
title('Changes in norm of Fmap through iterations', 'FontSize', 7.5);
subplot(5,4,10)
imagesc(squeeze(All_X(1,:,:)));
title('Visualization of F-map First', 'FontSize', 7.5);
subplot(5,4,11)
imagesc(squeeze(All_X(round(num_iters/2),:,:)));
title('Visualization of F-map Middle', 'FontSize', 7.5);
subplot(5,4,12)
imagesc(squeeze(All_X(num_iters,:,:)));
title('Visualization of F-map Last', 'FontSize', 7.5);

subplot(5,4,13)
plot(changes_W);
title('Changes in norm of weights through iterations', 'FontSize', 7.5);
subplot(5,4,14)
imagesc(squeeze(All_W(1,:,:)));
title('Visualization of weights First', 'FontSize', 7.5);
subplot(5,4,15)
imagesc(squeeze(All_W(round(num_iters/2),:,:)));
title('Visualization of weights Middle', 'FontSize', 7.5);
subplot(5,4,16)
imagesc(squeeze(All_W(num_iters,:,:)));
title('Visualization of weights Last', 'FontSize', 7.5);

subplot(5,4,17)
plot(changes_A);
title('Changes in norm of alphas through iterations', 'FontSize', 7.5);
subplot(5,4,18)
imagesc(squeeze(All_A(1,:,:)));
title('Visualization of alphas First', 'FontSize', 7.5);
subplot(5,4,19)
imagesc(squeeze(All_A(round(num_iters/2),:,:)));
title('Visualization of alphas Middle', 'FontSize', 7.5);
subplot(5,4,20)
imagesc(squeeze(All_A(num_iters,:,:)));
title('Visualization of alphas Last', 'FontSize', 7.5);

colorbar;

%saveas(h, ['../figs/' images(z).name '_' images(y).name '_sigma1000.jpg']);
input('Press Enter for next pair to be run \n');
end

