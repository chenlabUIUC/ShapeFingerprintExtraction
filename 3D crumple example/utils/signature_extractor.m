% NAME:     this function computes the 2D shape signature from a wavefront
%           format-like 3D shape model.
%
% INPUT:    shape: a struct describing the 3D model.
%                  shape.v - mesh vertices
%                  shape.f - face definition assuming faces are made of of 3 vertices
%
%           centoird: the 3D geometrical centroid (1x3) of this shape. 
%
% NOTE:     this function DOES NOT horizontally shift the signature.
%
% OUTPUT:   signature: 91x181 matirx containing the 2D shape signature 
%           d(theta,phi). The range of theta is [0:180] degrees with an 
%           interval of 2 degrees. The range of phi is [0:360] degrees
%           with an interval of 2 degrees.
% 
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021

function signature = signature_extractor(shape,centroid)
    v = shape.v;
    f = shape.f.v;
    th = 0:2:180;
    x2D = cosd(th);
    y2D = sind(th);
    z2D = x2D*0;
    Rx = [cosd(90) 0 -sind(90);
            0 1 0 ;
            sind(90) 0  cosd(90)];
    vector_theta = [x2D',y2D',z2D']*Rx;
    phis = [0:2:360];
    vector_matirx_x = zeros([91,181]);
    vector_matirx_y = zeros([91,181]);
    vector_matirx_z = zeros([91,181]);
    for i = 1:181
        phi = phis(i);
        Rz = [cosd(phi) -sind(phi) 0; 
              sind(phi) cosd(phi) 0; 
              0 0 1 ];
        vector_phi = vector_theta*Rz;
        vector_matirx_x(:,i) = vector_phi(:,1);
        vector_matirx_y(:,i) = vector_phi(:,2);
        vector_matirx_z(:,i) = vector_phi(:,3);
    end
signature = zeros(91,181);
%     figure(1);clf;hold on
%     axis equal

%     for k = 1 : length(f)
%                mesh = v(f(k,:)',:);
%                fill3(mesh(:,1),mesh(:,2),mesh(:,3),1)
% 
%     end
  
    for i = 1:91
        disp(i)
       for j = 1:181
           %quiver3(centroid(1),centroid(2),centroid(3),vector_matirx_x(i,j)*20,vector_matirx_y(i,j)*20,vector_matirx_z(i,j)*20)
           inter_sec = [];
           for k = 1 : length(f)
               mesh = v(f(k,:)',:)';
               n = normal(mesh);
               [I,check] = plane_line_intersect(n',mesh,centroid,[vector_matirx_x(i,j),vector_matirx_y(i,j),vector_matirx_z(i,j)]);
               if check==1
                   inter_sec = [inter_sec,norm(I-centroid)];
               end
           end
        inter_sec = sort(inter_sec);
        if mod(length(inter_sec),2)
           inter_sec = [0,inter_sec];
           signature(i,j) = sum(inter_sec(2:2:end)-inter_sec(1:2:end));
        else
           signature(i,j) = sum(inter_sec(2:2:end)-inter_sec(1:2:end));
        end
        
       end

    end

end