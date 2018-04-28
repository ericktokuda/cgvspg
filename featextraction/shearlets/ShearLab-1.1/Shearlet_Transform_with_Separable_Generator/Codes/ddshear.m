function x = ddshear(im,k,axis,res)

% Discrete shear transform : this is basically same as dshear.m but 
% this routine performs resampling according to shear matrix [1 k/2^(res); 0 1]
% or [1 0; k/2^(res) 1] with essentially no aliasing effect. 


if axis == 1
    im = im';
end

[row col] = size(im);

y = zeros(row,2^(res)*col);

for j = 1:row
    tmp = im(j,:);
    for d = 1:res
        tmp = dyadup(tmp,2);
    end
    y(j,:) = [tmp zeros(1,2^res-1)];
end
y = dshear(y,k,0,0,0);
hy = fftshift(fft2(y));
hy = hy(:,(2^res-1)*col/2+1:(2^res+1)*col/2);
x = ifft2(ifftshift(hy));
    
if axis == 1
    x = x';
end

%
%  Copyright (c) 2010. Wang-Q Lim
%
%  Part of ShearLab Version 1.0
%  Built Sun, 07/04/2010
%  This is Copyrighted Material
%  For Copying permissions see COPYRIGHT.m

