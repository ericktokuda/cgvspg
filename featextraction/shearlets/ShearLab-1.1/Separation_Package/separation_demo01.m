% Demo routine for separating points and curves
% Written by Wang-Q Lim on May 5, 2010. 
% Copyright 2010 by Wang-Q Lim. All Right Reserved.

N = 150; % the number of random points
sigma = 20; % noise level

[img nimg] = curve_point(N,sigma);
% generate test image (points + curves) with noise


shear=shearing_filters_Myer([80 80 81 81],[3 3 4 4],256);
% generate shearing filters across scales j. 


[C P] = separate(nimg,4,10,3,3,[.1 .1 1.5 1.5],1,shear);

% separation using shearlets and wavelets

% display results 

figure; clf; imagesc(img); axis equal; axis tight; colormap jet; 
title('original image');

figure; clf; imagesc(nimg); axis equal; axis tight; colormap jet; 
title('noisy image');
  
figure; clf; imagesc(C, [0 max(max((C)))]); axis equal; axis tight; colormap jet; 
title('separated image : curves');

figure; clf; imagesc(P, [0 max(max((P)))]); axis equal; axis tight; colormap jet; 
title('separated image : points');




axis off; 
