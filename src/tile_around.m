function tiled_output = tile_around(masked_img, corners)

tile = masked_img(corners(2):corners(4), corners(1):corners(3),:);

tile_length = ceil(size(masked_img,2)/size(tile,2));
tile_height = ceil(size(masked_img,1)/size(tile,1));


big_tiled = repmat(tile, tile_height, tile_length);

tiled_output = big_tiled(1:size(masked_img,1), 1:size(masked_img,2),:);
tiled_output(corners(2):corners(4), corners(1):corners(3),:) = tile;

end