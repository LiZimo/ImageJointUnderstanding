function [ match score ] = makeConfidentMatches_greedy( confidenceMap, nBest )
if nargin < 2
    nBest = Inf;
end

match = []; score = [];
[ max_value max_ind ] = max(confidenceMap(:) );
k = 0;

while max_value > 0 && k < nBest
    [ max_row max_col ] = ind2sub( size(confidenceMap), max_ind );
    cur_match = [ max_row; max_col ]; 
    confidenceMap(cur_match(1),:) = 0;
    confidenceMap(:,cur_match(2)) = 0;
    match = [ match cur_match ];
    score = [ score max_value ];
    k = k + 1;
    [ max_value max_ind ] = max(confidenceMap(:) );
end
