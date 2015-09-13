function new_corners = box_shift(old_corners, h,w)
    
    xmin = old_corners(1);
    ymin = old_corners(2);
    xmax = old_corners(3);
    ymax = old_corners(4);

    left_room = -xmin+1;
    right_room = w - xmax -1 ;
    up_room = -ymin + 1;
    down_room = h - ymax - 1;
    
    
    horz_shift = randi([left_room right_room]);
    vert_shift = randi([up_room down_room]);
    
    new_corners = [xmin+horz_shift ymin+vert_shift xmax+horz_shift ymax+vert_shift];
end