imgsize = 32;
radius = 3;
sigmax = 3.2;
sigmav = 28;

jpegs = dir('/home/zimo/Documents/JointImag/VOC2007/VOC2007_6x2/aeroplane_left/*.jpg');
segmentations = dir('/home/zimo/Documents/JointImag/VOC2007/SegmentationClass/*.png');

corlocs = zeros(length(segmentations), 4);
for i = 1:length(segmentations);
    
    image_name = jpegs(i).name;
    try ground_truth = imread(strcat('/home/zimo/Documents/JointImag/VOC2007/SegmentationClass/', image_name(1:end-4),'.png'));
    catch continue
    end
    img = imresize(imread(strcat('/home/zimo/Documents/JointImag/VOC2007/VOC2007_6x2/aeroplane_left/',image_name(1:end-4), '.jpg')),[imgsize NaN]);

    
    ground_truth = double(imresize(ground_truth, [imgsize NaN]));

    ground_truth(ground_truth~=0) = 1;
    gt_vec = reshape(ground_truth, 1, []);
    

    tic;
    fprintf('Calculating graph laplacian...\n');
    [lplcn, D_half] = ICS_laplacian_nf(img, radius, 0, 3.2, 28);
    fprintf('Done \n');
    toc;
    
    
    fprintf('Calculating eigenvectors...\n');
    tic;
    [v,d] = eigs(lplcn, 32, 1e-20);
    fprintf('Done \n');
    toc;

    seg_proj_coeff = gt_vec*v;
    seg_proj = v*seg_proj_coeff';
    
    r = img(:,:,1);
    g = img(:,:,2);
    b = img(:,:,3);
    
    r_proj_coeff = double(reshape(r,1,[])) * v;
    g_proj_coeff = double(reshape(g,1,[])) * v;
    b_proj_coeff = double(reshape(b,1,[])) * v;
    
    r_proj = v*r_proj_coeff';
    g_proj = v*g_proj_coeff';
    b_proj = v*b_proj_coeff';
    
    rgb_proj = zeros(size(img));
    rgb_proj(:,:,1) = reshape(r_proj, size(img,1), []);
    rgb_proj(:,:,2) = reshape(g_proj, size(img,1), []);
    rgb_proj(:,:,3) = reshape(b_proj, size(img,1), []);
    
    seg_projim = reshape(seg_proj, [size(img,1) size(img,2)]);
    
    
    %% finding the threshold
    fprintf('finding best threshold...\n');
    tic;
    cand_threshs = linspace(min(seg_proj),max(seg_proj), 1000);
    cand_projs = zeros(1000, length(seg_proj));
    scores = zeros(1,1000);
    parfor j = 1:1000
        newproj = seg_proj;
        newproj(newproj<cand_threshs(j)) = 0;
        newproj(newproj>cand_threshs(j)) = 1;
     
        
        ncut_score = (newproj'*lplcn*newproj)/(newproj'*diag(diag(lplcn))*newproj) + ...
            (newproj'*lplcn*newproj)/(~newproj'*diag(diag(lplcn))*~newproj);
        scores(j) = ncut_score;
        
        cand_projs(j,:) = newproj;
    end
    toc;
    fprintf('Done \n');
    
    [~,best_ind] = min(scores);
    best_proj = cand_projs(best_ind,:);

    seg_projim1 = reshape(best_proj, [size(img,1) size(img,2)]);
    
    frst_eig = (v(:,1) - min(v(:,1)))/(max(v(:,1)) - min(v(:,1)));
    frst_eig = reshape(frst_eig, [size(img,1) size(img,2)]);
    scnd_eig = (v(:,2) - min(v(:,2)))/(max(v(:,2)) - min(v(:,2)));
    scnd_eig = reshape(scnd_eig, [size(img,1) size(img,2)]);
    thrd_eig = (v(:,3) - min(v(:,3)))/(max(v(:,3)) - min(v(:,3)));
    thrd_eig = reshape(thrd_eig, [size(img,1) size(img,2)]);
    
%     err = norm(projim1 - ground_truth);
%     picnorm = norm(ground_truth);

    intersection = sum(seg_projim1(ground_truth==1));
    union = sum(seg_projim1(ground_truth==0)) + sum(ground_truth(:));
    corloc = intersection/union;
    
    
    diff = double(img) - rgb_proj;
    diff = diff(:);
    rgb_proj_err = norm(diff);
    
   total_norm = (norm(double(img(:)) + norm(rgb_proj(:))));
    
    
    
    h = figure;
   
    set(h,'Visible', 'on', 'name','hi','numbertitle','off') 
   
    subplot(3,3,1:3);
    imshow(img);
    title('Original Image','FontSize', 7.5);
    
    subplot(3,3,4);
    imshow(ground_truth);
    title('Ground truth Segmentation','FontSize', 7.5);
    
    subplot(3,3,5);
    imshow(seg_projim);
    title('Ground Truth projected into eigenspace','FontSize', 7.5);
    
    subplot(3,3,6);
    imshow(seg_projim1);
    title(num2str(corloc),'FontSize', 7.5);
    
    subplot(3,3,7);
    imshow(rgb_proj/255);
    title(strcat(num2str(rgb_proj_err/total_norm)),'FontSize', 7.5);
    
%     subplot(3,3,7);
%     title('first eigenvalue of laplacian');
%     imshow(frst_eig);
%     
%     subplot(3,3,8);
%     title('second eigenvalue of laplacian');
%     imshow(scnd_eig);
%     
%     subplot(3,3,9);
%     title('third eigenvalue of laplacian');
%     imshow(thrd_eig);

    x = input('next image \n');
    
end
