function [c flag1 ss num] = MP_DST(image,qmf1,qmf2,N,iter,scale,ndir)

% MP_DST  Image Approximation using Matching Pursuit with shearlets 
%
% Usage:
%	[y flag s num] = MP_DST(x,qmf1,qmf2,N,iter,scale,ndir)
% Input:
%   x:      input image
%
%   For j = 1,...,L (where L = size of input vector 'scale'),
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%
%      N: row vector of the form [N(1),...,N(iter)]
%         N(i) is the number of nonzero coefficients produced in each 
%         MP iteration
%         total number of nonzero coefficients = N(1)+...+N(iter)
%   iter: number of iterations in MP step
%
%   scale : row vector consisting of sizes of shearlets across scales 
%           scale =  [s(1),...,s(L)].
%   For the horizontal cone associated with shear matrix [1 1;0 1],
%   the value s(j) determines the size of shearlets : 
%   2^(-1*(L-j)) by 2^(-1*(L-s(j))) at jth scale.
%   For the vertical cone associated with shear matrix [1 0;1 1],
%   the value s(j) determines the size of shearlets : 
%   2^(-1*(L-s(j))) by 2^(-1*(L-j)) at jth scale.
%   For example, when scale = [3 3 4 4 5],   
%   size of support = 2^(-4) by 2^(-2) at the finest scale
%   size of support = 2^(-3) by 2^(-2) at the second scale
%   size of support = 2^(-2) by 2^(-1) at the third scale
%   size of support = 2^(-1) by 2^(-1) at the fourth scale
%   size of support = 2^(0) by 2^(0) at the coarsest scale
%   for the horizontal cone. 
%
%   ndir:      number of directions = 2^(ndir+2)+2; 
%   Note:      ndir = -1 ---> only two directions (horizontal and vertical)          
%
% Output:
%   y:    3D array consisting of n 2D arrays and each of those  
%         2D arrays contains N(i) nonzero coefficients produced in 
%         ith MP iteration (here n = iter : number of MP iterations)
%   flag: 3D binary array consisting of n 2D arrays and each of those 
%         2D arrays indicates locations of N(i) nonzeros coefficients 
%         produced in ith MP iteration 
%         (here n = iter : number of iterations)
%   s:    row vector of the form s = [k f num] 
%         ( see search_match3.m for description )
%   num:  total number of nonzero coefficients used for image approximation
%
%      
% See also: SAMPLED_DST, SEARCH_MATCH3, GOP1

% initialize
dd = double(image);
num = zeros(iter,1);
q = 0;
ss = zeros(iter,3);

for j = 1:iter
    % take extended shearlet transform to produce 2^(ndir+2)+2
    % directional components in 3D arrays dd1 and dd2
    % NOTE: when ndir < 0, only two directions (horizontal & vertical)
    [dd1 dd2] = sampled_DST(dd,qmf1,qmf2,scale,ndir);
    % find a directional component d whose N(j) most significant 
    % coefficients have the largest energy
    % and then apply thresholding to keep only those N(j) coefficients 
    [d flag s] = search_match3(dd1,dd2,N(j));
    % updating number of nonzero coefficients produced in each MP iteration
    num(j) = s(3)+q;
    % save thresholded coefficients in each MP iteration
    c(:,:,j) = d;
    % save 2D binary array indicating locations of the N(j) nonzero coeff
    % in each MP iteration
    flag1(:,:,j) = flag;
    % save index information for the selected directional component d 
    % in each MP iteration
    ss(j,:) = s;
    if j < iter
        % compute residual in each MP iteration
        dd1 = Gop1(d,scale,ndir,qmf1,qmf2,s(2),s(1));
        q = num(j);
        dd = dd-dd1;
    end      
end
% save total number of nonzero coeff used for image approximation
num = num(iter);


%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

