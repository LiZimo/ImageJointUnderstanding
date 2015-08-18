function overlap_ratios= GT_overlap(patches, groundTruth)
%% patches is an Nx4 array of patch proposals from the file "imname"
%% image is the image from which the patches come from
%% groundTruth is the ground-truth segmentation of the image as a binary mask

overlap_ratios = zeros(size(patches,1),1);


parfor i = 1:size(patches,1)
    xmin = patches(i,1);
    ymin = patches(i,2);
    xmax = patches(i,3);
    ymax = patches(i,4);
    
    gt_patch = groundTruth(ymin:ymax,xmin:xmax);
    
    overlap_sum = sum(gt_patch(:));
    
    ratio = overlap_sum/ ((xmax-xmin)*(ymax-ymin));
    overlap_ratios(i) = ratio;



end