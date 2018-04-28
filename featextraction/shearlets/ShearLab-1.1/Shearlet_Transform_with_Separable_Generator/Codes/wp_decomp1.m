function wp = wp_decomp1(img,scale,qmf)

wp = wp_decomp1(img,scale,qmf);

% WP_DECOMP1-- Wavelet Packet Decomposition
%
%  Usage
%    wp = wp_decomp1(x,scale,qmf) 
%  Inputs
%    x        2^J1 by 2^J2 input image
%    scale    row vector of the form scale = [s(1),...s(L)] 
%             each entry s(j) determines degree of finest frequency partition
%             for each  2^J1 by 2^(J2-s(j)) submatrix of the input image. 
%
%    qmf      orthonormal quadrature mirror filter 
%  Outputs
%    wp       2d array consisting of Wavelet Packet
%             Coefficients for finest frequency interval
%             [b/2^(scale(j)),(b+1)/2^(scale(j))] for each jth submatrix 
%             of the input image x
%
%  Description
%              Take finest frequency partition from 
%              Dyadic table of all Wavelet Packet coefficients
%
%  See Also
%    rec_wp_decomp1
%
%
%  Note : WPAnalysis.m (from WaveLab850) is slightly modified to take 
%         only finest frequency partion from Dyadic table of all Wavelet
%         Packet coefficients
% 


%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

