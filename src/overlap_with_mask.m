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

    for i = 1:size(patches,1)
        xmin = patches(i,1);
        ymin = patches(i,2);
        xmax = patches(i,3);
        ymax = patches(i,4);
        
        if xmin==xmax || ymin==ymax   % Empty patch.   %TODO-Z: change to && and notice. -> degenerate cases of lines exist.
            overlaps(i) = 0;       
        else                       
            gt_patch    = bitmask(ymin:ymax, xmin:xmax); % When referencing the bitmask, the x and y axis, are reversed.                        
            overlaps(i) = sum(gt_patch(:)) / ((xmax +1 - xmin) * (ymax +1 - ymin));            
        end
               
    end

    if any(overlaps<0) || any(overlaps>1)
        error('Overlaps outside of [0, 1] range were produced. Please check input.')
    end
end