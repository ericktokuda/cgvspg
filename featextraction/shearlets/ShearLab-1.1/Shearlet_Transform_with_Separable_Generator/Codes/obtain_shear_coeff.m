function coeff = obtain_shear_coeff(img,scale,ndir,h_v,j,k,qmf1,qmf2)

% COEFF = OBTAIN_SHEAR_COEFF: obtain shearlet coefficients for fixed 
%                              scale j and shear parameter k.
% 
% Usage:
%   coeff = obtain_shear_coeff(img,scale,ndir,h_v,j,k,qmf1,qmf2)
%
% Input :
%   img :  input image
%   default option : Lena image 
%
%   For j = 1,...,L (where L = size input vector scale = [s(1),...,s(L)]),
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j)
%         default option : Symmlet with 4 vanishing moments 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%         default option : Symmlet with 4 vanishing moments
%   ( see MakeONFilter.m in WaveLab )
%
%   scale : row vector consisting of sizes of shearlets across scales 
%           scale =  [s(1),...,s(L)]
%           For N X N input image, L < log2(N)
%           
%           Choice for parabolic scaling (5 level decomposition): 
%           scale = [3 3 4 4 5]
%           if j = 1 then ndir = 2 and k = -4,-3...0...4.
%           if j = 2 then ndir = 2 and k = -4,-3...0...4.
%           if j = 3 then ndir = 1 and k = -2,-1...0...2.
%           if j = 4 then ndir = 1 and k = -2,-1...0...2.
%           if j = 5 then ndir = 0 and k = -1,0,1.
%
%   For the horizontal cone associated with shear matrix [1 1;0 1],
%   the value s(j) determines the size of the support of shearlets : 
%   2^(-1*(L-j)) by 2^(-1*(L-s(j))) at jth scale.
%   For the vertical cone associated with shear matrix [1 0;1 1],
%   the value s(j) determines the size of the support of shearlets : 
%   2^(-1*(L-s(j))) by 2^(-1*(L-j)) at jth scale.
%
%   For example, when scale = [3 3 4 4 5],   
%   size of support = 2^(-4) by 2^(-2) at the finest scale
%   size of support = 2^(-3) by 2^(-2) at the second scale
%   size of support = 2^(-2) by 2^(-1) at the third scale
%   size of support = 2^(-1) by 2^(-1) at the fourth scale
%   size of support = 2^(0) by 2^(0) at the coarsest scale
%   for the horizontal cone. 
%
%   ndir:   number of directions = 2^(ndir+1)+1;
%   h_v:    see Output
%           h_v = 'hor' : horizontal cone.
%           h_v = 'ver' : vertical cone.
%
%   j  :    index for scale --> j = 1,2,...,L (L = size of input vetor 'scale')
%           j = 1 : finest level 
%           j = L : coarsest level
%   k  :    index for shearing  --> -2^(ndir),...,0,1,2,...2^(ndir)
%
% Output:
%   coeff : shearlet coefficients for fixed scale j and shear index k.
%   
%   case1) h_v = 'hor' : compute shearlet coefficients associated with
%          shear [1 1; 0 1] for given input parameters j and k.
%          In this case, the corresponding shearlet elements are obtained 
%          by applying scaling matrix diag(2^(L-j),2^(L-s(j))) and 
%          shear matrix [1 k/2^(ndir); 0 1] on a separable wavelet generator 
%          w(x_1)s(x_2) where w(x_1) is 1d wavelet and s(x_2) is 1d scaling
%          function. 
%   case2) h_v = 'ver' : compute shearlet coefficients associated with
%          shear [1 0; 1 1] for given input parameters j and k.
%          In this case, the corresponding shearlet elements are obtained 
%          by applying scaling matrix diag(2^(L-s(j)),2^(L-j)) and 
%          shear matrix [1 0;  k/2^(ndir) 1] on a separable wavelet generator 
%          s(x_1)w(x_2) where w(x_2) is 1d wavelet and s(x_1) is 1d scaling
%          function. 
%   

if nargin < 8
    qmf2 = MakeONFilter('Symmlet',4);
end

if nargin < 7
    qmf1 = MakeONFilter('Symmlet',4);
end

if strcmp( h_v, 'hor' )
   %coeff = wp_aniso_dwt(dshear(img,k,0,ndir,1),scale,qmf1,qmf2,1);
   coeff = wp_aniso_dwt(ddshear(img,k,0,ndir),scale,qmf1,qmf2,1);
else
   %coeff = wp_aniso_dwt(dshear(img,k,1,ndir,1),scale,qmf1,qmf2,0);
   coeff = wp_aniso_dwt(ddshear(img,k,1,ndir),scale,qmf1,qmf2,0);
   coeff = coeff';
end

[row col] = size(coeff);
if row ~= col
    disp('Input image needs to be a square matrix');
    return;
end
L = length(scale);
if j < 0 || j > L 
    disp('scaling index j should be positive and j <= L')
    return;
end

coeff = coeff(1:row/(2^(scale(j))),col/2^j+1:col/(2^(j-1)));

if strcmp(h_v,'ver')
    coeff = coeff';
end

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m





