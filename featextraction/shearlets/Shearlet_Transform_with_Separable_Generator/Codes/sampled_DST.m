function  [dd1 dd2] = sampled_DST(image,qmf1,qmf2,scale,ndir)

% SAMPLED_DST   Extended Discrete Shearlet Transform 
%
%                     ( compute shearlet coefficients to produce 
%                       directional components so that each of those 
%                       components contains shearlet coefficients 
%                       associated with the corresponding shearing )
%
%	[d1 d2] = sampled_DST(x, qmf1,qmf2, scale, ndir)
%
% Input:
%   x:      input image
%
%   For j = 1,...,L (where L = size of input vector scale = [s(1),...,s(L)]), 
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%
%   scale : row vector consisting of sizes of shearlets across scales 
%           scale =  [s(1),...,s(L)].
%
%   For the horizontal cone associated with shear matrix [1 1;0 1],
%   the value s(j) determines the size of shearlets : 
%   For j = 1,...,L, 2^(-1*(L-j)) by 2^(-1*(L-s(j))) at jth scale.
%
%   For the vertical cone associated with shear matrix [1 0;1 1],
%   the value s(j) determines the size of shearlets : 
%   For j = 1,...,L, 2^(-1*(L-s(j))) by 2^(-1*(L-j)) at jth scale.
%
%   For example, when scale = [3 3 4 4 5],   
%   size of support = 2^(-4) by 2^(-2) at the finest scale
%   size of support = 2^(-3) by 2^(-2) at the second scale
%   size of support = 2^(-2) by 2^(-1) at the third scale
%   size of support = 2^(-1) by 2^(-1) at the fourth scale
%   size of support = 2^(0) by 2^(0) at the coarsest scale
%   for the horizontal cone. 
%
%   ndir:    number of directions = 2^(ndir+2)+2;
%   Note:    ndir = -1 ----> only two directions (horizontal and vertical)            
%
% Output:
%   d1 & d2:   2^(ndir+1)+1 matrices and each of them consists of  
%              shearlet coefficients associated with each direction. 
%   d1 :  2^(ndir+1)+1 directional components assoicated with shear matrices 
%         [1 k/2^(ndir); 0 1] for k = -2^(ndir)...2^(ndir) 
%         (for the horizontal cone)
%   d2 :  2^(ndir+1)+1 directional components assoicated with shear matrices 
%         [1 0; k/2^(ndir) 1] for k = -2^(ndir)...2^(ndir)
%         (for the vertical cone)
%
% Note:
%   1) This routine perfomrs 2^(ndir+2)+2 directional orthogonal 
%      transforms. 
%      ( ndir = -1 ---> only two directional (horizontal and vertical)
%      orthogonal transforms )
%   2) in order to obtain parabolic scaling of the form 
%      diag(2^j,2^(j/2)) or diag(2^(j/2),2^j), input parameter    
%      scale needs to be chosen appropriately  
%      (eg. scale = [3 3 4 4 5],...)
%
% See also: WP_ANISO_DWT, DSHEAR, HALF_SAMPLED_DST1


aa = double(image);  %input image
[row col] = size(image);
dd1 = zeros(row,col,2^(ndir+1)+1);
dd2 = zeros(row,col,2^(ndir+1)+1);

for k = fix(-2^(ndir)):fix(2^(ndir))
      % compute shearlet coefficients across all scales for each shear
      % matrix [1 k/2^ndir;0 1]
      dd1(:,:,k+fix(2^(ndir))+1) = wp_aniso_dwt(dshear(aa,k,0,ndir,1),scale,qmf1,qmf2,1);
      % compute shearlet coefficients across all scales for each shear
      % matrix [1 0;k/2^ndir 1]
      dd2(:,:,k+fix(2^(ndir))+1) = wp_aniso_dwt(dshear(aa,k,1,ndir,1),scale,qmf1,qmf2,0);
      
end                     
                    
%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

