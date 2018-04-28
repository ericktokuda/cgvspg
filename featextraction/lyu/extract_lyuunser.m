function features=getFeatures_lyuUnser(pathToImage)

lowFilter=[0.02807382 -0.060944743 -0.073386624; 0.41472545 0.7973934 0.41472545; 0.073386624 -0.060944743 0.02807382];
highFilter=[0.02807382 0.060944743 -0.073386624; -0.41472545 0.7973934 -0.41472545; -0.073386624 0.060944743 0.02807382];
nScales=4; 
threshold=0.01;

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

A=imread(pathToImage);

[D V H] = waveletDecomposition(A,lowFilter,highFilter,nScales);
D=double(D);V=double(V);H=double(H);

features=[];
for k=1:3 %for each color channel
    for j=1:nScales %for each scale
        D(:,:,j,k)=normalize(D(:,:,j,k));        V(:,:,j,k)=normalize(V(:,:,j,k));        H(:,:,j,k)=normalize(H(:,:,j,k));
        features=[features;getUnserFeatures(D(:,:,j,k))];
        features=[features;getUnserFeatures(V(:,:,j,k))];
        features=[features;getUnserFeatures(H(:,:,j,k))];        
    end
end

%End of Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D V H] = waveletDecomposition(A,lowFilter,highFilter,nScales)
D=zeros(size(A,1),size(A,2),nScales); V=D; H=D;
for k=1:3  %for each color chanel
    for j=1:nScales %for each scale
        D(:,:,j,k)=conv2(conv2(A(:,:,k),highFilter, 'same'),highFilter, 'same');
        V(:,:,j,k)=conv2(conv2(A(:,:,k),lowFilter, 'same'),highFilter, 'same');
        H(:,:,j,k)=conv2(conv2(A(:,:,k),highFilter, 'same'),lowFilter, 'same');
        A(:,:,k)=conv2(conv2(A(:,:,k),lowFilter,'same'),lowFilter,'same');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function features=getUnserFeatures(im) %Receives an image normalized (vaues between 0~1) and BW
features=zeros(9,1);
%epsilon=1e-30; im=im + epsilon; %Just to avoid logarithm of zero
im=double(im);
[m n]=size(im);
mi=mean(im(:));
squared=(im.^2);

for i=1:m
    for j=1:n
    features(1) = features(1) + i*im(i,j);
    features(2) = features(2) + ((i-mi)^2)*im(i,j);
    features(3) = features(3) + squared(i,j);
    features(4) = features(4) + (i-mi)*(j-mi)*im(i,j);
    if(im(i,j)~=0); features(5) = features(5) - im(i,j)*log(double((im(i,j)))); end;
    features(6) = features(6) + ((i-j)^2)*im(i,j);    
    features(7) = features(7) + (1/(1+(i-j)^2))*im(i,j);  % Different from the article
    features(8) = features(8) + ((i-j-2*mi)^3)*im(i,j);    
    features(9) = features(9) + ((i-j-2*mi)^4)*im(i,j);   
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=normalize(A)
res=(A-min(A(:)))/(max(A(:))-min(A(:)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function features=getHaralick4features(A)
C=graycomatrix(A,'NumLevels',256);			
D=graycoprops(C);
%features(1)=getField(D,'Contrast');	features(2)=getField(D,'Correlation');
%features(3)=getField(D,'Energy');	features(4)=getField(D,'Homogeneity');
features(1)=getfield(D,'Contrast');	features(2)=getfield(D,'Correlation');
features(3)=getfield(D,'Energy');	features(4)=getfield(D,'Homogeneity');
features=features';
