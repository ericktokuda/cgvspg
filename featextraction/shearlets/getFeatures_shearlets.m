function features=getFeatures_shearlets(A)

	if(~exist('sampled_DST','file'))
		run('ShearLab110.m');%Set pathnames
	end

	n=size(A,1);
	filt=MakeONFilter('Daubechies',16);
	szShearlets=[3 3 4 4 5];
	paramNumDir=1;
	s=4; % Number of Statistics extracted in function getStatistics
	ndir=2^(paramNumDir+1)+1;
	shearCoeffs=zeros(n,n,ndir);

	features=zeros(1,3*ndir*s); % NumColours*numDir*numMoments

	is_rgb = size(A, 3) == 3;

	if (~is_rgb)
		shearCoeffs=sampled_DST(A,filt,filt,szShearlets,paramNumDir);
		for k=1:ndir 
			aux=shearCoeffs(:,:,k);
			ind=(1-1)*(ndir*s)+ (k-1)*s + 1;
			aux2(1, ind:ind+3)=getStatistics(aux(:));
		end
		features = [aux2 aux2 aux2];
	else
	for rgb=1:3
		shearCoeffs=sampled_DST(A(:,:,rgb),filt,filt,szShearlets,paramNumDir);
		for k=1:ndir 
			aux=shearCoeffs(:,:,k);
			ind=(rgb-1)*(ndir*s)+ (k-1)*s + 1;
			features(1,ind:ind+3)=getStatistics(aux(:));
		end
	end
end

function s =getStatistics (a)
	s=zeros(1,4);
	s(1) = mean(a);
	s(2) = var(a);
	s(3) = skewness(a);
	s(4) = kurtosis(a);

