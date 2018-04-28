%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This is a script for testing denoising  
%   using (extended) shearlet transform
%   test image: Goldhill
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function deno_Goldhill
clf;
% original image
im = imread('goldhill.jpg','jpg');
im = double(im);
% create noisy image
Noisyim = GWNoisy2(im,30);
disp( 'Displaying the input image...');
clf;
% display noisy image and original image
subplot(1,2,1), imagesc(im, [0, 255]);
title( 'Input image' ) ;
axis image off;
subplot(1,2,2), imagesc(Noisyim, [0, 255]);
title( 'Noisy image' );
axis image off;
colormap(gray);
input( 'Press Enter key to continue...' ) ;
disp(' ');
% call 1D quadrature mirror filters for shearlets and wavelets

qmf = MakeONFilter('Symmlet',4);
% take (extended) shearlet transform with Hard Thresholding and then reconstruct
% using 10 directions
% take wavelet transform with Hard Thresholding and then reconstruct
disp('take translation invariant wavelet transform for denoising')
disp(' ');
tic;
im_wrec = TIDenoiseHard2(Noisyim,5,qmf,3*30);
toc;
psnr2 = 20*log10(255/(1/512*norm(double(im(:))-im_wrec(:))));
disp('take (extended) shearlet transform for denoising')
disp(' ');
imrec = HT_DST(Noisyim,qmf,qmf,1,[3 3 3 4 4],30,2,1,1,0.9*[4 3 3 3 3],'both');
psnr1 = 20*log10(255/(1/512*norm(double(im(:))-imrec(:))));

input( 'Press Enter key to continue...' ) ;
disp(' ');

% Only show a portion of images (size 256 x 256);
ind1 = 201:456;
ind2 = 1:256;
% display results
clf;
disp('Comparing denoising by wavelets and by shearlets...') ;
subplot(1,3,1), imagesc ( im(ind1, ind2), [0, 255] ) ;
title( 'Input image' );
axis image off;
subplot(1,3,2), imagesc ( im_wrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('(TI)Wavelets; Redundany = %d,PSNR = %.2f dB)', ...
    64, psnr2)) ;
axis image off;

subplot(1,3,3), imagesc ( imrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('Shearlets; Redundancy = %d,PSNR = %.2f dB)', ...
    20, psnr1)) ;
colormap(gray);
axis image off;

%  Copyright (c) 2010. Wang-Q Lim, University of Osnabrueck
%
%  Part of ShearLab Version 1.0
%  Built Sun, 07/04/2010
%  This is Copyrighted Material
%  For Copying permissions see COPYRIGHT.m
