% NAME:     this is an example showing how to extract the shape signature 
%           d(theta) of nanoparticles from TEM images. The inputs of this function 
%           are based on the output of "tetrahedra_segmentation.m", so please
%           first run "tetrahedra_segmentation.m". For more information and 
%           citation, please refer to our publication:
%           Unveil the synthesis?nanomorphology relationships of heterogeneous
%           nanoparticles, hybrids, and 3D polymer films using generalizable 
%           shape fingerprints and unsupervised learning
%
% INPUT:    individual particle contours: MATLAB structs containing an Nx2
%           array of points on the particle contour. Contours of individual
%           nanoparticles are stored in ".mat" files in "contours/". 
%           (unit: pixel)

% NOTE:     in this example the signatures are shifted so value in the 
%           middle of the d(theta) coresponds to the largest d(theta).

% OUTPUT:   shape signatures d(theta): Nx360 array containing shape signatures
%           of each individual nanoparticle. The range of theta is [-179:180] degrees 
%           with an interval of 1 degree. The array will be output into 
%           "signartures.csv"
%           (unit: pixel)
%           
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021
addpath('utils');
nameList = dir('contours');
data = [];
Areas = [];

figure(1);clf;
set(gcf,'color','w');
set(gcf,'position',[20 200 512 512])
set(gca,'position',[0.1 0.1 .8 .8])
xlabel('\theta')
ylabel('d(\theta) (pixels)')
hold on
for i = 3 :length(nameList)
    load(['contours/',nameList(i).name]);B = output.B;
    if size(B,1)<3 %remove any incomplete contours
        data = [data;nan([1,360])];
        continue;
    end
    mask = poly2mask(B(:,1),B(:,2),512,512);
    props = regionprops(mask,'Centroid','Area');
    if(length(props)<1) %remove any contours with no area (linear contours)
        data = [data;nan([1,360])];
       continue; 
    end
    Areas = [Areas;props(1).Area];
    if(props(1).Area<3500) %remove any contours with too small area
        data = [data;nan([1,360])];
       continue; 
    end
    
    cen = props.Centroid;cen = [cen(2),cen(1)];
    profile_ = signature(B,cen);
    data = [data;profile_];
    plot(1:360,data);
    drawnow
end
    
T = array2table(data);
writetable(T,'signatures.csv','WriteVariableNames',0) %save the extracted shape signatures