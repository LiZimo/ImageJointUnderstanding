function desc = load_hog( filePathName, varargin )
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

boxes = feat.boxes;

%fprintf('%d RP generated proposals in %0.2f seconds!\n', size(proposals,1), toc(ticId));
bValid1 = boxes(:,1) > feat.imsize(1)*0.01 & boxes(:,3) < feat.imsize(1)*0.99 ...
        & boxes(:,2) > feat.imsize(2)*0.01 & boxes(:,4) < feat.imsize(2)*0.99;
bValid2 = boxes(:,1) < feat.imsize(1)*0.01 & boxes(:,3) > feat.imsize(1)*0.99 ...
        & boxes(:,2) < feat.imsize(2)*0.01 & boxes(:,4) > feat.imsize(2)*0.99;

idxValid = find(bValid1 | bValid2);
desc = cast(feat.hist(idxValid,:)', 'single');

