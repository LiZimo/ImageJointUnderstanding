function [ feat ] = extract_segfeat_hog(img, seg)
%% extract hog features from segments

% initialize structs
feat = struct;

% compute HOG features
szCell = 8;
nX=8; nY=8;
nDim = nX*nY*31;
hist_temp = zeros(size(seg.coords,1), nDim);
%im_patch_pad = ones(szCell*(nY+2),szCell*(nX+2),3);
%load('./who2/bg11.mat');

pixels = double([nY nX] * szCell);
cropsize = ([nY nX]+2) * szCell;
% minsize

heights = double(seg.coords(:,3) - seg.coords(:,1) + 1);
widths = double(seg.coords(:,4) - seg.coords(:,2) + 1);
box_rects = [ seg.coords(:,1:2) heights widths ];

% loop through boxes
% suha: remove the "if 0" routine, clear hog variables, 20150320
for j = 1:size(hist_temp,1)    
    %img_patch = imresize(imcrop(img, box_rect), [szCell*nY szCell*nX]);
    %img_patch_pad(szCell+1:end-szCell,szCell+1:end-szCell,:) = img_patch;
    %img_patch = imresize(imcrop(img, box_rects(j,:)), [szCell*(nY+2) szCell*(nX+2)]);

    % padding
    padx = szCell * widths(j) / pixels(2);
    pady = szCell * heights(j) / pixels(1);
    x1 = round(double(seg.coords(j,1))-padx);
    x2 = round(double(seg.coords(j,3))+padx);
    y1 = round(double(seg.coords(j,2))-pady);
    y2 = round(double(seg.coords(j,4))+pady);
    %  pos(i).y1
    window = subarray(img, y1, y2, x1, x2, 1);
    img_patch = imresize(window, cropsize, 'bilinear');
    
    hog = features(double(img_patch), szCell);
    hog_ = hog(:,:,1:end-1);
    hist_temp(j,:) = hog_(:)';
    clear hog;
    clear hog_;
end

% add to feat
%feat.hist = sparse(hist_temp);
% suha: type-casting, 20150320
feat.hist = cast(hist_temp, 'single');
feat.boxes = cast(seg.coords, 'single');

% suha: store image size only, 20141025
feat.imsize = [size(img, 2), size(img, 1)];% feat.img = img; 
        

function B = subarray(A, i1, i2, j1, j2, pad)

% B = subarray(A, i1, i2, j1, j2, pad)
% Extract subarray from array
% pad with boundary values if pad = 1
% pad with zeros if pad = 0

dim = size(A);
%i1
%i2
is = i1:i2;
js = j1:j2;

if pad,
  is = max(is,1);
  js = max(js,1);
  is = min(is,dim(1));
  js = min(js,dim(2));
  B  = A(is,js,:);
else
  % todo
end