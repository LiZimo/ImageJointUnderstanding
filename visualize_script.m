%% given 2 images, the patches of both images, and the assignments between the patches, the function will continually
%% show matching patches from both images "howmany" times.  Press enter after each pair of patches
%% to see the next pair of corresponding patches.  The script to call is "visualize_script.m" with 2 image names, im1name and im2name
%% see visualize_patches.m for more info

function visualize_script(im1name, im2name)

image1 = imread(im1name);
image2 = imread(im2name);


[rowsol, cost, cost_matrix, intersection_ratios_im1, intersection_ratios_im2, patches_1, patches_2, ~, ~] =  get_match(im1name, im2name);
visualize_patches(image1, image2, patches_1, patches_2, rowsol, 1000);

end