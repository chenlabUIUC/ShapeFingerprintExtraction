% NAME:     this function extracts the shape signature d(theta) from nanoparticle 
%           contour coordinates.
% INPUT:    boundary: Nx2 array containing the coordinates of all points on 
%           the boundary of one nanoparticle.
%           center: the geometrical centroid of the nanoparticle boundary
% NOTE:     this function also shifts the the signature so value in the 
%           middle of the d(theta) coresponds to the largest d(theta)
% OUTPUT:   out: 1x360 array of shape signatures d(theta). The range of ? is 
%           [-179:180] degrees with an interval of 1 degree.
% 
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021
function out = signature(boundary,center)
    y0=boundary(:,1);
    x0=boundary(:,2);
    boundary=[x0,y0];
    rads=1000;
    angles=[1:360]';
    x=center(1)*ones([length(angles) 1]);
    y=center(2)*ones([length(angles) 1]);
    trans_x=rads*cosd(angles);
    trans_y=rads*sind(angles);
    tail_x=x+trans_x;
    tail_y=y+trans_y;
%     xi = zeros([length(angles) 1]);
%     yi = zeros([length(angles) 1]);
    dist = zeros([length(angles) 1]);
%      figure(1);clf;
%      plot(x0,y0,'black')
%      hold on
    for i = 1:360
        final_x = [center(1); tail_x(i)];
        final_y = [center(2); tail_y(i)];
        [x_current,y_current] = polyxpoly(boundary(:,1),boundary(:,2),final_x,final_y,'unique');
        if(length(x_current)>1)
            d = [x_current, y_current]-center;
            d = sqrt(d(:,1).^2+d(:,2).^2);
            sorter = [d,x_current,y_current];
            sorter = sortrows(sorter,1);
            x_current = sorter(:,2);
            y_current = sorter(:,3);
            seg_centers_x = (x_current(:)+[center(1);x_current(1:end-1)])/2;
            seg_centers_y = (y_current(:)+[center(2);y_current(1:end-1)])/2;
            seg_bins_x = [center(1);x_current];
            seg_bins_y = [center(2);y_current];
            ins = inpolygon(seg_centers_x,seg_centers_y,boundary(:,1),boundary(:,2));
%             scatter(seg_centers_x,seg_centers_y,'green')
%             scatter(x_current,y_current,'red')
            for k = 1:(length(seg_bins_x)-1)
                if(ins(k))
                    %plot([seg_bins_x(k);seg_bins_x(k+1)],[seg_bins_y(k);seg_bins_y(k+1)],'b')
                    dist(i) = dist(i) + sqrt((seg_bins_x(k+1)-seg_bins_x(k)).^2+(seg_bins_y(k+1)-seg_bins_y(k)).^2);
                else
                    %plot([seg_bins_x(k);seg_bins_x(k+1)],[seg_bins_y(k);seg_bins_y(k+1)],'r')
                end
            end
        elseif (length(x_current)==1)
            dist(i) = sqrt((center(1)-x_current).^2+(center(2)-y_current).^2);
        else
            dist(i) = 0;
        end
        %xi(i) = x_current;y(i) = y_current;
    end


    %scatter(xi,yi,'red')
    %axis equal
    


    %%
%   this block shifts the signature so value in the middle coresponds to
%   the largest d(?)
    max_d = find(dist ==max(dist));
    dist_new = dist*NaN;
    angles_new = angles-180;
    if(max_d>=180)
        dist_new(180:180+360-max_d) = dist(max_d:360);
        dist_new(1:179) = dist(max_d-180+1:max_d-1);
        dist_new(180+360-max_d+1:360) = dist(1:max_d-180);
    else
        dist_new(180:360) = dist(max_d:max_d+180);
        dist_new(1:180-max_d) = dist(max_d+180+1:360);
        dist_new(180-max_d+1:179) = dist(1:max_d-1);
    end
%     figure(2)
%     plot(angles_new,dist_new);
%     hold on
%     drawnow
    out = dist_new';
end