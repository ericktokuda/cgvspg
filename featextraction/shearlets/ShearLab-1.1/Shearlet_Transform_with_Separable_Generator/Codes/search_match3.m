function [d flag s] = search_match3(dd1,dd2,n)

% SEARCH_MATCH3   
%
% Usage :
%	[d flag s] = search_match3(d1,d2,n)
%
% Input:
%   d1:     directional components (2d arrays) consisting in shearlet coeff
%           associated with shear matrix [1 1; 0 1] for the horizontal cone
%   d2:     directional components (2d arrays) consisting in shearlet coeff
%           associated with shear matrix [1 0; 1 1] for the vertical cone
%   n:      number of most significant coefficients in each directional 
%           component
%
% Output:
%   d:	    one of directional component among all components in d1 and d2
%           such that the norm of n most significant coeff is largest 
%   flag:   binary image which indicates location of each of n most 
%           significant coeff in the selected component d
%   s:      row vector of the form s = [k f num]
%           k & f: indices for d ( for example, if f = 1 and k = k0 
%                                  then d = d1(:,:,k0);
%                                  on the other hand, if f = 2 and k = k1 
%                                  then d = d2(:,:,k1); )
%           num:  number of most significant coeff
%   n:      number of most significant coefficients to keep in d           
%
%      
% See also: SELECT_COEFF

% check size of input data
m(1) = size(dd1,1);
m(2) = size(dd1,2);
m(3) = size(dd1,3);

s1 = zeros(2*m(3),2);

% compute the norm of n most significant coeff in each directional component
% in dd1 and dd2
for k = 1:m(3)
    [temp1 thr1] = select_coeff(dd1(:,:,k),n); 
    [temp2 thr2] = select_coeff(dd2(:,:,k),n); 
    temp1 = temp1(:); 
    temp2 = temp2(:);
    s1(k,:) = [norm(temp1(:)) thr1];
    s1(k+m(3),:) = [norm(temp2(:)) thr2];
end

% find a directional component d among all components in dd1 and dd2 
% such that the norm of n most significant coeff is largest
% and then save the corresponding index info for d
[T1 index] = max(s1(:,1)); thr = s1(index,2);

if index > m(3) && index < 2*m(3)+1 
    s(1) = index - m(3); s(2) = 2; 
    flag = (abs(dd2(:,:,s(1)))>thr);
    num = sum(sum(flag));
    d = dd2(:,:,s(1)).*flag;
else 
    s(1) = index; s(2) = 1;
    flag = (abs(dd1(:,:,s(1)))>thr);
    num = sum(sum(flag));
    d = dd1(:,:,s(1)).*flag;
end
s(3) = num;

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

