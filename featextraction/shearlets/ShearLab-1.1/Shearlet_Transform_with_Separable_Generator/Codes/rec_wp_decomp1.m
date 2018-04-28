function x = rec_wp_decomp1(img,scale,qmf)

 x = rec_wp_decomp1(img,scale,qmf);

% REC_WP__DECOMP1 -- Reconstruction from Wavelet Packet Decomposition
%
%  Usage
%    y = rec_wp_decomp1(x,scale,qmf) 
%  Inputs
%    x        2^J1 by 2^J2 input image 
%    scale    row vector of the form scale = [s(1),...s(L)] 
%             each entry s(j) determines degree of finest frequency partition
%             for each  2^J1 by 2^(J2-s(j)) submatrix of the input image.
%
%    qmf      orthonormal quadrature mirror filter 
%  Outputs
%    y        reconstructed 2d image from wavelet packet coeff 
%             for finest freuency partition
%  Description
%             Inverse of wp_decomp1
%  See Also
%    wp_decomp1
%
%  Note : This is a modified version of IPT_WP from WaveLab850
%         IPT_WP is slightly modified. 

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m







