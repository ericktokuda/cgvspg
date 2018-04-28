function features = getFeatures_lsb(im)

	if (size(im, 3) < 3)
		aux = zeros([size(im) 3]);
		aux(:, :, 1) = im;
		aux(:, :, 2) = im;
		aux(:, :, 3) = im;
		im = aux;
	end

	map = mod(im, 2);
	map = (map-min(map(:)))/(max(map(:))-min(map(:)));
	features = zeros(3,4);

	for rgb=1:3
		features(rgb,:)=getHaralick4features(map(:,:,rgb));
	end    
	features = transpose(features(:));

function features=getHaralick4features(A)
	C = graycomatrix(A,'NumLevels',256);			
	D = graycoprops(C);
	features(1) = getfield(D,'Contrast');
	features(2) = getfield(D,'Correlation');
	features(3) = getfield(D,'Energy');
	features(4) = getfield(D,'Homogeneity');

	features=features';
