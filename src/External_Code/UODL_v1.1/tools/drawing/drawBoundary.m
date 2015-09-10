% SUHA KWAK, post-doctoral researcher, WILLOW - INRIA/ENS



function bimg = drawBoundary(img)



[H, W, C] = size(img);
B = true(H, W);


% top to bottom
for cidx = 1 : C
	B(1:end-1, :) = B(1:end-1, :) & (img(1:end-1, :, cidx) == img(2:end, :, cidx));
end

% left to right
for cidx = 1 : C
	B(:, 1:end-1) = B(:, 1:end-1) & (img(:, 1:end-1, cidx) == img(:, 2:end, cidx));
end


% draw boundary
bimg = double(img);
bd = double(B) + (double(~B) .* 0.6);		% alpha effect on boundary
for cidx = 1 : C
	bimg(:, :, cidx) = bimg(:, :, cidx) .* bd;
end
bimg = uint8(bimg);
