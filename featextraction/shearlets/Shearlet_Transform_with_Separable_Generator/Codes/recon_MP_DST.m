function x = recon_MP_DST(c,flag1,ss,qmf1,qmf2,iter,scale,ndir)

% recon_MP_DST  Image Approximation using Matching Pursuit with shearlets 
%               ( reconstruct an image from shearlet coefficients in 
%                 MP iterations ) 
%
% Usage:
%	y = recon_MP_DST(c,flag,s,qmf1,qmf2,iter,scale,ndir)
% Input:
%   c:    3D array consisting of n 2D arrays and each of those  
%         2D arrays contains N(j) nonzero coefficients produced in 
%         jth MP iteration (here n = iter : number of MP iterations)
%   flag: 3D binary array consisting of n 2D arrays and each of those 
%         2D arrays indicates locations of N(j) nonzeros coefficients 
%         produced in jth MP iteration 
%         (here n = iter : number of iterations)
%   s:    row vector of the form s = [k f num] 
%         ( see search_match3.m for description )
%   iter: number of iterations in MP step
%   scale : row vector consisting of sizes of the support of shearlets across scales 
%           scale =  [s(1),...,s(L)] ( see sampled_DST.m )
%   ndir:      number of directions = 2^(ndir+2)+2; 
%   Note:      ndir = -1 ---> only two directions (horizontal and vertical)          
%
% Output:
%   y:    reconstructed image from the shearlet coefficients in MP iterations 
%      
% See also: MP_DST, SAMPLED_DST, GOP1, HOP1

% check size of image which will be reconstructed
[n J] = quadlength(c(:,:,1));
dd = zeros(n);

    for j = iter:-1:1
        temp = ss(j,:);
        % check index for directional component used in each MP iteration
        % this idex information is a parameter for each shearing 
        k = temp(1); nn = temp(2); 
        % reconstruct an image from MP iterations
        if j > 1
            d = Hop1(dd,flag1(:,:,j),scale,ndir,qmf1,qmf2,nn,k);
            d = Gop1(c(:,:,j)-d,scale,ndir,qmf1,qmf2,nn,k);
        else 
            d = Gop1(c(:,:,j),scale,ndir,qmf1,qmf2,nn,k);
        end
        dd = d+dd;          
    end
    x = dd;



    
    
    
    

