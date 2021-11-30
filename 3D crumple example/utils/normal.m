% NAME:     this function computes the normal of one triangular mesh grid.
% INPUT:    mesh: 3x3 matrix containing the coordinates 3 vertices of one
%           mesh. Rows corespond to dimensions x, y, z. Columns coresponds 
%           to vertices 1, vertices 2, vertices 3.
% OUTPUT:   n: Mesh normal. Normalized normal of the mesh in 3x1 array.
% 
% HISTORY:  Written by Lehan Yao
% Last modified by Lehan Yao on 06/07/2021

function n=normal(mesh)
v1=mesh(:,2)-mesh(:,1);
v2=mesh(:,3)-mesh(:,1);
n=cross(v1,v2);
n=n/norm(n);
%scatter3(mesh(2,1),mesh(2,2),mesh(2,3))
%fill3(mesh(:,1),mesh(:,2),mesh(:,3),1)
end