function [all_img1_indicators, all_img2_indicators] = get_sift_correspondences(im1, im2, SIFTflowpara, cellsize,gridspacing)
%% INPUT: im1 and im2 are two images
%% SIFTflowpara are the sift flow parameters.  
%% If you don't add a SIFTflowpara, cellsize, or gridspacing, there are defaults.


%% OUTPUT:
%% "all_img1_indicators" is an N x M matrix where N = size(im1,1)*size(im1,2), and M is the number
%% of correspondences calculated by the sift flow algorithm between the two images.
%% Each column of "all img1_indicators" represents a linearized version of the 2D image, with
%% a 1 representing a specific pixel

%% "all_img2_indicators" is a K x M matrix where K = size(im2,1)*size(im2,2), and M is the
%% same as above.  Each column in "all_img2_indicators" is also an indicator, in correspondence with
%% the indicator in "all_img1_indicators" of the same row.  


if nargin < 3

cellsize=3;
gridspacing=1;
SIFTflowpara.alpha=2*255;
SIFTflowpara.d=40*255;
SIFTflowpara.gamma=0.005*255;
SIFTflowpara.nlevels=4;
SIFTflowpara.wsize=2;
SIFTflowpara.topwsize=10;
SIFTflowpara.nTopIterations = 60;
SIFTflowpara.nIterations= 30;

end

imgsize = size(im1,1);

%% calculate the flow_field using SIFTflow
sift1 = mexDenseSIFT(im1,cellsize,gridspacing);
sift2 = mexDenseSIFT(im2,cellsize,gridspacing);
[vx,vy,energylist]=SIFTflowc2f(sift1,sift2,SIFTflowpara);

all_img1_indicators = zeros(imgsize^2, imgsize^2);
all_img2_indicators = zeros(imgsize^2, imgsize^2);

return

entry = 1;

%% using the flow field, mark indicator matrices
for i=1:imgsize
    for j=1:imgsize
      img1_indicator = zeros(imgsize);
      img1_indicator(i,j) = 1;
      img1_indicator = reshape(img1_indicator, [], 1);
      
      img2_indicator = zeros(imgsize);
      corres_y = i +vy(i,j);
      corres_x = j+vx(i,j);
      
       if corres_y <= 0 || corres_y >= imgsize || corres_x <= 0 || corres_x >= imgsize
           continue;
       end
      
      try img2_indicator(corres_y,corres_x) = 1;
      catch continue
      end

      img2_indicator = reshape(img2_indicator, [], 1);
      if length(img2_indicator) ~= imgsize^2
          input('bad size');
      end
      
      all_img1_indicators(:,entry) = img1_indicator;
      all_img2_indicators(:,entry) = img2_indicator;
      entry = entry+1;
    end
end
all_img1_indicators( :, ~any(all_img1_indicators,1) ) = [];  %columns
all_img2_indicators( :, ~any(all_img2_indicators,1) ) = [];  %columns



end
