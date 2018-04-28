function features=getFeatures_GLCMwavelets(pathToImage)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to extract the features vector from an image.
%  It is based on the 4 features of haralick from 
%  the wavelet decomposition.
%
% INPUT: full path of the RGB image
%   e.g. getFeatures_GLCMwavelets('/mnt/ext3/Datasets512/CG/3dtotal_1049.jpg')
%
% OUTPUT: 144 D-array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Considerations
% 
% 
% In the equation of the linear predictors
%  -we use the ROUND of the  half-sizes
%  -log is neperian
%  -considering magnitudes above the threshold
%  -just colored images are being considered
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


lowFilter=[0.02807382 -0.060944743 -0.073386624 0.41472545 0.7973934 0.41472545 0.073386624 -0.060944743 0.02807382];
highFilter=[0.02807382 0.060944743 -0.073386624 -0.41472545 0.7973934 -0.41472545 -0.073386624 0.060944743 0.02807382];
nScales=4; 


A=imread(pathToImage);
if (size(A,3)<3 ) %just colored images
    disp (['Skipping ', pathToImage, ': one colour band']);    
    features=-1;
    return;
end


DD=zeros(3*nScales,4); VV=DD; HH=DD;

for k=1:3
    [C L]=wavedec2(A(:,:,k),nScales,lowFilter,highFilter);
    for s=1:nScales
        [H V D]=detcoef2('all',C,L,s);
        HH((k-1)*4+s,:)=getHaralick4features(H);
        VV((k-1)*4+s,:)=getHaralick4features(V);
        DD((k-1)*4+s,:)=getHaralick4features(D);        
    end
end



concat=[HH;VV;DD];
features=concat(:);

%End of Main

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function features=getHaralick4features(A)
C=graycomatrix(A,'NumLevels',256);			
D=graycoprops(C);
%features(1)=getField(D,'Contrast');	features(2)=getField(D,'Correlation');
%features(3)=getField(D,'Energy');	features(4)=getField(D,'Homogeneity');
features(1)=getfield(D,'Contrast');     features(2)=getfield(D,'Correlation');
features(3)=getfield(D,'Energy');       features(4)=getfield(D,'Homogeneity');
%
features=features';



