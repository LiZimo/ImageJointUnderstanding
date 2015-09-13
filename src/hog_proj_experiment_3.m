imgsize = 128;

eigs_dir = dir('/home/zimo/Documents/JointImag/eigs_horse/*.mat');
jpegs = dir('/home/zimo/Documents/JointImag/VOC2007/VOC2007_6x2/horse_right/*.jpg');
segmentations = dir('/home/zimo/Documents/JointImag/VOC2007/SegmentationClass/*.png');
all_dists = {};
index = 1;
for i = 1:length(jpegs);
    
    image_name1 = jpegs(i).name;
     try ground_truth1 = imread(strcat('/home/zimo/Documents/JointImag/VOC2007/SegmentationClass/', image_name1(1:end-4),'.png'));
     catch
     continue;
     end
     
     while 1 == 1
        j = randi([1 length(jpegs)]);
        if j == i
            continue;
        end
     
        image_name2 = jpegs(j).name;
        try 
            ground_truth2 = imread(strcat('/home/zimo/Documents/JointImag/VOC2007/SegmentationClass/', image_name2(1:end-4),'.png'));
            fprintf('found 1');
        break;
        catch
            continue;
        end
     
     end
    
    distances = zeros(3,6); %% first row for hog distances, second row for coeff distances
     
    img1 = imresize(imread(strcat('/home/zimo/Documents/JointImag/VOC2007/VOC2007_6x2/horse_right/',image_name1(1:end-4), '.jpg')),[imgsize NaN]);
    img2 = imresize(imread(strcat('/home/zimo/Documents/JointImag/VOC2007/VOC2007_6x2/horse_right/',image_name2(1:end-4), '.jpg')),[imgsize NaN]);
    
    ground_truth1 = double(imresize(ground_truth1, [imgsize NaN]));
    ground_truth2 = double(imresize(ground_truth2, [imgsize NaN]));
    
    corners1 = gt_box(ground_truth1);
    corners2 = gt_box(ground_truth2);
    
    if get_area(corners2) > 0.2 * size(img2,1)*size(img2,2)
        corners2 = get_sub_box(corners2, 0.2);
    end
    
    
    img_patch1 = img1(corners1(2):corners1(4), corners1(1):corners1(3),:);
    img_patch2 = img2(corners2(2):corners2(4), corners2(1):corners2(3),:);
    hog_feats1 = extractHOGFeatures(imresize(img_patch1, [256 256]));
    hog_feats2 = extractHOGFeatures(imresize(img_patch2, [256 256]));
    
    hog_img1 = faceFeatures(img1, {'hog'});
    hog_img2 = faceFeatures(img2, {'hog'});
    
    filename1 = strcat('eigs_horse/',image_name1, '_', '64_', 'basis.mat');
    filename2 = strcat('eigs_horse/',image_name2, '_', '64_', 'basis.mat');
    basis1 = load(filename1, 'v');
    basis2 = load(filename2, 'v');
    basis1 = basis1.v;
    basis2 = basis2.v;
    
    hog_patch1 = zeros(size(hog_img1));
    hog_patch2 = zeros(size(hog_img2));
    
    hog_patch1(corners1(2):corners1(4), corners1(1):corners1(3),:) = hog_img1(corners1(2):corners1(4), corners1(1):corners1(3),:);
    hog_patch2(corners2(2):corners2(4), corners2(1):corners2(3),:) = hog_img2(corners2(2):corners2(4), corners2(1):corners2(3),:);
    hog_patch2_tile = tile_around(hog_patch2, corners2);
    
    vec_hog_patch1 = squeeze(reshape(hog_patch1, 1, [], size(hog_patch1,3)))';   
    vec_hog_patch2 = squeeze(reshape(hog_patch2, 1, [], size(hog_patch2,3)))';
    vec_hog_patch2_tile = squeeze(reshape(hog_patch2_tile, 1, [], size(hog_patch2,3)))';
    
    
    projec_coeffs1 = vec_hog_patch1 * basis1;
    projec_coeffs2 = vec_hog_patch2 * basis2;
    projec_coeffs2_tile = vec_hog_patch2_tile * basis2;
    
    projec_distance_gt = norm(projec_coeffs1 - projec_coeffs2);
    projec_distance_gt_tile = norm(projec_coeffs1 - projec_coeffs2_tile);
    hog_distance_gt = norm(hog_feats1 - hog_feats2);
    
    distances(1,1) = hog_distance_gt;
    distances(2,1) = projec_distance_gt;
    distances(3,1) = projec_distance_gt_tile;
    
    for k = 2:6
        
    corners2_rnd_shift = box_shift(corners2, size(img2,1), size(img2,2));
    if get_area(corners2_rnd_shift) > 0.2 * size(img2,1)*size(img2,2)
        corners2_rnd_shift = get_sub_box(corners2_rnd_shift, 0.2);
    end
    
    
    img2_patch_shift = img2(corners2_rnd_shift(2):corners2_rnd_shift(4), corners2_rnd_shift(1):corners2_rnd_shift(3),:);
    hog_feats2_shift = extractHOGFeatures(imresize(img2_patch_shift, [256 256]));
    
    
    hog_patch2_shift = zeros(size(hog_img2));
    hog_patch2_shift(corners2_rnd_shift(2):corners2_rnd_shift(4), corners2_rnd_shift(1):corners2_rnd_shift(3),:) = hog_img2(corners2_rnd_shift(2):corners2_rnd_shift(4), corners2_rnd_shift(1):corners2_rnd_shift(3),:);    
    hog_patch2_shift_tile = tile_around(hog_patch2_shift, corners2_rnd_shift);
    
    vec_hog_patch2_shift = squeeze(reshape(hog_patch2_shift, 1, [], size(hog_patch2_shift,3)))';
    vec_hog_patch2_shift_tile = squeeze(reshape(hog_patch2_shift_tile, 1, [], size(hog_patch2,3)))';
    
    projec_coeffs2_shift= vec_hog_patch2_shift * basis2;
    projec_coeffs2_shift_tile = vec_hog_patch2_shift_tile * basis2;
    
    projec_distance_shift = norm(projec_coeffs1 - projec_coeffs2_shift);
    projec_distance_shift_tile = norm(projec_coeffs1 - projec_coeffs2_shift_tile);
    hog_distance_shift = norm(hog_feats1 - hog_feats2_shift);
    
    
    distances(1,k) = hog_distance_shift;
    distances(2,k) = projec_distance_shift;
    distances(3,k) = projec_distance_shift_tile;
    
    %input('hi');
    end
    all_dists{index} = distances;
    index = index + 1;
end
