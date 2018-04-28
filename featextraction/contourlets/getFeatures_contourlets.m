function features=getFeatures_contourlets(img)

	img = double(img);
	features = [];

	nlevels = [0, 0, 4, 4, 5];   % Decomposition level
	pfilter = '9-7' ;            % Pyramidal filter
	dfilter = 'pkva';            % Directional filter

	index=1;

	if size(img, 3) < 3
		aux = [];
		coeffs = pdfbdec( img, pfilter, dfilter, nlevels);
		aux =[aux  get4Statistics(coeffs{1}(:))];
		for s=2:length(coeffs)
			for dir=1:length(coeffs{s})
				aux =[aux   get4Statistics(coeffs{s}{dir}(:))];
			end
		end
		features = [aux aux aux];
	else
		for rgb=1:3
			coeffs = pdfbdec( img(:,:,rgb), pfilter, dfilter, nlevels );
			features=[features get4Statistics(coeffs{1}(:))];
			for s=2:length(coeffs)
				for dir=1:length(coeffs{s})
					features=[features  get4Statistics(coeffs{s}{dir}(:))];
				end
			end
		end
	end


function s =get4Statistics (a)
	s=zeros(1,4);
	s(1) = mean(a); 
	s(2) = var(a);
	s(3) = skewness(a);
	s(4) = kurtosis(a);
