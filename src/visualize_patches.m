function visualize_patches(image1, image2, patches1, patches2, assignment_mat, howmany)
%% given 2 images, the patches of both images, and the assignments between the patches, the function will continually
%% show matching patches from both images "howmany" times.  Press enter after each pair of patches
%% to see the next pair of corresponding patches.  The script to call is "visualize_script.m" with 2 image names.

    close all;
    shapeInserter = vision.ShapeInserter('LineWidth', 4);

    for i=1:howmany

    close all;

    N = size(patches1,1)
    which_patch = randi([1 N])
    matching_patch = assignment_mat(which_patch);


    x1 = patches1(which_patch, 1);
    y1 = patches1(which_patch, 2);
    x2 = patches1(which_patch, 3);
    y2 = patches1(which_patch, 4);

    x3 = patches2(matching_patch,1);
    y3 = patches2(matching_patch,2);
    x4 = patches2(matching_patch,3);
    y4 = patches2(matching_patch,4);


    rec1 = int32([x1 y1 (x2 - x1) (y2 - y1)]);
    rec2 = int32([x3 y3 (x4 - x3) (y4- y3)]);

    im1_out = step(shapeInserter, image1, rec1);
    im2_out = step(shapeInserter, image2, rec2);


    subplot(1,2,1), subimage(im1_out);
    subplot(1,2,2), subimage(im2_out);

    input('press enter');

    end



end 