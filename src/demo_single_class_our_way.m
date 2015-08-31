clr;
gitdir; 
cd 'ImageJointUnderstanding/src'
%%
foldername = '../data/input/ObjectDiscoveryDataset/Airplane100';
images     = load_images(foldername, 'jpg');

%%
total_images = 20;
images       = images(:,:,:,1:total_images);

%%
k_neighbors = 1;
[gist_descriptors, gist_nn] = get_gist_nn(images, k_neighbors);

%% Partition each image into tiles.
grid_dim = [20, 20];                                                        % Image will be partioned in grid_dim tiles.

%% Extract BOW-feature.

bow_dict    = load('/Users/optas/Dropbox/matlab_projects/Image_Graphs/data/Centers_MSRC');
bow_dict    = bow_dict.Centers;

bow_feats   = cell(1); 
for i=1:total_images    
    [F, ~]       = bag_of_words(images(:,:,:,i), bow_dict, grid_dim(1), grid_dim(2));  % Extract Bag Of Word Features
    bow_feats{i} = F;
end

%%
save('../data/output/aeroplane_first_20_bow_feats_100_100_grid', 'bow_feats')
%%

grid_graph = simple_graphs('grid', grid_dim(1), grid_dim(2));



%%
F
pd1 = pdist(F1);
pd1 = squareform(pd1);
pd1 = exp(-pd1);
pd1 = pd1 .* grid_graph;

pd2 = pdist(F2);
pd2 = squareform(pd2);
pd2 = exp(-pd2);
pd2 = pd2 .* grid_graph;








%%

%%%%%%%%%%% Now get Hog features too%%%%%%%%%%%%%%
bin_size   = 32;
n_orients  = 4;
patch_size = 128;

hog_size = (patch_size/bin_size)^2 * 4 * n_orients;

Hogs = zeros(Nimages, hog_size);
for j = 1:Nimages

H1 = hog(images(:,:,:,i), bin_size, n_orients);
H1 = reshape(H1, [hog_size,1]);

Hogs(j,:) = H1;
end



