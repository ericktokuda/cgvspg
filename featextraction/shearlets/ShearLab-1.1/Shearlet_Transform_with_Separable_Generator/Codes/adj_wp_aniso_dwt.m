function x = adj_wp_aniso_dwt(wc,scale,qmf1,qmf2,dir)

% ADJ_WP_ANISO_DWT -- Inverse Anisotropic Discrete Wavelet Transform 
%
% Usage:
%    y = adj_wp_ansio_dwt(x,scale,qmf1,qmf2,x_y) 
%
% Input:
%   x:      ansiotropic wavelet coefficients
%   scale : row vector consisting of sizes of wavelets across scales 
%           scale =  [s(1),...,s(L)] (see wp_ansio_dwt.m)
%
%   For j = 1,...L,
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%
%   For j = 1,...,L, 
%   x_y = 1: take anisotropic wavelets with scaling diag(2^(L-j),2^(L-s(j)))
%   x_y = 0: take anisotropic wavelets with scaling diag(2^(L-s(j)),2^(L-j))
%
% Output :
%   y : reconstructed image from anisotropic wavelet coeff
%
% Description
%   inverse of wp_aniso_dwt.m  
%              
%
% See Also
%    wp_ansio_dwt.m, rec_wp_decomp1.m 

% For j = 1,...,L,
% if dir = 0, then take inverse (ansiotropic) wavelet transfom with scaling
% diag(2^(L-s(j)),2^(L-j)). 
% If dir = 1, then take inverse (ansiotropic) wavelet transfom with scaling
% diag(2^(L-j),2^(L-s(j))). 
if dir == 0 
    wc = wc';
end

% check size of input image
[n1 n2] = size(wc);
J1 = log2(n1); J2 = log2(n2);
x = zeros(n1,n2); temp = zeros(n1,n2);
L = length(scale);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% take inverse (ansiotropic) wavelet transfom with scaling diag(2^(L-j),2^(L-s(j)))
% if dir = 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% take inverse 1D wavelet packet transform for finest frequency partition 
% at each scale scale(k) along the vertical direction
temp = rec_wp_decomp1(wc,scale,qmf2);
m = n2/2^(L);
for j = 1:m
    temp(:,j) = IDWT_PO(wc(:,j)',J1-L,qmf1)';
end
for j2 = 1:n1
    % take inverse 1d wavelet transform along the horizontal axis
    x(j2,:) = IDWT_PO(temp(j2,:),J2-L,qmf1);
end

if dir == 0 
    x = x';
end


%
%  Copyright (c) 2010. Wang-Q Lim, University of Osnabrueck
%
%  Part of ShearLab Version 1.0
%  Built Sun, 07/04/2010
%  This is Copyrighted Material
%  For Copying permissions see COPYRIGHT.m
