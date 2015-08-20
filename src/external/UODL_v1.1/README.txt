#########################################################################
#                                                                       #
#    Unsupervised Object Discovery and Localization in the Wild         #
#                        Version 1.0                                    #
#    http://www.di.ens.fr/willow/research/objectdiscovery               #
#                                                                       #
#    written by Minsu Cho and Suha Kwak, Inria - WILLOW , 2015          #
#                                                                       #
#########################################################################

email {minsu.cho or suha.kwak}@inria.fr 
for any questions, suggestions and bug reports

/*************************************************************************/
 This software is for academic use ONLY. 
 If you use this code for your research, please add the following citation.

@InProceedings{cho2015,
  author = {Minsu Cho and Suha Kwak and Cordelia Schmid and Jean Ponce},
  title = {Unsupervised Object Discovery and Localization in the Wild: Part-based Matching with Bottom-up Region Proposals},
  booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition},
  year = {2015}
}
/*************************************************************************/


This code implements the unsupervised object localization method
described in 
	 
[1] Unsupervised Object Discovery and Localization in the Wild: 
    Part-based Matching with Bottom-up Region Proposals
    Minsu Cho, Suha Kwak, Cordelia Schmid, and Jean Ponce
    Proc. of the IEEE Conf. on Computer Vision and Pattern Recognition 2015 

, and provides a demo script to reproduce the result on PASCAL VOC 2007 6x2 
dataset reported in our paper mentioned above. 

In order to use the demo code, you should also download and install
   
(a) VLFeat library [2]
    http://www.vlfeat.org/

(b) Prime Object Proposals with Randomized Prim's Algorithm [3]
    http://www.vision.ee.ethz.ch/~smanenfr/rp/index.html
    
(c) PASCAL VOC 2007 dataset [4]
    http://host.robots.ox.ac.uk/pascal/VOC/voc2007/index.html

 This code already contains HOG feature functions taken from [5]  
 http://www.cs.berkeley.edu/~rbg/latent/
 
Note that all paths to (a), (b), (c) should be set in "set_path.m". 
Once all set, run "run_demo.m". At the end of the algorithm, the results 
will be quantified and visualised in a summary html page:
../results/VOC2007_6x2/Webpage/index.html
   
For more details, see comments in "run_demo.m".
   
Enjoy!

-------
[2] VLFeat: An Open and Portable Library of Computer Vision Algorithms
    A. Vedaldi and B. Fulkerson, 2008
[3] Prime Object Proposals with Randomized Prim's Algorithm,
    S. Manen, M. Guillaumin, L. Van Gool,
    Proc. of the International Conference on Computer Vision 2013    
[4] The PASCAL Visual Object Classes Challenge 2007 (VOC2007) Results,
	M. Everingham, and L. Van Gool, C. K. I. Williams, J. Winn, A. Zisserman,
[5] Object Detection with Discriminatively Trained Part Based Models,
    P. F. Felzenszwalb, R. B. Girshick, D. McAllester, and D. Ramanan.,
    IEEE Transactions on Pattern Analysis and Machine Intelligence 2010