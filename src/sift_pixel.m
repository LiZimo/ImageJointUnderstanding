function [f,d] = sift_pixel(image, pixel)

fc = [pixel(1);pixel(2);10;0] ;
[f,d] = vl_sift(I,'frames',fc,'orientations') ;

end