function corners = gt_box(ground_truth_mask)

xmin = min(find(logical(sum(ground_truth_mask))));
xmax = max(find(logical(sum(ground_truth_mask))));

ymin = min(find(logical(sum(ground_truth_mask'))));
ymax = max(find(logical(sum(ground_truth_mask'))));

corners = [xmin ymin xmax ymax];
end