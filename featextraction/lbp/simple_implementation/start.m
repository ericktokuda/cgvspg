clc; clear; 
im = double(rgb2gray(imread('lenna.jpg')));
im = im(1:255,1:255);
imagesc(im); colormap(gray)

%process 3*3 blocks with LBP
result = blockproc(im,[3 3],@lbp);
imagesc(result) %see result
colormap(hot)
