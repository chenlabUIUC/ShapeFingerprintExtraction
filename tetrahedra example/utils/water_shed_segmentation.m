% NAME:     this function uses watershed algorithm to draw lines to seperate the areas 
%           connected by narrow necks in an binary image.
% INPUT:    BW: the binary image to be segmented. 1 for objects, 0 for emptiness
%           threshold: a threshold on distance map to impose local minimums
% NOTE:     adaped from https://www.mathworks.com/help/images/ref/watershed.html
%           with modifications
% OUTPUT:   L: a binary images with areas seperated by black(0) lines
% 
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021
function L=water_shed_segmentation(BW,threshold)
    D = -bwdist(~BW);
    M = D < -threshold;
    D = imimposemin(D,M);
    D(~BW) = Inf;
    L = watershed(D);
    L(~BW) = 0;
    L = L>0;
end