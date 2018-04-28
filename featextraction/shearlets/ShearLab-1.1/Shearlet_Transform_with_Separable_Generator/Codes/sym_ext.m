function out = sym_ext(image,mode)

% SYM_EXT   Symmetric Extension
%
% Usage:
%	y = sym_ext(x, mode)
%
% Input:
%   x:      input image
%   mode:   mode = 0 then apply a vertical reflection
%           mode = 1 then apply a horizontal reflection 
% Output
%   y:      extended image from input image x
%           for N by N image x,  
%           mode = 0 then size of y is N by 2N
%           mode = 1 then size of y is 2N by N
%
% Note : This reduces artificial singularities due to shearing

[n,m] = size(image);

if mode == 0
% apply a vertical reflection 
out = [image fliplr(image)]; 
else
% apply a horizontal reflection
out = [image; flipud(image)];
end



%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

