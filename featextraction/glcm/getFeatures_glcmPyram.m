function features = getFeatures_glcmPyram(A)

	lowFilter=[0.02807382 -0.060944743 -0.073386624 0.41472545 0.7973934 0.41472545 0.073386624 -0.060944743 0.02807382];
	highFilter=[0.02807382 0.060944743 -0.073386624 -0.41472545 0.7973934 -0.41472545 -0.073386624 0.060944743 0.02807382];
	nScales=4; 

	if (size(A,3)<3)
		DD=zeros(nScales,4); VV=DD; HH=DD;
		[C L]=wavedec2(A, nScales,lowFilter,highFilter);
		for s=1:nScales
			[H V D] = detcoef2('all',C,L,s);
			HH(s, :) = getHaralick4features(H);
			VV(s, :) = getHaralick4features(V);
			DD(s, :) = getHaralick4features(D);        
		end
		HHH = [HH; HH; HH];
		VVV = [VV; VV; VV];
		DDD = [DD; DD; DD];
		concat=[HHH;VVV;DDD];
	else
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
	end

	features = transpose(concat(:));

function features=getHaralick4features(A)
	C=graycomatrix(A,'NumLevels',256);			
	D=graycoprops(C);
	features(1)=getfield(D,'Contrast');	features(2)=getfield(D,'Correlation');
	features(3)=getfield(D,'Energy');	features(4)=getfield(D,'Homogeneity');
	features=features';



