% SUHA KWAK, post-doctoral researcher, WILLOW - INRIA/ENS



function img = paintBlack(img, bbox)


[H, W, C] = size(img);

% bbox = [x, y, width, height]
bbox = max(bbox, 1);
xmin = min(W, bbox(1));
xmax = min(W, bbox(1) + bbox(3));
ymin = min(H, bbox(2));
ymax = min(H, bbox(2) + bbox(4));

% mask
img_mask = zeros(H, W, 'uint8');
img_mask(ymin : ymax, xmin : xmax) = 1;
img_mask = repmat(img_mask, [1, 1, C]);

% masking
img = img .* img_mask;


