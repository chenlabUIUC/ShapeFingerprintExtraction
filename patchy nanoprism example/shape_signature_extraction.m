% NAME:     this is an example showing how to extract the shape signature 
%           d(theta) of the polymer patches from patchy nanoparticle TEM 
%           images. The inputs of this function are based on the output of
%           "segmentation.m", so please first run "segmentation.m". For 
%           more information and citation, please refer to our publication:
%           Unveil the synthesis?nanomorphology relationships of heterogeneous
%           nanoparticles, hybrids, and 3D polymer films using generalizable 
%           shape fingerprints and unsupervised learning
%
% INPUT:    binary individual patchy particles: binary RGB images with each
%           patchy nanoparticle centralized and rotated so one tip of the
%           triangular is now point to the up direction. The binary
%           nanoparticle is stored in R channel and the binary polymer patches
%           are stored in G channel. The RGB images are stored in "segmentation/"
%
% NOTE:     in this example the signatures are shifted so value in the 
%           middle of the d(theta) coresponds to the largest d(theta). In
%           this example, the signatures are also flipped so the sum of the
%           d(theta) on the right half is always larger than the left half.
%
% OUTPUT:   shape signatures d(theta) of polymer patch on one tip: 
%           Nx120 array containing shape signatures of polymer patch on 
%           one tip of the patchy nanoprisms. The range of theta is [-59:60]
%           degrees with an interval of 1 degree. The array will be output into 
%           "signartures.csv"
%           (unit: pixel)
%           
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021

addpath('utils')
path = 'segmentation/';
fileList = dir(path);
sigs = [];
figure(1);clf;hold on
set(gcf,'color','w');
xlabel('theta (degree)')
ylabel('d(theta) (pixel)')
triangle_mask = [256, 256; 256+256*sqrt(3),0; 256-256*sqrt(3),0];
triangle_mask = poly2mask(triangle_mask(:,1),triangle_mask(:,2),512,512);
    for i  = 1 :length(fileList)
        namei = fileList(i).name;
        if(length(namei)<4)   %% remove files with too short name
            continue;
        end
        if(~strcmp(namei(end-3:end),'.tif'))%% remove files that are not in tiff format
            continue;
        end
        I = imread([path,namei]);
        img = double(I(:,:,1))*0+0.8;
        ptc = I(:,:,1)==255;
        ply = I(:,:,2)==255;
        img(ptc) = 0.2;
        img(ply) = 0.6;
        c = regionprops(ptc,'Centroid');
        c = c.Centroid;
        [B,L] = bwboundaries(ply);
        sig = zeros(1,360);
        disp(namei)
        
%       extracts the polymer patch shape signature in whole range from -180 to +180 degrees
        if inpolygon(c(1),c(2),B{1}(:,1),B{1}(:,2))
            sig = particle_signature_no_rotation(B{1},c)-particle_signature_no_rotation(B{2},c); %%sometimes the polymer patch can inscribe the core. Here B{1} is the outer polymer contour and B{2} is the inner hole.
        else
            for p = 1 :length(B)
                sig = sig + patch_signature_no_rotation(B{p},c);
            end
        end
%       cut the shape signature into 3 parts each coresponds to one tip        
        sig = [sig(331:360), sig(1:330)];
        sig1 = sig(1:120);
        sig2 = sig(121:240);
        sig3 = sig(241:360);
        if sum(sig1(1:60)) > sum(sig1(61:120))
           sig1 = flip(sig1); 
        end
        if sum(sig2(1:60)) > sum(sig2(61:120))
           sig2 = flip(sig2); 
        end
        if sum(sig3(1:60)) > sum(sig3(61:120))
           sig3 = flip(sig3); 
        end
        sigs = [sigs,sig1',sig2',sig3'];
%        figure(2);hold on
%        clf;
        plot((1:120)-60,sig1);
        plot((1:120)-60,sig2);
        plot((1:120)-60,sig3);
%        plot(1:360,sig);
%        imshow(img)
        xlim([-60,60])
        drawnow
    end
    
sigs_out = sigs(:,:);
writematrix(sigs_out','signatures.csv') 
