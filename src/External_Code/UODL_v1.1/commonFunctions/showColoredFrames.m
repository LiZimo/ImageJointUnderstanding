function showColoredFrames(frame, weight, varargin)
% show frames with different colors based on their weights

strcolormap = 'jet';
ms = 3;
mode = 'dot';
linew = 1;

for k=1:2:length(varargin)
  opt=lower(varargin{k}) ;
  arg=varargin{k+1} ;
  switch opt
    case 'offset'
      offset = arg;
      if numel(offset) == 1
          offset(2) = 0;
      end
      frame(1,:) = frame(1,:) + offset(1);
      frame(2,:) = frame(2,:) + offset(2);
    case 'colormap'
        strcolormap = arg;
    case 'markersize'
        ms = arg;
    case 'mode'
        mode = arg;
    case 'linewidth'
        linew = arg;
    otherwise
      error(sprintf('Unknown option ''%s''', opt)) ;
  end
end

cmap = colormap(strcolormap);
colormap('gray');

maxW = max(weight);
minW = min(weight);
if maxW > minW
    step_w = length(cmap) / (maxW-minW);
else
    step_w = length(cmap);
end

[ tmp, idxC ] = sort(weight);

if strcmp(mode,'dot')
    hs = gsp(frame(1,:),frame(2,:),weight,ms);
elseif strcmp(mode,'frame')
    for m=1:numel(weight)
        idxFrame = idxC(m);
        colorId = min( ceil( ( weight(idxFrame)-minW ) * step_w )+1, length(cmap));
        colorCode = cmap( colorId, :);
        %vl_plotframe(frame(:,idxFrame),'color','w','LineWidth',3);
        vl_plotframe(frame(:,idxFrame),'color',colorCode,'LineWidth',linew);
    end
elseif strcmp(mode,'box')
    box = frame2box(frame);
    for m=1:numel(weight)
        idxFrame = idxC(m);
        colorId = min( ceil( ( weight(idxFrame)-minW ) * step_w )+1, length(cmap));
        colorCode = cmap( colorId, :);
        
        xmin= box(1,idxFrame);
        ymin= box(2,idxFrame);
        xmax= box(3,idxFrame);
        ymax= box(4,idxFrame);
    
        plot([xmin xmax xmax xmin xmin],[ymin ymin ymax ymax ymin],'Color',colorCode,'LineWidth',linew,'LineStyle','-');
    end
else
    error(sprintf('Unknown mode ''%s''', mode)) ;
end

end

%~~~~~~~~~~ Graf Scatter Plot ~~~~~~~~~~~
function varargout = gsp(x,y,c,ms)
%Graphs scattered poits
map = colormap('jet');
colormap('gray')
ind = fix((c-min(c))/(max(c)-min(c))*(size(map,1)-1))+1;
h = [];
%much more efficient than matlab's scatter plot
for k=1:size(map,1) 
    if any(ind==k)
        h(end+1) = line('Xdata',x(ind==k),'Ydata',y(ind==k), ...
            'LineStyle','none','Color',map(k,:), ...
            'Marker','o','MarkerFaceColor',map(k,:), 'MarkerSize',ms);
    end
end
if nargout==1
    varargout{1} = h; 
end

end