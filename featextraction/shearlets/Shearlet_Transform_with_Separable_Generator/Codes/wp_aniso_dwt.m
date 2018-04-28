function wc = wp_aniso_dwt(image,scale,qmf1,qmf2,dir)

% WP_ANISO_DWT -- Anisotropic Discrete Wavelet Transform 
%
% Usage:
%	y = wp_aniso_dwt(x, scale, qmf1, qmf2, x_y)
%
% Input:
%   x:      input image
%   scale : row vector consisting of sizes of wavelets across scales 
%           scale =  [s(1),...,s(L)].
%   When x_y = 1, the value s(j) determines the size of wavelets : 
%   For j = 1,...,L, 2^(-1*(L-j)) by 2^(-1*(L-s(j))) at jth scale. 
%
%   When x_y = 2, the value s(j) determines the size of wavelets : 
%   For j = 1,...,L, 2^(-1*(L-s(j))) by 2^(-1*(L-j)) at jth scale. 
%
%   For example, when scale = [3 3 4 4 5],   
%   size of support = 2^(-4) by 2^(-2) at the finest scale
%   size of support = 2^(-3) by 2^(-2) at the second scale
%   size of support = 2^(-2) by 2^(-1) at the third scale
%   size of support = 2^(-1) by 2^(-1) at the fourth scale
%   size of support = 2^(0) by 2^(0) at the coarsest scale
%   when x_y = 1. 
%
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%         ( see MakeONFilter.m in WaveLab )
%
%   x_y = 1: take anisotropic wavelets with scaling diag(2^(L-j),2^(L-s(j))
%   x_y = 0: take anisotropic wavelets with scaling diag(2^(L-s(j)),2^(L-j))
%
%   Note : in order to obtain parabolic scaling of the form 
%          diag(2^j,2^(j/2)) or diag(2^(j/2),2^j), input parameter    
%          scale needs to be chosen appropriately  
%          (eg. scale = [3 3 4 4 5]...)
%
% Output:
%   y:	    anisotropic wavelet coefficients associated with  
%   with scaling matrix diag(2^(L-j),2^(L-s(j))) (when x_y = 1) or 
%   diag(2^(L-s(j)) 2^(L-j)) (when x_y = 0).
%
%      
% See also: WP_DECOMP1, SAMPLED_DST, ADJ_WP_ANISO_DWT

% If dir = 0, then take (ansiotropic) wavelet transfom with scaling
% diag(2^(L-s(j)),2^(L-j)). 
% If dir = 1, then take (ansiotropic) wavelet transfom with scaling
% diag(2^(L-j),2^(L-s(j))). 
if dir == 0 
    image = image';
end

% check size of input image
[n1 n2] = size(image);
J1 = log2(n1); J2 = log2(n2);
wc = zeros(n1,n2); temp = zeros(n1,n2);
L = length(scale);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% take anisotropic wavelet transform with scaling matrix diag(2^(L-j),2^(L-s(j)))
% if dir = 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j1 = 1:n1
    % take 1D wavelet transform along the horizontal direction 
    temp(j1,:) = DWT_PO(image(j1,:),J2-L,qmf1);
end
% take 1D wavelet packet transform for finest frequency partition at each 
% scale 2^(L-scale(j)) along the vertical direction
wc = wp_decomp1(temp,scale,qmf2);
m = n2/(2^L);
for j3 = 1:m          
    wc(:,j3) = DWT_PO(temp(:,j3)',J1-L,qmf1)';
end

if dir == 0 
    wc = wc';
end


%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

