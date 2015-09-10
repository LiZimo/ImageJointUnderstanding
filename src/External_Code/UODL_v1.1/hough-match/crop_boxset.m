function [ idx_sel2 ] = crop_boxset( boxfull, bbox_id, confidence, nMax )
% crop a subset of boxes based on bounding boxes 

if nargin < 3 || isempty(confidence)
    confidence = ones(1,size(boxfull,2));
end

if nargin < 4
    nMax = 10000;
end

rectA = box2rect(boxfull);
areaA = rectA(3,:).*rectA(4,:);

if ~isempty(bbox_id)
    rect_s = box2rect(boxfull(:,bbox_id));
    area_s = rect_s(3,:).*rect_s(4,:);
    area_int = rectint(rect_s',rectA');
    id_sel = false(1,size(boxfull,2));
    
    for p=1:numel(bbox_id)
        IOA = area_int(p,:) ./ areaA; % area intersection ratio to the others
        IOS = areaA / area_s(p); % area ratio to the object box
        id_sel = id_sel | (IOA > 0.8 & IOS > 0.1);
    end
    idx_sel = find(id_sel);
else
    idx_sel = 1:size(boxfull,2);
end

% enforce to include the input boxes
confidence(bbox_id) = inf;

%suppress near-duplicate boxes
id_nms = [];
confidence = confidence(idx_sel);
rectA = rectA(:,idx_sel);
areaA = areaA(idx_sel);
while nnz(confidence) && numel(id_nms) < nMax
    [ tmp, imax ] = max(confidence);
    id_nms = [ id_nms, imax ];
    confidence(imax) = 0;
    if ~isinf(tmp)
        id_valid = find(confidence>0);
    else
        id_valid = find(confidence>0 & ~isinf(confidence));
    end

    % suha, 20150404
    if isempty(id_valid)
        break;
    end
        
    area_int = rectint(rectA(:,imax)',rectA(:,id_valid)');
    IOU = area_int ./ (areaA(imax)+areaA(id_valid)-area_int);
    id_nm = id_valid(find(IOU>0.5));
    confidence(id_nm) = 0;
end

idx_sel2 = idx_sel(id_nms);

end