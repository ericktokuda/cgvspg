function dd = half_sampled_DST1(image,qmf1,qmf2,scale,ndir,h_v)


% HALF_SAMPLED_DST1   Extended Discrete Shearlet Transform associated
%                     with only one type of shear matrix [1 1; 0 1] (or [1 0; 1 1])
%                     ( compute shearlet coefficients to produce 
%                       directional components so that each of those 
%                       components contains shearlet coefficients 
%                       associated with the corresponding shearing )
%
% Usage:
%	d = half_sampled_DST1(x, qmf1,qmf2, scale, ndir,x_y)
%
% Input:
%   x:      input image
%
%   For j = 1,...,L (where L = size of input vector 'scale'),
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%
%   scale : row vector consisting of sizes of shearlets across scales 
%           scale =  [s(1),...,s(L)] (see sampled_DST.m)
%
%   ndir:   number of directions = 2^(ndir+1)+1;
%   x_y:    see Output
%
% Output:
%   d : 1) if x_y = 0 --->
%          2^(ndir+1)+1 directional components assoicated with shear matrices 
%          [1 k/2^(ndir); 0 1] for k = -2^(ndir),...,2^(ndir)
%       2) if x_y = 1 --->
%          2^(ndir+1)+1 directional components assoicated with shear matrices 
%          [1 0; k/2^(ndir) 1] for k = -2^(ndir),...,2^(ndir)
%
%   Note : in order to obtain parabolic scaling of the form 
%          diag(2^j,2^(j/2)) or diag(2^(j/2),2^j), input parameter    
%          scale needs to be chosen appropriately  
%          (eg. scale = [3 3 4 4 5],...)



aa = double(image);
[row col] = size(image);
dd = zeros(row,col,2^(ndir+1)+1);
for k = -2^(ndir):2^(ndir)
        if h_v == 0
            dd(:,:,k+2^(ndir)+1) = wp_aniso_dwt(dshear(aa,k,0,ndir,1),scale,qmf1,qmf2,1);
            %dd(:,:,k+2^(ndir)+1) =
            %wp_aniso_dwt(ddshear(aa,k,0,ndir),scale,qmf1,qmf2,1);
        else
            dd(:,:,k+2^(ndir)+1) = wp_aniso_dwt(dshear(aa,k,1,ndir,1),scale,qmf1,qmf2,0);
            %dd(:,:,k+2^(ndir)+1) = wp_aniso_dwt(ddshear(aa,k,1,ndir),scale,qmf1,qmf2,0);
        end
end                     

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m
