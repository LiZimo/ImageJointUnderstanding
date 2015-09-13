function new_corners = get_sub_box(old_corners,scale)

old_length = (old_corners(3) - old_corners(1));
old_height = (old_corners(4) - old_corners(2));

new_length = old_length*sqrt(scale);
new_height = old_height*sqrt(scale);

xmin = old_corners(1) + (old_length - new_length)/2;
xmax = xmin + new_length;
ymin = old_corners(2) + (old_height - new_height)/2;
ymax = ymin + new_height;

new_corners = uint16(floor([xmin ymin xmax ymax]));

assert(xmin < xmax);
assert(ymin < ymax);
end
