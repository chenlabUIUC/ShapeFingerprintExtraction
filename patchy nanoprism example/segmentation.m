% NAME:     this is an example showing the patchy nanoparticle segmentation
%           of both nanoparticle core and polymer patches from TEM images. 
%           This method is based on the machine learning neural network 
%           prediction. For more information, please refer to our publication:
%           Unveil the synthesis?nanomorphology relationships of heterogeneous
%           nanoparticles, hybrids, and 3D polymer films using generalizable 
%           shape fingerprints and unsupervised learning
%
% INPUT:    ML predictions: the neural netwrok predictions of experimental 
%           TEM images are stored in "predictions/". This neural network 
%           predicts the pixels within gold nanoparticle as intensity value
%           255, pixels within patchy polymer shell as value 127, and pixels
%           in background as value 0.
%
% OUTPUT:   binary individual patchy particles: binary RGB images with each
%           patchy nanoparticle centralized and rotated so one tip of the
%           triangular is now point to the up direction. The binary
%           nanoparticle is stored in R channel and binary polymer patches
%           are stored in G channel. The RGB images will be saved in "segmentation/"
%
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021

addpath('utils')
path = 'predictions/';
fileList = dir(path);
    for i  = 1 :length(fileList)
        namei = fileList(i).name;
        if(length(namei)<4)
            continue;
        end
        if(~strcmp(namei(end-3:end),'.tif'))
            continue;
        end
        I = imread([path,namei]);
        I_ptc = (I==255);
        I_ply = (I==127);
        I_both = (I>0);
        I_both = imclearborder(I_both);
        [B,L]= bwboundaries(I_both);
        for p = 1 :length(B)
           combined =  L==p;
           if sum(combined,'all')<10000
              continue; %skip small 'particles'
           end
           ptc = I_ptc&combined;
           ply = I_ply&combined;
           %%%%keep only the largest area as the particle core
           [~,L]= bwboundaries(ptc);
           ptc = L==1;
           ptc = imfill(ptc,'holes');
           %%%%keep large areas as the polymer shell
           ply = bwareaopen(ply, 50);
           ply = ~bwareaopen(~ply, 50);
           %%%%calc. orientation
           [B,L] = bwboundaries(ptc);
           c = regionprops(L,'Centroid');
           out = particle_signature_no_rotation(B{1},c.Centroid);
           A = find(out==max(out))+90;
           %%%translate to the center & rotate
           prop = regionprops(ptc, 'Centroid','Area');
           ply = imtranslate(ply,-prop.Centroid+[256,256]);
           ply = imrotate(ply,A(1),'crop');
           ptc = imtranslate(ptc,-prop.Centroid+[256,256]);
           ptc = imrotate(ptc,A(1),'crop');
           figure(1);clf;
           set(gcf,'position',[200,200,512,512])
           set(gca,'position',[0 0 1 1])
           %hold on
           output = cat(3,cat(3,ptc,ply),ply*0)*255;
           imwrite(output,['segmentation/',namei(1:end-4),'-',num2str(p),'.tif'])
           imshow(output)
           drawnow
        end
        
    end
