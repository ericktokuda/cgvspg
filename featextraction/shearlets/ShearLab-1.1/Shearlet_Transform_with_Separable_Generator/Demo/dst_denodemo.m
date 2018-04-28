function dst_denodemo( im, option )
%   Demo for denoising using shearlet transform. 
%   DST_DENODEMO shows how to use the shearlet toolbox to do denoising 
%   for Gaussian noise. It provides a sample script that uses basic function
%   HT_DST.
%
%
%   While displaying images, the program will pause and wait for your response.
%   When you are ready, you can just press Enter key to continue.
%
%       dst_denodemo( im, option )
%
% Input:
%	im:     a double or integer matrix for the input image.
%           The default input is the 'barbara' image.  
%   option: option for the demos. The default value is 'auto'
%       'auto' ------  automtatical demo, no input
%       'user' ------  semi-automatic demo, simple interactive inputs
%   
% See also:     HT_DST.

% History:
%   03/21/2010  Creation.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Welcome to shearlet denoising demo ! :)');
disp('Type help dst_denodemo for help' ) ;
disp('You can also view dst_denodemo.m for details.') ;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Noisy image with Gaussian noise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp( option, 'auto' )
    Noisyim = GWNoisy2(im,30);
    sigma = 30;
else
    sigma = -1;
    while sigma < 0 
        sigma = input(sprintf('Input noise level (sigma > 0): '));
    end;
    Noisyim = GWNoisy2(im,sigma);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Image decomposition by shearlets followed by thresholding for 
% denoising.
% Image decomposition by wavelets followed by thresholding for 
% denoising.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp( option, 'auto' )
    scale = [3 3 3 4 4]; % choose size of shearlets at each scale
    qmf2 = MakeONFilter('Symmlet',4); % choose a wavelet filter
    %qmf2 = MakeONFilter('Coiflet',4); % choose a wavelet filter
    ndir = 0; % number of directions (2^(ndir+2)+2 directions) 
    x_y = 'both'; % choose type of shearing
    % x_y = 'hor' : shearing associated with horizontal cone 
    % x_y = 'ver' : shearing associated with verical cone 
    % x_y = 'both' : take both types of shearings 
    lim_x = 1; % number of translates along the axis associated with scaling 2^j
    lim_y = 1; % number of translates along the axis associated with scaling 2^(j/2) 
    redundancy = (lim_x)*(lim_y)*(2^(ndir+2)+2)*2;
    % Total redundacny of shearlet transform with mirror extension is 
    % (lim_x)*(lim_y)*(2^(ndir+2)+2)*2 when x_y = 'both'
    % (lim_x)*(lim_y)*(2^(ndir+2)+2) when x_y = 'hor' or 'ver'
else
    % Get the input and check the input
    scale = input(sprintf(...
    'Choose size of shearlets at each scale [fine scale -->coarse scale] (eg. [3 3 3 4 4]): '));
    str = input(sprintf(...
    'Choose a wavelet filter (eg. Symmlet or Coiflet (see MakeONFilter.m in WaveLab for details) ): '));
    par = input(sprintf('Choose a parameter for your wavelet filter (degree of vanishing moments): '));
    qmf2 = MakeONFilter(str,par);
    ndir = -1;
    while ndir < 0
        ndir = input(sprintf('Choose the number of directions (input value n gives 2^(n+2)+2 directions): '));
    end
    lim_x = -1;
    while lim_x < 0
        lim_x = input(sprintf('Choose the number of translates along the horizontal axis: '));
    end
    lim_y = -1;
    while lim_y < 0
        lim_y = input(sprintf('Choose the number of translates along the vertical axis): '));
    end
    x_y = input(sprintf('Choose type of shearing (horizontal(hor) or vertical(ver) or both): '));
    if strcmp(x_y,'hor') | strcmp(x_y,'ver')
        redundancy = (lim_x)*(lim_y)*(2^(ndir+2)+2);
    else
        redundancy = (lim_x)*(lim_y)*(2^(ndir+2)+2)*2;
    end
end;
disp(' ');
% take (shfit invariant) wavelet transform followed by Hard Thresholding
disp('Take translation invariant wavelet transform (symmlet4) followed by')
disp('HARD thresholding and then reconstruct image with thresholded coeff');
qmf = MakeONFilter('Symmlet',4);
tic;
im_wrec = TIDenoiseHard2(Noisyim,5,qmf,3*sigma);
toc;
psnr2 = 20*log10(255/(1/512*norm(double(im(:))-im_wrec(:))));
disp('Take shearlet transform followed by HARD thresholding')
disp('and then reconstruct image with thresholded coeff');
% take (extended) shearlet transform followed by Hard Thresholding
%tic;
imrec = HT_DST(Noisyim,qmf2,qmf2,ndir,scale,sigma,2,lim_x,lim_y,.88*[4 3*ones(1,length(scale)-1)],x_y);
%toc;
psnr1 = 20*log10(255/(1/512*norm(double(im(:))-imrec(:))));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Display the original image as well as the denoised image
subplot(1,2,1), imagesc ( im, [0, 255] ) ; 
title( sprintf('Original image (%d X %d)', size(im))) ;
colormap(gray);
axis image off;
subplot(1,2,2), imagesc( imrec, [0, 255] );
title(sprintf('Denoised image using shearlets'));
colormap(gray);
axis image off;

disp('Comparing the original image with denoised image by shearlets...') ;
input('Press Enter key to continue...' ) ;
disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display comparison with denoising using wavelets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Only show a portion of images (size 256 x 256);
ind1 = 201:456;
ind2 = 1:256;

disp('Comparing denoising by (TI)wavelets and by shearlets...') ;

subplot(1,2,1), imagesc ( im_wrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('(TI)Wavelets; Redundany = %d,PSNR = %.2f dB)', ...
    64, psnr2)) ;
colormap(gray);
axis image off;

subplot(1,2,2), imagesc ( imrec(ind1, ind2), [0, 255] ) ; 
title( sprintf('Shearlets; Redundancy = %d,PSNR = %.2f dB)', ...
    redundancy, psnr1)) ;
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
