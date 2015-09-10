function [ id_nms ] = crop_kbestbox( boxfull, bbox_id, confidence, k )
% crop k-best boxes based on bounding boxes 

if nargin < 3 || isempty(confidence)
    confidence = ones(1,size(boxfull,2));
end

if nargin < 4 
    k = 10;
end

rectA = box2rect(boxfull);
areaA = rectA(3,:).*rectA(4,:);
if isempty(bbox_id)
    [ tmp, bbox_id ] = max(areaA);
end
rect_s = box2rect(boxfull(:,bbox_id));
area_s = rect_s(3,:).*rect_s(4,:);
area_int = rectint(rect_s',rectA');
id_sel = false(1,size(boxfull,2));

for p=1:numel(bbox_id)
    IOA = area_int(p,:) ./ areaA; % area intersection ratio to the others
    IOS = areaA / area_s(p); % area ratio to the object box
    id_sel = id_sel | (IOA > 0.8 & IOS > 0.2);
end
confidence(~id_sel) = 0;

% enforce the input boxes included with the highest confidences
confidence(bbox_id) = [ numel(bbox_id):-1:1 ] + max(confidence);

%suppress near-duplicate boxes
id_nms = [];
for p=1:numel(bbox_id)
    IOA = area_int(p,:) ./ areaA; % area intersection ratio to the others
    IOS = areaA / area_s(p); % area ratio to the object box
    idx_sel2 = find(IOA > 0.8 & IOS > 0.2);
    if isempty(idx_sel2)
        continue;
    end
    while numel(id_nms)<k && nnz(confidence)
        [ tmp, imax_t ] = max(confidence(idx_sel2));
        imax = idx_sel2(imax_t);
        id_nms = [ id_nms, imax ];
        confidence(imax) = 0;
        id_valid = find(confidence>0);

        % suha, 20150404
        if isempty(id_valid)
            break;
        end
        
        area_int_t = rectint(rectA(:,imax)',rectA(:,id_valid)');
        IOU = area_int_t ./ (areaA(imax)+areaA(id_valid)-area_int_t);
  
        id_nm = id_valid(find(IOU>0.5));
        confidence(id_nm) = 0;
    end

end


end