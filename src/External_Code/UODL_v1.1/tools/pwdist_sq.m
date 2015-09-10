
function M = pwdist_sq(X1, X2)

% check dimension
if size(X1, 1) ~= size(X2, 1)
	fprintf('ERROR:pwdist_sq - feature dimension mismatched\n');
	M = zeros(0);
	return;
end

% calculate pairwise squared Euclidean distance
M = bsxfun(@plus, sum(X1 .* X1, 1)', (-2) * X1' * X2);        
M = bsxfun(@plus, sum(X2 .* X2, 1), M);        
M(M < 0) = 0;                        
