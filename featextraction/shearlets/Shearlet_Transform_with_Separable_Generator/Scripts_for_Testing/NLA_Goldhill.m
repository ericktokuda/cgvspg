%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This is a script for testing NLA  
%   using (extended) shearlet transform
%   test image : Goldhill
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NLA_Goldhill


clf;
% original image
im = imread('goldhill.jpg');
im = double(im);
disp( 'Displaying the input image...');
clf;
imagesc(im, [0, 255]);
title( 'Input image' ) ;
axis image off;
colormap(gray);
input( 'Press Enter key to continue...' ) ;
disp(' ');
disp('take (extended) shearlet transform and wavelet transform for NLA')
disp(' ');
N = 10000;

% call 1D Quadrature mirror filter for shearlets
qmf2 = MakeONFilter('Coiflet',4);
% take (extended) shearlet transform with Hard Thresholding and then
% reconstruct using only two directions ( horizontal and vertical )
[imrec num1] = test_dst(im,[2 3 3 4 4],N,qmf2,qmf2);
psnr1 = 20*log10(255/(1/512*norm(double(im(:))-imrec(:))));

% call 9-7 CDF filters for wavelet transform
[qmf,dqmf] = MakeBSFilter('CDF',[4 4]);
% take wavelet transform with Hard Thresholding and then reconstruct
[im_wrec num2 psnr2] = wave_comp(double(im),dqmf,qmf,4,N,1);

input( 'Press Enter key to continue...' ) ;
disp(' ');

% Only show a portion of images (size 256 x 256);
ind1 = 201:456;
ind2 = 1:256;

disp('Comparing NLA by wavelets and by shearlets...') ;

% display results
subplot(1,3,1), imagesc ( im(ind1, ind2), [0, 255] ) ;
title( 'Input image' );
axis image off;
subplot(1,3,2), imagesc ( im_wrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('NLA using wavelets\n(M = %d coeffs; PSNR = %.2f dB)', ...
    num2, psnr2)) ;
axis image off;
subplot(1,3,3), imagesc ( imrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('NLA using shearlets\n(M = %d coeffs; PSNR = %.2f dB)', ...
    num1, psnr1)) ;
axis image off;
%  Copyright (c) 2010. Wang-Q Lim, University of Osnabrueck
%
%  Part of ShearLab Version 1.0
%  Built Sun, 07/04/2010
%  This is Copyrighted Material
%  For Copying permissions see COPYRIGHT.m
