function best_indices = find_good_bad_correspondences(C,D,W,howmany, imgsize, goodorbad)



[sorted_W, sorted_w_inds] = sort(W);

if strcmp(goodorbad, 'good')   
    best = sorted_w_inds(1:howmany);
end

if strcmp(goodorbad, 'bad')   
    best = sorted_w_inds(end-howmany+1:end);
end


best_starts = C(:,best);
best_ends = D(:,best);


best_indices = zeros(howmany, 4);
for i = 1:howmany
   indicator_start = best_starts(:,i);
   start_reshaped_to_2d = reshape(indicator_start, [imgsize imgsize]);
   [row, col] = find(start_reshaped_to_2d);
   best_indices(i,1:2) = [row, col];
   
   indicator_end = best_ends(:,i);
   end_reshaped_to_2d = reshape(indicator_end, [imgsize imgsize]);
   [row, col] = find(end_reshaped_to_2d);
   best_indices(i,3:4) = [row, col];
end
end