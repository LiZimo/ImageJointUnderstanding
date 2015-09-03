function [overlaps] = overlap_with_mask(patches, bitmask)
    % Computes for every patch in a collection, the fraction of its area that resides inside a bit mask.
    %
    % Input:    
    %           patches  - (N x 4) N rectangular image patches. Each patch is a 4-dimensional vector describing the (x,y)
    %                      coordinates of the corners of the rectangle. Only the 4 extrema values are given for space
    %                      economy, that is:  [xmin, ymin, xmax, ymax].    
    %
    %           bitmask  - (m x n) binary matrix. Usually positions flagged with 1, correspond to ROI wrt. an image. E.g., 
    %                      they describe a segmentation of an object.
    %     
    % Output:                     
    %           overlaps - (N x 1) vector. overlaps(i) is the fraction of the area of the i-th patch (patches(i))
    %                      in the bitmask.

    
    overlaps = zeros(size(patches,1),1);
    gt_area = sum(bitmask(:));    
    for i = 1:size(patches,1)
        xmin = patches(i,1);
        ymin = patches(i,2);
        xmax = patches(i,3);
        ymax = patches(i,4);
        
        if xmin==xmax || ymin==ymax   % Empty patch.   %TODO-Z: change to && and notice. -> degenerate cases of lines exist.
            overlaps(i) = NaN;       
        else                       
            inter_area  = sum(sum(bitmask(ymin:ymax, xmin:xmax)));            
            overlaps(i) = inter_area / ((1 + xmax - xmin) * (1 + ymax - ymin) + gt_area - inter_area);            
        end
               
    end

    if any(overlaps<0) || any(overlaps>1)
        error('Overlaps outside of [0, 1] range were produced. Please check input.')
    end
end