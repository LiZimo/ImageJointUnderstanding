function [Laplacian_n, superpixels, eigenvectors, eigenvalues] = compute_superpixel_basis(img)


%% first get the superpixels
[labels, num] = slicmex(img, 200, 8); %% first parameter is number of superpixels, second parameter is how "square" the superpixels are.  Higher means more square

labels = labels + 1; % the smallest region is indexed by 0, but we want it to be 1
superpixels = labels;

%% next calculate 2 adjacency matrices of the superpixels: one for 
%% boundary length and one for average intensity.  We multiply
%% these together for the final weights of hte laplacian
adj_mat_boundary = adj_from_superpixels(labels, 'boundary');


adj_mat_boundary = adj_mat_boundary/max(adj_mat_boundary(:));
adj_mat_intensity = adj_from_superpixels(labels, 'intensity', img);
sigma_bnd = median(adj_mat_boundary(adj_mat_boundary~=0)); %% sigma vales are the medians of the non zero values of these two adjacency matrices
sigma_intns = median(adj_mat_intensity(adj_mat_intensity~=0));

%========================== change the values of the adjacency matrix to be gaussians of the
%non-zero values.  Zero-valued weights remain zero
adj_mat_bnd_exp = exp(adj_mat_boundary^2/sigma_bnd);
adj_mat_bnd_exp(adj_mat_boundary == 0) = 0;
adj_mat_intns_exp = exp(-adj_mat_intensity/sigma_intns);
adj_mat_intns_exp(adj_mat_intensity == 0) = 0;
adj_mat_whole = adj_mat_intns_exp .* adj_mat_bnd_exp;

%========Calculate normalized laplacian from the adjacency============================================
Diagonal = -diag(sum(adj_mat_whole));
d = diag(Diagonal);
D_neghalf = diag(1./sqrt(d));
Laplacian = Diagonal - adj_mat_whole;
Laplacian_n = D_neghalf * Laplacian * D_neghalf;


%% calculate eignvectors and values
[eigenvectors, eigenvalues] = eigs(Laplacian_n, 5, 1e-40);

end
