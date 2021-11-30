% NAME:     this function determines which contour is one point in.
% INPUT:    point: coordinate of a point in 2D plane (x,y)
%           B: a cell containing boundary coordinates of several different polygons
% OUTPUT:   insiders: a logical array with the same number of elements as
%           cell B. 1 indicates the point is inside the coresponding
%           polygon. 0 for outside.
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021
function insiders = in_which_polygon(point,B)
    insiders = zeros([length(B),1]);
    for i = 1:length(B)
        x = inpolygon(point(1),point(2),B{i}(:,1),B{i}(:,2));
        insiders(i) = x;
    end
end