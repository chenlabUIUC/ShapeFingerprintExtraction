% NAME:     this is an example showing the shape signature extraction from 
%           binarized 3D TEM tomographs of crumples on the polyamide filtration 
%           membrane. For more information and citation, please refer to our 
%           publication:
%           Unveil the synthesis?nanomorphology relationships of heterogeneous
%           nanoparticles, hybrids, and 3D polymer films using generalizable 
%           shape fingerprints and unsupervised learning
%
% INPUT:    binarized 3D images: the binarized volumetric TEM images in tiff 
%           format are stored in "images/"
%
%           wavefront 3D models: the wavefront models in ".obj" format of 
%           coresponding 3D images with same names are stored in "obj/". 
%           These files can be obtained by simply openining and saving the 
%           3D tiff images as wavefront files in ImageJ/Fiji.
%
% OUTPUT:   2D shape signature: 91x181 MATLAB matirx containing the 2D shape 
%           signature d(theta,phi). The range of theta is [0:180] degrees
%           with an interval of 2 degrees. The range of phi is [0:360] degrees
%           with an interval of 2 degrees. 2D shape signatures of each individual 
%           crumple will be saved in ".mat" files in "signatures/". 
%           (unit: voxel)
%           
%           2D shape signature plots: images in tiff format showing the plotted
%           2D shape signatures with coresponding colorbars. The plots will be 
%           saved in "signature plots/"
% 
% NOTE:     The speed of shape signature extraction depends on the number
%           of meshes in the wavefront models. The speed can be increased 
%           by simplifying the wave front models. In this example the shape 
%           signatures are NOT horizontally shifted.
%
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021

addpath('utils')
folder = 'obj';
files = dir(folder);
for i = 1 :length(files)
    name = files(i).name;

    if name(end)=='j'
            disp([name,': ',num2str(i)])
        shape = readObj([folder,'/',name]);
        %%%
        info = imfinfo(['images/',name(1:end-4),'.tif']);
        W = info(1).Width;
        H = info(1).Height;
        D = length(info);
        I3D = nan([H,W,D]);
        for k = 1:D
            I3D(:,:,k) = imread(['images/',name(1:end-4),'.tif'],k );
        end
        [x,y,z] = ind2sub(size(I3D),find(I3D >128 ));
        centroid = mean([y,x,z],1);
        %%%%
        signature = signature_extractor(shape,centroid);
        save(['signatures/',name(1:end-4),'.mat'],'signature')
        figure(1);clf;
        set(gcf,'color','w');
        set(gcf,'position',[200 200 181*3 91*3])
        set(gca,'position',[0.15 0.2 .7 .7])
        imagesc(flipud(signature))
        h = colorbar();
        ylabel(h, 'd(\theta,\phi) (voxels)')
        axis on
        axis equal
        xticks(1:60:181)
        xticklabels({'0','120','240','360'})
        xlabel('\phi (degrees)')
        yticks(1:30:91)
        yticklabels({'0','60','120','180'})
        ylabel('\theta (degrees)')
        xlim([.5,181.5])
        ylim([.5,91.5])
        drawnow
        saveas(gcf,['signature plots/',name(1:end-4),'.tif'])
    end
end
