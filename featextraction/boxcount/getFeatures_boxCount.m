function features = getFeatures_boxCount(img)
	j = 6; %Number of features to preserve from boxcount
	features = version02(img, j);

function features=version01(im,j)
	features=zeros(1,j*3);
	for k=1:3
		aux=boxcount(edge(im(:,:,k)));
		aux=aux(1:j);
		features((k-1)*j+1:k*j)=aux;
	end

function features = version02(im, j)
	features = zeros(1,3);

	if size(im, 3) < 3
		[n r] = boxcount(edge(im));
		n = n(1:j);
		r = r(1:j);
		df = -diff(log(n))./diff(log(r));
		aux = median(df); 
		features = [aux aux aux];
	else
		for k = 1:3
			[n r] = boxcount(edge(im(:, :, k)));
			n = n(1:j);
			r = r(1:j);
			df = -diff(log(n))./diff(log(r));
			features(k) = median(df); 
			%mean(df) %We can use mean or median
		end
	end
