function dst_nlademo( im, option )
%   Demo for shearlet nonlinear approximation. 
%   DST_NLADEMO shows how to use the shearlet toolbox to do nonlinear 
%   approximation. It provides a sample script that uses basic functions 
%   such as MP_DST and recon_MP_DST.
%
%
%   While displaying images, the program will pause and wait for your response.
%   When you are ready, you can just press Enter key to continue.
%
%       dst_nlademo( [im, option] )
%
% Input:
%	im:     a double or integer matrix for the input image.
%           The default input is the 'barbara' image.  
%   option: option for the demos. The default value is 'auto'
%       'auto' ------  automtatical demo, no input
%       'user' ------  semi-automatic demo, simple interactive inputs
%   
% See also:     MP_DST, recon_MP_DST.

% History:
%   03/21/2010  Creation.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to shearlet nonlinear approximation demo! :)');
disp('Type help dst_nlademo for help' ) ;
disp('You can also view dst_nlademo.m for details.') ;
disp(' ');

% Input image
if ~exist('im', 'var')
    im = imread('barbara.jpg');
    im = double(im);
else
    im = double(im);
end

disp( 'Displaying the input image...');
clf;
imagesc(im, [0, 255]);
title( 'Input image' ) ;
axis image off;
colormap(gray);
input( 'Press Enter key to continue...' ) ;
disp(' ');

% Running option
if ~exist('option', 'var')
    option = 'auto' ;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image decomposition by shearlets followed by thresholding for 
% Nonlinear approximation.
% Image decomposition by wavelets followed by thresholding for 
% Nonlinear approximation.
% It will keep the most significant coefficients and use these 
% coefficients to reconstruct the image.
% It will show the reconstructed image and calculate the distortion. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Display information
nPixels = prod( size(im) );             % number of pixels
disp( sprintf('Number of image pixels is %d', nPixels) ) ;

if strcmp( option, 'auto' )
    nSignif = round(nPixels * 4 / 100) ;  % use 4% of coefficients for approximation. 
    disp( sprintf( 'It will keep %d significant coefficients', nSignif ) ) ;
    scale = [2 3 3 4 4]; % choose size of shearlets at each scale
    iter = 1; % number of iterations in MP step
    qmf2 = MakeONFilter('Symmlet',4); % choose a wavelet filter
    %qmf2 = MakeONFilter('Coiflet',4); % choose a wavelet filter
    ndir = -1; % number of directions (2^(ndir+2)+2 directions) and 
    % if ndir = -1 ---> only 2 directions (vertical and horizontal)
else
    % Get the input and check the input
    nSignif = -1 ;
    while nSignif < 0 | nSignif > nPixels
        nSignif = input( ...
            sprintf('Input the number of retained coefficient (1 to %d): ', ...
                nPixels) );
    end;
    scale = input(sprintf(...
    'Choose size of shearlets at each scale [fine scale -->coarse scale] (eg. [2 3 3 4 4]): '));
    iter = -1 ;
    while iter < 0 
        iter = input( ...
            sprintf('Choose the number of iterations in MP step: ') );
    end;
    str = input(sprintf(...
    'Choose a wavelet filter (eg. Symmlet or Coiflet (see MakeONFilter.m in WaveLab for details) ): '));
    par = input(sprintf('Choose a parameter for your wavelet filter (degree of vanishing moments): '));
    qmf2 = MakeONFilter(str,par);
    ndir = input(sprintf('Choose the number of directions (input value n gives 2^(n+2)+2 directions and enter -1 for fast result): '));
end;
for j = 1:iter
    N(j) = round((nSignif)/iter);
end
disp(' ');

disp('Take wavelet transform (9/7 CDF) with symmetric extension and then reconstruct image with thresholded coeff');
[qmf,dqmf] = MakeBSFilter('CDF',[4 4]);
tic;
[im_wrec num2 psnr2] = wave_comp(double(im),dqmf,qmf,4,nSignif,1); % approximation using wavelets 
toc;
disp('Take shearlet transform with MP step and then reconstruct image with thresholded coeff');
if ndir >= 0
    tic;
    [c flag1 ss num1] = MP_DST(im,qmf2,qmf2,N,iter,scale,ndir); % shearlet decomposition 
    % with MP step followed by thresholding
    imrec = recon_MP_DST(c,flag1,ss,qmf2,qmf2,iter,scale,ndir); % approximation using shearlets (with MP)
    toc;
    psnr1 = 20*log10(255/(1/512*norm(double(im(:))-imrec(:))));
    
else
    % if ndir < 0 then take shearlet transform with only two directions (vertical & horizontal)
    tic;
    [imrec num1] = test_dst(im,scale,N,qmf2,qmf2);
    toc;
    psnr1 = 20*log10(255/(1/512*norm(double(im(:))-imrec(:))));
end
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Display the original image as well as the reconstructed image
subplot(1,2,1), imagesc ( im, [0, 255] ) ; 
title( sprintf('Original image (%d X %d)', size(im))) ;
axis image off;
subplot(1,2,2), imagesc( imrec, [0, 255] );
title(sprintf('Reconstructed image\n(using %d coefs; PSNR = %.2f dB)', ...
    nSignif, psnr1));
colormap(gray);
axis image off;

disp('Comparing the original image with the NLA image by shearlets...') ;
input('Press Enter key to continue...' ) ;
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display comparison with NLA using wavelets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Only show a portion of images (size 256 x 256);
ind1 = 201:456;
ind2 = 1:256;

disp('Comparing NLA by wavelets and by shearlets...') ;

subplot(1,2,1), imagesc ( im_wrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('NLA using wavelets\n(M = %d coeffs; PSNR = %.2f dB)', ...
    num2, psnr2)) ;
colormap(gray);
axis image off;

subplot(1,2,2), imagesc ( imrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('NLA using shearlets\n(M = %d coeffs; PSNR = %.2f dB)', ...
    num1, psnr1)) ;
colormap(gray);
axis image off;

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m
