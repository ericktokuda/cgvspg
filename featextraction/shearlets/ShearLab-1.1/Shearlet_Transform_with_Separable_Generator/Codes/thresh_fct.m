function y = thresh_fct(x,sigma,opt,t,diff)

% Soft Thresholding, Hard Thresholding, some other variants...
% Usage: y = thresh_fct(x,sigma,opt,t,diff)
% Input: 
%          x: input coeff
%        opt: choice for tresholding
%      sigma: standard deviation of Gaussian noise
%   t & diff: control parameters for other variants thresholdings
%
% Output: 
%          y:  thresholded coeff
% Note: for other variants, see reference paper
%       'The SURE-LET Approach to Image Denoising' 
%        by T. Blu, F. Luisier 

if opt == 0 
    if diff == 1
        y = 1;
    else
        y = x;
    end
elseif opt == 1
    if diff == 1
        y = (1-exp(-1*(x*1/t*1/sigma).^8))+x.*(exp(-1*x.^8*1/t^8*1/sigma^8).*x.^7*8/t^8*1/sigma^8);
    else
        y = x.*(1-exp(-1*(x*1/t*1/sigma).^8));
    end
% Hard Thresholding    
elseif opt == 2
    if diff == 1
        y = (abs(x)>t*sigma);
    else
        y = x.*(abs(x)>t*sigma);
    end
% Soft Thresholding
elseif opt == 3
   y = SoftThresh(x,t*sigma);
else
    if diff == 1
        y = exp(-x.^2*1/t*1/sigma^2)+x.*(exp(-x.^2*1/t*1/sigma^2).*x*2/t*-1*1/sigma^2);
    else
        y = x.*exp(-1/t*1/sigma^2*x.^2);
    end
end





%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

