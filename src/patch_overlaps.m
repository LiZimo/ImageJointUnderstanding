function overlaps = patch_overlaps(patches)
%panos test
%% patches are Nx4 arrays, where N is the number of patches.  Each
%% row contains [xmin ymin xmax ymax] of the patch.  

N = size(patches,1);

%% overlaps is an N x N matrix, where the (i,j)th entry gives: (i intersect j)/(i union j)
overlaps = zeros(N);


parfor i = 1:size(patches,1)
    
    row = zeros(1,N);
    row(i) = 1;
    for j = 1:size(patches,1)
        x1 = patches(i,1);
        y1 = patches(i,2);
        x2 = patches(i,3);
        y2 = patches(i, 4);
        
        x3 = patches(j,1);
        y3 = patches(j,2);
        x4 = patches(j,3);
        y4 = patches(j,4);
        
        
        %% coordinates of intersection are here
        x5 = max(x1, x3);
        y5 = max(y1, y3);
        x6 = min(x2, x4);
        y6 = min(y2, y4);
        
        if x5 >= x6 || y5 >= y6
            row(j) = 0;
        else
           intersection_area = (x6 - x5) * (y6 - y5);
           i_area = (x2 - x1) * (y2 - y1);
           j_area = (x4 - x3) * (y4 - y3);
           
           row(j) = intersection_area/(i_area + j_area - intersection_area);
        end
        
        
        
    end
    overlaps(i,:) = row;
end
end