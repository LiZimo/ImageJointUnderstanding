function [ id_nms v_nms] = select_kbestbox( boxfull, confidence, k )
% select non-duplicate k-best boxes based on confidence
 
if nargin < 2 || isempty(confidence)
    confidence = ones(1,size(boxfull,2));
end
if nargin < 3 
    k = 5;
end
 
rectA = box2rect(boxfull);
areaA = rectA(3,:).*rectA(4,:);
 
id_nms = []; v_nms = [];
[ vmax, imax ] = max(confidence);
while numel(id_nms)<k && ~(vmax==-inf)
    id_nms = [ id_nms, imax ];
    v_nms = [ v_nms, vmax ];
    confidence(imax) = -inf;
    id_valid = find(isfinite(confidence));
    area_int = rectint(rectA(:,imax)',rectA(:,id_valid)');
    IOU = area_int ./ (areaA(imax)+areaA(id_valid)-area_int);
    id_nm = id_valid(find(IOU>0.8));
    confidence(id_nm) = -inf;
    [ vmax, imax ] = max(confidence);    
end
