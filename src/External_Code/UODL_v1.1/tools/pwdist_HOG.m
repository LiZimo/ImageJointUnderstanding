
function M = pwdist_HOG(X1, X2, hog_spec)

% check dimension
ndim_hog = hog_spec.nx * hog_spec.ny * hog_spec.nf;
if size(X1, 1) ~= ndim_hog || size(X2, 1) ~= ndim_hog
	fprintf('ERROR:pwdist_HOG_eLDA - feature dimension mismatched\n');
	M = zeros(0);
	return;
end

% cosine angle as metric
ns1 = sqrt(sum(X1 .* X1, 1));
ns2 = sqrt(sum(X2 .* X2, 1));
ns1(ns1 == 0) = 1;  
ns2(ns2 == 0) = 1;
M = bsxfun(@times, X1' * X2, 1 ./ ns1');
M = bsxfun(@times, M, 1 ./ ns2);

M = M .* -1;