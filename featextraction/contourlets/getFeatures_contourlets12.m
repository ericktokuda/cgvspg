function features=getFeatures_contourlets(pathToImage)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script to extract the features from an image,
%  based on Wiliam Scharz work
%
% INPUT: full path of the RGB image
%   e.g. getFeatures_HSC('/mnt/ext3/Datasets512/CG/artlantis_1272022334.jpg');
%
% OUTPUT: 144d-array 
%
% Eric K. (eric.keiji@students.ic.unicamp.br)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



oldDir=cd('contourlets');

img=imread(pathToImage);
img = double(img);
features = [];


nlevels = [0, 0, 4, 4, 5];   % Decomposition level
pfilter = '9-7' ;            % Pyramidal filter
dfilter = 'pkva12';            % Directional filter

% Contourlet transform

index=1;
for rgb=1:3
  coeffs = pdfbdec( img(:,:,rgb), pfilter, dfilter, nlevels );
  features=[features get4Statistics(coeffs{1}(:))];
  for s=2:length(coeffs)
    for dir=1:length(coeffs{s})
      features=[features  get4Statistics(coeffs{s}{dir}(:))];
    end
  end
end
	


cd(oldDir);	

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s =get4Statistics (a)
s=zeros(1,4);
s(1) = mean(a); 
s(2) = var(a);
s(3) = skewness(a);
s(4) = kurtosis(a);
