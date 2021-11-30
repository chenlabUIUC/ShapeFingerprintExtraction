% NAME:     this is an example showing the overlapping nanoparticle contour 
%           extraction from TEM images. This method is based on the machine 
%           learning neural network prediction. For more information and
%           citation, please refer to our publication:
%           Unveil the synthesis?nanomorphology relationships of heterogeneous
%           nanoparticles, hybrids, and 3D polymer films using generalizable 
%           shape fingerprints and unsupervised learning
%
% INPUT:    raw TEM images: the raw TEM images in tiff format are stored in "images/"
%
%           ML predictions: the neural netwrok predictions of coresponding 
%           TEM images with same names are stored in "predictions/". This
%           neural network predicts the pixels with particle overlaying as
%           intensity value 255, pixels within particle but without overlaying 
%           as value 127, and pixels in background as value 0.

% OUTPUT:   individual particle contours: MATLAB structs containing an Nx2
%           array of points on the particle contour. Contour of each
%           nanoparticle will be saved in one ".mat" file in "contours/". 
%           (unit: pixel)
%           
%           segmentation plots: extracted nanoparticle contours will be 
%           annotated in the raw TEM images. The plots will be saved in 
%           "segmentation/"
% 
% NOTE:     Manual selection is needed to remove the unsuccessful contours.
%           We have added interactive codes to make this step efficient.
%           Please left click the failed segmentations to remove them, and 
%           right click to finish the segmentation of the current image.
%
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021

addpath('utils');
name_list = dir('images');
count = 0;
for i = 3 :length(name_list)
   I = imread(['images/', name_list(i).name]);
   M = imread(['predictions/', name_list(i).name]);
   S = M==127;
   D = M==255;
   D = imclearborder(D);
   D_labeled = bwlabel(D);
   S= water_shed_segmentation(S,20);
   S = imclearborder(S);
   S_labeled = bwlabel(S);
   fig = figure(1);clf;
   set(gcf,'position',[20 200 512 512])
   set(gca,'position',[0 0 1 1])
   imshow(I)
   hold on
   Bs = {};
   for j = 1 :max(S_labeled(:))
      single_ind = S_labeled == j;
      mask_or = single_ind | D;
      mask_or  = water_shed_segmentation(mask_or ,5);
      or_labeled = bwlabel(mask_or);
      for k = 1 : max(or_labeled(:))
          particle = (or_labeled==k);
          if sum(particle & single_ind,'all')<1
              continue;
          end
          B = bwboundaries(particle');B = B{1};
          Bs{end+1} = B;
      end
   end
   B_mask = ones([length(Bs),1]);
   for j = 1 :length(Bs)
      plot (Bs{j}(:,1),Bs{j}(:,2),'LineWidth',2) 
   end
   
   while 1
        disp('Please left click the failed segmentations to remove. Right click to finish.');
          [x,y,button] = ginput(1);
          if (button ==1)
            insiders = in_which_polygon([x,y],Bs);
            B_mask = logical(B_mask-insiders);
            disp(max(insiders));
            fig = figure(1);clf;
            set(gcf,'position',[20 200 512 512])
            set(gca,'position',[0 0 1 1])
            imshow(I);
            hold on
          for j = 1:length(Bs)
            if B_mask(j)
                plot(Bs{j}(:,1),Bs{j}(:,2),'LineWidth',2) 
            end
          end
            
          else
          	break;
          end
   end
    
    for j = 1:length(Bs)
        if B_mask(j)
            B = Bs{j};
            count = count+1;
            output = struct();
            output.B = B;
            save(['contours/',num2str(count)],'output')
        end
    end            
   drawnow
   saveas(fig,['segmentation/',name_list(i).name,'.png'])
end