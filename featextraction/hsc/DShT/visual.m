%close all;
figure; 

nangles = 8;

% open image
f = imread('test_d.pgm');

[d1 d2] = sbandas(f);

% display
for i = 1 : nangles
    subplot(2,4,i);
    imagesc((d1(:,:,i)));
end

i = 1;
idxPos = find(d1(:,:,i) > -0.001);
idxNeg = find(d1(:,:,i) < 0.001);

mapPos = d1(:,:,i);
mapPos(idxNeg) = 0;

mapNeg = d1(:,:,i);
mapNeg(idxPos) = 0;

figure; imagesc(mapPos);
figure; imagesc(mapNeg);

% compute histograms
histog = zeros(1, nangles);
for i = 1 : nangles
    histog(i) = sum(sum(abs(d2(:,:,i))));
end
histog = histog / norm(histog);