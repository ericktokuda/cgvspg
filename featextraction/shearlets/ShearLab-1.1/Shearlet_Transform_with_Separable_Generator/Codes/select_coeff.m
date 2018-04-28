function [y thr num] = select_coeff(x,n)

% SELECT_COEFF   
%
% Usage :
%	y = select_coeff(x,n)
%
% Input:
%   x:      input array
%   n:      number of samples to keep in x
%
% Output:
%   y:	    thresholded array so that only n most significant coeff 
%           are kept (all other entries are set to zeros) from the input array x
%   thr:    thresholding parameter for output y
%   num:    number of nonzero coeff in output array y
%
%


% Sort the coefficient in the order of energy.
temp = sort(abs(x(:)),'descend');

% Only keep n most significant coefficients
thr = abs(temp(n));
flag = (abs(x)>=thr);
num = sum(sum(flag));
y = x.*flag;

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

