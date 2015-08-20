function [ viewInfo ] = loadView_seg( filePathName, varargin )
% load image and make view info

conf = [];

for k=1:2:length(varargin)
  opt=lower(varargin{k}) ;
  arg=varargin{k+1} ;
  switch opt
    case 'conf'
      conf = arg;
    otherwise
      error(sprintf('Unknown option ''%s''', opt)) ;
  end
end

load([ filePathName(1:end-4) conf.postfix_feat '.mat' ], 'feat');



% suha - load GIST feature
load([ filePathName(1:end-4) conf.postfix_gist '.mat' ], 'gist_feat'); 



boxes = feat.boxes;

% viewInfo.img = feat.img;
% if size(viewInfo.img,3) == 3
%     viewInfo.img_gray = rgb2gray(viewInfo.img);
% elseif size(featInfo.img,3) == 1
%     viewInfo.img_gray = viewInfo.img;
%     viewInfo.img = repmat( viewInfo.img, [ 1 1 3 ]);
% else
%     err([ 'wrong image file!: ' filePathName ]);
% end


% suha - save image size separately
viewInfo.imsize = feat.imsize;  % width, height


%fprintf('%d RP generated proposals in %0.2f seconds!\n', size(proposals,1), toc(ticId));
bValid1 = boxes(:,1) > feat.imsize(1)*0.01 & boxes(:,3) < feat.imsize(1)*0.99 ...
        & boxes(:,2) > feat.imsize(2)*0.01 & boxes(:,4) < feat.imsize(2)*0.99;
bValid2 = boxes(:,1) < feat.imsize(1)*0.01 & boxes(:,3) > feat.imsize(1)*0.99 ...
        & boxes(:,2) < feat.imsize(2)*0.01 & boxes(:,4) > feat.imsize(2)*0.99;



idxValid = find(bValid1 | bValid2);
boxes = boxes(idxValid,:);
viewInfo.frame = box2frame(boxes');
viewInfo.type = ones(1,size(viewInfo.frame,2));
viewInfo.desc = cast(feat.hist(idxValid,:)', 'single');
% viewInfo.desc = full(feat.hist(idxValid,:)');
viewInfo.patch = cell(0);    
viewInfo.fileName = filePathName;
viewInfo.bbox = [ 1, 1, feat.imsize(1), feat.imsize(2) ]';

% suha - save GIST as well
viewInfo.gist = gist_feat;


