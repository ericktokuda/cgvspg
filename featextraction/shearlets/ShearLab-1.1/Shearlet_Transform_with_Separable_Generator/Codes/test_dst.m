function [x num] = test_dst(image,scale,n,qmf1,qmf2)

% this is extended shearlet transform with only two directions (vertical 
% and horizontal)
%
% Usage:  [y num] = test_dst(im,scale,N,qmf1,qmf2)
%
% Note:
% this routine is basically equivalent to applying the 
% following two commands but this is slightly faster
%
% 1) [c flag s num] = MP_DST(x,qmf1,qmf2,N,1,scale,-1)
% 2) y = recon_MP_DST(c,flag,s,qmf1,qmf2,1,scale,-1)
%
% Input:
%  im:  input image
%  scale: size of shearlets at each scale (see sampled_DST.m)
%  N:  total number of nonzero coefficients which will be used for 
%      image approximation
%  qmf1 & qmf2: 1D Quadrature mirror filters (see sampled_DST.m)
%
% Output:
%  y: reconstructed image
%  num: total number of nonezero coeff used for image approx
%

image = double(image);

% apply anisotropic wavelet transform with scaling diag(2^(L-j),2^(L-s(j)))  
wc1 = wp_aniso_dwt(image,scale,qmf1,qmf2,1);
% apply anisotropic wavelet transform with scaling diag(2^(L-s(j)),2^(L-j))  
wc2 = wp_aniso_dwt(image,scale,qmf1,qmf2,0);
% hard thresholding to keep n most significant coeff 
[y1 thr num1] = select_coeff(wc1,n);
[y2 thr num2] = select_coeff(wc2,n);
% select directional component with higher energy among two directions (horizontal & vertical)
if norm(y1(:)) > norm(y2(:))
    t = 1; num = num1;wc = y1;
else
    t = 0; num = num2;wc = y2;
end
% reconstruction
x = adj_wp_aniso_dwt(wc,scale,qmf1,qmf2,t);

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

