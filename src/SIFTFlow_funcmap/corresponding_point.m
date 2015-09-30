function point2 = corresponding_point(point1, basis1, basis2, functional_map)

point1_proj = basis1'*point1;
point2_from_map = functional_map*point1_proj;

point2_proj = basis2 * point2_from_map;

point2 = zeros(1,length(point1));
point2(point2_proj == max(point2_proj)) = 1;

end