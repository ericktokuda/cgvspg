function features = getFeatures_curvelets(A)

warning ('OFF','all');

%if (size(A,3)<3 ) %just colored images
    %disp (['Skipping ', pathToImage, ': one colour band']);    
    %features=-1;
    %return;
%end
if (~exist('CURVELABPATH','var')); setParam(); end;

% ALWAS resizing to 256x256
%A = imresize(A, [256 256]);
n=size(A,1);

nScales=log2(n)-3; % Default value for fdct_usfft

acc=1;

if (size(A,3)<3 ) %just colored images
	aux=-ones(1,n*10); % Length large enough
	C = fdct_usfft(double(A),0,nScales); %Curvelets transform
	for s=1:length(C) % |scale01|scale02|...|
		for w=1:length(C{s}) % |orientation01|orientation02|...|
			aux(acc:acc+3)=get4Statistics(abs(C{s}{w}(:))); %|mean var skew kurt|
			acc=acc+4;
		end
	end
	features = [aux aux aux];
else
	features=-ones(1,n*10); % Length large enough
	C=cell(1,3);
	for rgb=1:3  % |colour_1| colour_2|colour_3|
		C{rgb} = fdct_usfft(double(A(:,:,rgb)),0,nScales); %Curvelets transform
		for s=1:length(C{rgb}) % |scale01|scale02|...|
			for w=1:length(C{rgb}{s}) % |orientation01|orientation02|...|
				features(acc:acc+3)=get4Statistics(abs(C{rgb}{s}{w}(:))); %|mean var skew kurt|
				acc=acc+4;
			end
		end
	end
end
features(features==-1)=[];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=get4Statistics(A)
[m n p]=size(A);
B=reshape(A,1,m*n,p); % Linearization
res=zeros(1,4*p);
for k=1:p
    res(4*k-3)= mean(B(:,:,k));
    res(4*k-2)= var(B(:,:,k));
    res(4*k-1)= skewness(B(:,:,k));    
    res(4*k)  = kurtosis(B(:,:,k));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setParam()
% fdct_usfft_path:

global CURVELABPATH
global PATHNAMESEPARATOR
global PREFERIMAGEGRAPHICS
global MATLABPATHSEPARATOR
		
PREFERIMAGEGRAPHICS = 1;
Friend = computer;

if strcmp(Friend,'MAC2'),
  PATHNAMESEPARATOR = ':';
  CURVELABPATH = ['Macintosh HD:Build 802:BMIALab', PATHNAMESEPARATOR];
  MATLABPATHSEPARATOR = ';';
elseif isunix,
  PATHNAMESEPARATOR = '/';
  CURVELABPATH = [pwd, PATHNAMESEPARATOR];
  MATLABPATHSEPARATOR = ':';
elseif strcmp(Friend(1:2),'PC');
  PATHNAMESEPARATOR = '\';	  
  CURVELABPATH = [pwd, PATHNAMESEPARATOR];  
  MATLABPATHSEPARATOR = ';';
end

post = PATHNAMESEPARATOR;
p = path;
pref = [MATLABPATHSEPARATOR CURVELABPATH];
p = [p pref];

p = [p pref 'CurveCoeff' post];
p = [p pref 'USFFT' post];
p = [p pref 'Utilities' post];
p = [p pref 'Windows' post 'Meyer' post ];
p = [p pref 'Windows' post 'IteratedSine' post];

path(p);

clear p pref post
clear BMIALABPATH MATLABVERSION PATHNAMESEPARATOR
clear Friend PREFERIMAGEGRAPHICS MATLABPATHSEPARATOR
