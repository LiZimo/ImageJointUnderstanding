function [laplcn, D_half] = ICS_laplacian_nf(rgbimage, radius,weight_func, sigmax, sigmav)


if nargin < 2
    radius = 1;
end

if nargin < 3 || weight_func == 0
    weight_func = @gaussian_vect;
end

% if ndims(rgbimage)==3
%     image = double(rgb2gray(rgbimage));
% else
 image = double(rgbimage);
% end
numpixels = size(image,1)*size(image,2);

height = size(image, 1);

all_starts = {};
all_ends = {};
all_vals = {};

parfor i1=1:2*radius + 1
    i = i1 - radius - 1;
    width = ceil(sqrt(radius^2 - i^2+1));
    starts = [];
    ends = [];
    vals = [];
    for j = -width:width
        if i == 0 && j == 0
            continue;
        end
        
        section = image(1+max(i,0):end+min(i,0), 1+max(j,0):end + min(j,0),:);
        shift = zeros(size(image,1),size(image,2),size(image,3),2);
        shift(1 - min(i,0):end-max(i,0),1-min(j,0):end-max(j,0),:,1) = section;
        shift(1 - min(i,0):end-max(i,0),1-min(j,0):end-max(j,0),:,2) = 1;
        
        weights = -weight_func(image,shift(:,:,:,1),sigmav);
        
        dist=sqrt(i^2 + j^2);
        
  
        weights = weights*exp(-dist^2/(sigmax));

            
        weights(sum(shift(:,:,:,2),3)==0) = 0;
        start_indices = find(weights)';
        end_indices = start_indices + j*size(image,1) + i;
        val = weights(weights~=0);
    
        starts(end+1:end+length(start_indices)) = start_indices;
        ends(end+1:end+length(end_indices)) = end_indices;
    
        vals(end+1:end+length(val)) = val';
    end
    
    all_starts{i1} = starts;
    all_ends{i1} = ends;
    all_vals{i1} = vals;
end


all_starts = cell2mat(all_starts);
all_ends = cell2mat(all_ends);
all_vals = cell2mat(all_vals);


laplcn = sparse([all_starts all_ends], [all_ends all_starts], [all_vals all_vals]);



% down the diagonal
for i=1:size(laplcn)
    laplcn(i,i) = -sum(laplcn(i,:));
end

D_half = eye(size(laplcn,1));
d = diag(laplcn);
D_half = diag(1./sqrt(d));
laplcn = D_half*laplcn*D_half;

end

function [index] = pixel_index(rowId, colId, height)
index = ((colId-1)*height) + rowId;
end

function val = gaussian(a,b,sigma)
val = exp(-(a-b).^2/(2*sigma^2));
%val = 1;
end

function val = gaussian_vect(a,b,sigma)
sq_diff = (a-b).^2;
val = exp(-sum(sq_diff,3)/(2*sigma^2));

end