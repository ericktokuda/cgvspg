function [y num psnr] = wave_comp(x,qmf,dqmf,L,n,ortho)

% this is a test routine which runs wavelet transform
% for image approximation   


if ortho == 1
wc = FWT2_SBS(x,L,qmf,dqmf);
%wc = FWT2_PB(x,L,qmf,dqmf);
[temp1 thr1 num] = select_coeff(wc,n);
y = IWT2_SBS(temp1,L,qmf,dqmf);
%y = IWT2_PB(temp1,L,qmf,dqmf);
psnr = 20*log10(255/(1/512*norm(y(:)-x(:))));
else
qmf = MakeONFilter('Symmlet',4);
wc = FWT2_PO(x,L,qmf);
[temp1 thr1 num] = select_coeff(wc,n);
y = IWT2_PO(temp1,L,qmf);
psnr = 20*log10(255/(1/512*norm(y(:)-x(:))));
end    


%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m

