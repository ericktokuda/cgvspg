function y = iddshear(x,k,axis,res)

% inverse of ddshear (see ddshear.m)

if k == 0 
    y = x;
else
%k = k/(gcd(k,2^res)); 
%res = res - log2(gcd(k,2^res));

if axis == 1
    x = x';
end

[row col] = size(x);
hy = fftshift(fft2(x));
lhalf = hy(:,1:col/2);
rhalf = hy(:,col/2+1:col);
tmp = [];
if k < 0 
    sgn = 1;
else 
    sgn = 0;
end
k = abs(k);
for j = 1:2^res
    %tab1 = -1*row*(-1/2+1/2^res*(mod(k*j,2^res)-1));
    %tab2 = -1*row*(-1/2+1/2^res*(mod(k*j,2^res)));
    tab1 = -1*row*(-1/2^res*(mod(k*(2^(res-1)),2^res))+1/2^res*(mod(k*(j-1),2^res)));
    tab2 = -1*row*(-1/2^res*(mod(k*(2^(res-1)),2^res))+1/2^res*(mod(k*j,2^res)));
    if sgn == 1 
        tab1 = -1*tab1; tab2 = -1*tab2;
    end
    tmp = [tmp circshift(rhalf,tab1) circshift(lhalf,tab2)];
end

tmp = ifft2(ifftshift(tmp));
tmp = dshear(tmp,(-1)^(sgn+1)*k,0,0,0);
tmp = tmp(:,1:2^(res)*col-(2^res-1));

for j = 1:row
    tmp1 = tmp(j,:);
    for d = 1:res
        tmp1 = dyaddown(tmp1,1);
    end
    y(j,:) = tmp1;
end

if axis == 1
    y = y';
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
