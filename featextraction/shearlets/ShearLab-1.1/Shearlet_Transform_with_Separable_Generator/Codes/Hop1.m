function d = Hop1(image,flag,scale,ndir,qmf1,qmf2,nn,k)

% HOP1  Sheared Anisotropic Wavelet Transform with Thresholding
%       ( for a given image, apply thresholding for one specified 
%         directional component according to predetermined zero map ) 
%
% Usage: d = Hop1(x, flag, scale, ndir, qmf1, qmf2, x_y, k)
%
% Input:
%   x: input image
%   flag : 2D binary image indicating location of nonzero coeff (zero map) 
%   scale: size of shearlets at each scale (see sampled_DST.m)
%   ndir:  number of directions (see sampled_DST.m)
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j))
%   (see sampled_DST.m and MakeONFilter.m in WaveLab )
%   x_y & k: indices for 2^(ndir+2)+2 directional components from 
%            (extended) shearlet transform (sampled_DST.m)
%            for example, 
%            1) x_y = 1 & k = 7 ---> 7th directional component
%               associated with shear matrix [1 k/2^(ndir); 0 1]
%            2) x_y = 2 & k = 7 ---> 7th directional component
%               associated with shear matrix [1 0; k/2^(ndir) 1] 
%
% Output:
%   d: one thresholded directional component associated with indexes 
%      x_y & k



if nn == 1
    d = flag.*wp_aniso_dwt(dshear(image,k-(2^ndir+1),0,ndir,1),scale,qmf1,qmf2,1);
else          
    d = flag.*wp_aniso_dwt(dshear(image,k-(2^ndir+1),1,ndir,1),scale,qmf1,qmf2,0);
end
    
%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

    

    