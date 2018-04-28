function features=getFeatures(pathToImage)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to extract the features vector from an image.
%  It is based on the 4 features of haralick from 
%  the pyramidal wavelet decomposition.
%  The output matrix is assembled so that it is partitioned
%   in 4 blocks: ||-contrast-|-correlation-|-enery-|-homogeneity-||
%   . On this way, we can analyze the individal accuracy of the use
%   of each of these four features.
%
% INPUT: full path of the RGB image
%   e.g. getFeatures_glcmPyram('/mnt/ext3/Datasets512/CG/3dtotal_1049.jpg')
%
% OUTPUT: 144 D-array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


A=imread(pathToImage);
features = zeros(1,12);

for k=1:3
	C=graycomatrix(A(:,:,k),'NumLevels',256);			
	D=graycoprops(C);
	features(1+(k-1)*4)=getfield(D,'Contrast');	features(2+(k-1)*4)=getfield(D,'Correlation');
	features(3+(k-1)*4)=getfield(D,'Energy');	features(4+(k-1)*4)=getfield(D,'Homogeneity');
	if (size(A,3)~=3)
		features(5:8) = features(1:4);	features(9:12) = features(1:4);
		break;
	end
end




