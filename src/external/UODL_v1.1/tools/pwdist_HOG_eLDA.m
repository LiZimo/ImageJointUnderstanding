
function M = pwdist_HOG_eLDA(X1, X2, hog_spec)

% check dimension
ndim_hog = hog_spec.nx * hog_spec.ny * hog_spec.nf;
if size(X1, 1) ~= ndim_hog || size(X2, 1) ~= ndim_hog
	fprintf('ERROR:pwdist_HOG_eLDA - feature dimension mismatched\n');
	M = zeros(0);
	return;
end

% feature whitening: compute S^-1/2*(mu_pos-mu_bg) efficiently
A1 = X1 - repmat(hog_spec.mu_bg, 1, size(X1, 2));
A2 = X2 - repmat(hog_spec.mu_bg, 1, size(X2, 2));
A1 = hog_spec.R' \ A1;
A2 = hog_spec.R' \ A2;

% cosine angle as metric
ns1 = sqrt(sum(A1 .* A1, 1));
ns2 = sqrt(sum(A2 .* A2, 1));
ns1(ns1 == 0) = 1;  
ns2(ns2 == 0) = 1;
M = bsxfun(@times, A1' * A2, 1 ./ ns1');
M = bsxfun(@times, M, 1 ./ ns2);

M = M .* -1;