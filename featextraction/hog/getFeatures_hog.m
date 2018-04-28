function res = getFeatures_hog(A)

	res=[];
	if (size(A, 3)<3 ) %just colored images
		aux = hog(A, 4, 16);
		res = [aux aux aux];
	else
		for rgb=1:3
			res = [res hog(A(:,:,rgb), 4, 16)];
		end
	end
	res = transpose(res(:));
