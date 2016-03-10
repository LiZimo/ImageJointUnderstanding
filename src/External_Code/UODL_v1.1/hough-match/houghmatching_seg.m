function [ confidenceMap ] = houghmatching_seg( viewA, viewB, hsfilter )
% Probabilistic Hough matching function, used in 
% Unsupervised Object Dicovery and Localization in the Wild, CVPR15
% written by Minsu Cho, Inria - WILLOW

bVerbose = false;
thresAspect = 2.0;
if nargin < 3
    % filter used for smoothing in the Hough space
    hsfilter = fspecial3('gaussian', [5 5 5]);
end

tic;
%% learning HT
% compute inverted frames and determinants
[ invframe, detA ]  = inv_frame(viewA.frame);
% project the points on the standard frame
ptRef = viewA.bbox(3:4);% bottom right point
% ptRef = [ viewA.imsize(1) viewA.imsize(2) ];% bottom right point
xTrain = invframe(3,:)*ptRef(1) + invframe(5,:)*ptRef(2) + invframe(1,:);
yTrain = invframe(4,:)*ptRef(1) + invframe(6,:)*ptRef(2) + invframe(2,:);
sTrain = detA; % original scale
aTrain = viewA.frame(3,:)./viewA.frame(6,:);% aspect ratio 
aTest = viewB.frame(3,:)./viewB.frame(6,:);

%% inference HT
% setting for Hough space bins
width = viewB.imsize(1) * 2; 
height = viewB.imsize(2) * 2;
nCell = 8000;  % cells in x-y space
szCell = max(sqrt((width*height)/nCell),5);
model.nSpatialX = round(width/szCell); 
model.nSpatialY = round(height/szCell);
model.nSpatialS = 20;
dimBin = [model.nSpatialY, model.nSpatialX, model.nSpatialS];

% initialize histogram
histo = zeros(prod(dimBin), 1, 'single');
histo_add = zeros(prod(dimBin), 1, 'single');
xbinv = linspace(1,width,dimBin(2)+1);
ybinv = linspace(1,height,dimBin(1)+1);
sbinv = linspace(-4,4,dimBin(3)+1); % log_2 scale

% compute full sim matrix
wVoteFull = viewA.desc'*[ viewB.desc; ones(1,size(viewB.desc,2)) ];
wVoteFull = max(wVoteFull, 0);   

% confidenceMap = wVoteFull;
% return

tableBina = zeros(size(viewA.frame,2),size(viewB.frame,2),'uint32'); 

if bVerbose
    fprintf('vote weight: max %f - min %f\n', max(wVoteFull(:)), min(wVoteFull(:)));
end

nFeatTrain = size(viewA.desc,2);
%nFeatTest = size(viewB.desc,2);
% do Hough voting
for j=1:nFeatTrain
   xVote = viewB.frame(3,:)*xTrain(j) + viewB.frame(5,:)*yTrain(j) + viewB.frame(1,:);
   yVote = viewB.frame(4,:)*xTrain(j) + viewB.frame(6,:)*yTrain(j) + viewB.frame(2,:);
   sVote = abs((viewB.frame(3,:).*viewB.frame(6,:)-viewB.frame(5,:).*viewB.frame(4,:))./sTrain(j)); % original scale 
   sVote = log(sVote)./log(2);
   
   xBin = vl_binsearch(xbinv, xVote);
   yBin = vl_binsearch(ybinv, yVote);
   sBin = vl_binsearch(sbinv, sVote);
   bValid = (xBin >= 1) & (xBin <= dimBin(2)) ...
       & (yBin >= 1) & (yBin <= dimBin(1)) ...
       & (sBin >= 1) & (sBin <= dimBin(3));

   % prune bad candidates by aspect ratio
   bValid = bValid & (aTest/aTrain(j) < thresAspect) & (aTest/aTrain(j) > 1/thresAspect);
       
   idxValid = find(bValid);
   if ~isempty(idxValid)
       binsx = xBin(idxValid);%[ binsx, xBin(idxValid) ];
       binsy = yBin(idxValid);%[ binsy, yBin(idxValid) ];
       binss = sBin(idxValid);%[ binss, sBin(idxValid) ];
       wVote = wVoteFull(j,idxValid);
       bins = binsy + (binsx-1)*dimBin(1) + (binss-1)*dimBin(1)*dimBin(2);
       %bins = sub2ind(dimBin, binsy, binsx, binss); % sub2ind too slow

       nBins = numel(bins);
       for p=1:nBins
           histo_add(bins(p)) = max( histo_add(bins(p)), wVote(p));
           %histo_add(bins(p)) = histo_add(bins(p)) + wVote(p);
       end
       histo = histo + histo_add; % add temporaty votes to histogram
       histo_add(bins) = 0; % make temporary ones zeros again

       % store bin ids 
       tableBina(j, idxValid) = bins;
   end

end

houghspace = reshape(histo, [model.nSpatialY, model.nSpatialX, model.nSpatialS]);

% smoothen by convolution
houghspace = convn(houghspace, hsfilter,'same');

if bVerbose
    % show Hough spaces by scales
    figure;
    for jj=1:model.nSpatialS
      subplot(5,5,jj);  imagesc(houghspace(:,:,jj));
      title([ 'max hits: ' num2str(max(max(houghspace(:,:,jj)))) ]);
    end
    pause;
end

%% make the Hough space confidence
% make the confidence map (# of frames A by # of frames B)
confidenceMap = zeros(size(viewA.frame,2),size(viewB.frame,2),'single');
idxValid = find(tableBina>0);
confidenceMap(idxValid) = wVoteFull(idxValid).*houghspace(tableBina(idxValid));   


end

