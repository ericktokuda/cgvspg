function x = Gop1(d,scale,ndir,qmf1,qmf2,nn,k)

% GOP1   Inverse Sheared Anisotropic Wavelet Transform  
%        ( reconstruction using coeff in one of directional components from 
%          (extended) shearlet transform )
%
% Usage :
%	y = GOP1(d, scale, ndir, qmf1,qmf2, x_y, k)
%
% Input:
%   d: one of directional components from extended shearlet transfom (sampled_DST.m)      
%   scale: size of shearlets at each scale (see sampled_DST.m)
%   ndir:  number of directions (see sampled_DST.m)
%
%   For j = 1,..,L (where L = size of input vector 'scale')
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%   x_y & k: indices for 2^(ndir+2)+2 directional components from 
%            (extended) shearlet transform (sampled_DST.m)
%            for example, 
%            1) x_y = 1 & k = 7 ---> 7th directional component
%               associated with shear matrix [1 1; 0 1]
%            2) x_y = 2 & k = 7 ---> 7th directional component
%               associated with shear matrix [1 0; 1 1] 
% Output:
%   y:  reconstructed image from one of directional components
%       associated with idices x_y & k



if nn == 1
    x = dshear(adj_wp_aniso_dwt(d,scale,qmf1,qmf2,1),k-(fix(2^ndir)+1),0,ndir,0);      
else 
    x = dshear(adj_wp_aniso_dwt(d,scale,qmf1,qmf2,0),k-(fix(2^ndir)+1),1,ndir,0);
end

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m
