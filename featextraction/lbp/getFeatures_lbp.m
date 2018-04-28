function features = getFeatures_lbp(A)
	m = 24; %Number of sampling points (check function lbp.m)
	r = 3;

	LBPHIST = zeros(m+2,3);

	if exist('mapping_riu2.mat', 'file') == 2
		load('mapping_riu2', 'MAPPING');
	else
		MAPPING = getmapping(m, 'riu2');%Rotation-invariant (ri) and uniform(u2)
		save('mapping_riu2', 'MAPPING');
	end

	if (size(A, 3) < 3)
		aux = lbp(A, r, m, MAPPING, 'hist');
		LBPHIST = [aux; aux; aux];
	else
		for k = 1:3
			LBPHIST(:, k) = lbp(A(:,:,k), r, m, MAPPING, 'hist');
		end
	end

	features = transpose(LBPHIST(:));
