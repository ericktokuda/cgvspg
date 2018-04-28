function aa = half_adj_sampled_DST1(dd,qmf1,qmf2,scale,ndir,h_v)

% HALF_ADJ_SAMPLED_DST1 Inverse Extended Shearlet Transform associated
%                       with only one type of shear matrix [1 1; 0 1] (or [1 0; 1 1])
%                       ( reconstruct an image from 2^(ndir+1)+1 directional 
%                         components )
%
% Usage:
%   y = half_adj_sampled_DST1(d, qmf1, qmf2, scale, ndir, x_y)
%
% Input:
%   d : 1) if x_y = 0 --->
%          2^(ndir+1)+1 directional components assoicated with shear matrices 
%          [1 k/2^(ndir); 0 1] for k = -2^(ndir),...,2^(ndir)
%       2) if x_y = 1 --->
%          2^(ndir+1)+1 directional components assoicated with shear matrices 
%          [1 0; k/2^(ndir) 1] for k = -2^(ndir),...,2^(ndir)
%
%   For j = 1,...,L (where L = size of input vector 'scale')
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%
%   scale : row vector consisting of sizes of shearlets across scales 
%           scale =  [s(1),...,s(L)] (see sampled_DST.m)
%
%   ndir:   number of directions = 2^(ndir+1)+1;
%   x_y:    x_y = 0 or 1, which determines type of shear matrix
%
% Output:
%   y:      reconstructed image from 2^(ndir+1)+1 directional components

[m n] = size(dd(:,:,1));
aa = zeros(m,n); 

if h_v == 0 
    for k = 1:2^(ndir+1)+1
        aa = aa + dshear(adj_wp_aniso_dwt(dd(:,:,k),scale,qmf1,qmf2,1),(k-(2^ndir+1)),0,ndir,0); 
        %aa = aa +
        %iddshear(adj_wp_aniso_dwt(dd(:,:,k),scale,qmf1,qmf2,1),(k-(2^ndir+1)),0,ndir); 
    end             
else 
    for k = 1:2^(ndir+1)+1
        aa = aa + dshear(adj_wp_aniso_dwt(dd(:,:,k),scale,qmf1,qmf2,0),(k-(2^ndir+1)),1,ndir,0);
        %aa = aa + iddshear(adj_wp_aniso_dwt(dd(:,:,k),scale,qmf1,qmf2,0),(k-(2^ndir+1)),1,ndir);
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
