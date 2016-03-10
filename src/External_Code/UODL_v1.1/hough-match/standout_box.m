function [ standout ] = standout_box( box, confidence )
 
% compute the box-popup score 
box(3,:) = box(3,:)-box(1,:);
box(4,:) = box(4,:)-box(2,:);
area = box(3,:).*box(4,:);
[~, id_largest] = max(area);
 
% in order to speed up, ignore candidates with confidence less than a quantile 
bCand = confidence>quantile(confidence,0.75);
id_nms = find(bCand);
%id_nms = find(confidence>median(confidence));
%fprintf('%d out of %d selected.\n',numel(id_nms),numel(confidence));
 
standout = -inf*ones(1,numel(confidence));
 
%lar = 0.8;  % for the Object Discovery datasets (mostly large and centered)

lar = 0.5; % for the PASCAL datasets (usual setting)
inc = 0.8;
kPart = 5;

bCont = true;
while bCont 
    for k=1:numel(id_nms)

        % find larger boxes containing itself
        id_larger = find(lar*area > area(id_nms(k)));
        area_int = rectint(box(:,id_nms(k))',box(:,id_larger)');
        IOA = area_int / area(id_nms(k)); % area ration of intersection to k
        id_valid1 = id_larger(find(IOA >= inc)); % larger boxes containing it

        % find smaller boxes contained in itself
        id_smaller = find(area < lar*area(id_nms(k)));
        area_int = rectint(box(:,id_nms(k))',box(:,id_smaller)');
        IOB = area_int ./ area(id_smaller); % area ration of intersection to the others
        id_valid2 = id_smaller(find(IOB >= inc)); % smaller boxes contained it

        % compute the box-popup score with an additional constraint
        id_valid1 = [ id_valid1 id_largest]; % add the largest box
        if ~isempty(id_valid1) && ~isempty(id_valid2)
            score = confidence(id_nms(k)) - max(confidence(id_valid1));            
            if nnz(confidence(id_valid2) > max(confidence(id_valid1))) >= kPart % an additional constratint
                if nnz(confidence(id_valid2) > confidence(id_nms(k))) > 3
                    standout(id_nms(k)) = score;
                end
            end
        end

    end
    
    % handling exceptional cases: just ignore the additional constraints
    if nnz(isfinite(standout)) == 0 && kPart > 0
       kPart = 0;
    else
       bCont = false;
    end       
end

if nnz(isfinite(standout)) == 0 
    'fuck'
    standout = confidence;
end
    



