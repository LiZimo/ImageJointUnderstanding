%    Unsupervised Object Discovery and Localization in the Wild
%    http://www.di.ens.fr/willow/research/objectdiscovery    
%
%    written by Minsu Cho and Suha Kwak, Inria - WILLOW , 2015
%    * Before running this script, see README.txt

% Set paths to libraries and data
set_path;

% Prepare dataset: copy images, and extract box proposals and HOG features

% The script "prep_VOC2007_6x2.m" builds PASCAL 2007 6x2 dataset by selecting 
% and copying images from VOC 2007 dataset with the policies given in the
% paper introducing the dataset (Deselaers et al.'10). Write your own to build 
% your dataset. 
% You also should write "setup_*.m" for your own dataset; it will generate
% lists of test images and their labels. See "setup_VOC2007_6x2.m" for  
% an example. You may need to change only from line 33 to line 60 of the file
% to write your own setup script.
prep_VOC2007_6x2;

extract_boxes('VOC2007_6x2');
extract_gist('VOC2007_6x2');

% Run our object discovery algorithm: 
% run_localization takes the following arguments: 
% the name of experiments, # of iterations, # of nearest neighbors
run_localization_fast('VOC2007_6x2', 5, 10);	% running faster
%run_localization_mem('VOC2007_6x2',  5, 10);	% running with less memory

% Result will be saved in the result folder, which is set in "setup_*.m"
% In a default setting, open '../results/VOC2007_6x2/Webpage/index.html' 
% to see quantified results and all visualzed examples.
