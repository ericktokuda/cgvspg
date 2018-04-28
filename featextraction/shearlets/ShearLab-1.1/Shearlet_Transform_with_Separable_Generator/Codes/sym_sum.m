function out = sym_sum(image,mode)
% SYM_SUM   Symmetric Summation
%
% Usage:
%	y = sym_sum(x, mode)
%
% Input:
%   x:      output image
%   mode:   mode = 0 then obtain N1 by N2 original image from N1 by 2*N2 
%           reflected (vertically) image x
%           mode = 1 then obtain N1 by N2 original image from 2*N1 by N2
%           reflected (horizontally) image x
% Output
%   y:      unfolded image 


if mode == 0 
    [n,m] = size(image);
    out = image(:,1:m/2) + fliplr(image(:,m/2+1:m));
else
    [n,m] = size(image);
    out = image(1:n/2,:) + flipud(image(n/2+1:n,:));
end

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

