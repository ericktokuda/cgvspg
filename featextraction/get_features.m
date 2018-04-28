function res = get_features(imgs, outdir, approach, startingfrom)
	if (exist(imgs, 'file') == 2)
		res =  get_features_from_single_image(imread(imgs), approach);
	elseif (exist(imgs, 'file') == 7)
		if exist('startingfrom','var')
			res = get_features_from_folder(imgs, outdir, approach, startingfrom);
		else
			res = get_features_from_folder(imgs, outdir, approach);
		end
	else
		warning('Path does not exist')
	end

function res = get_features_from_folder(imdir, outdir, approach, startingfrom)
	if ( ~exist(outdir,'dir')); mkdir (outdir); end;

	files = dir(imdir);

	if exist('startingfrom','var')
		files = files(3+startingfrom:end);
	else
		files = files(3:end);
	end

	%maxnumthreads = 2;
	%parfor (i = 1:length(files), maxnumthreads)
	for i = 1:length(files)
		if (files(i).isdir == 1); continue; end;
		[filedir, filename, ext] = fileparts(files(i).name);

		if (strcmp(ext, '.jpg') ~= 1); continue; end;

		outpath = fullfile(outdir, strcat(filename, '.csv'));
		if (exist(outpath, 'file') == 2); continue; end;

		disp([int2str(i) ' : ' files(i).name]);
		img = imread(strcat(imdir,'/',files(i).name));

		features = get_features_from_single_image(img, approach);
		fh = fopen(outpath, 'w');
		fprintf(fh, '%f,',features);
		fclose(fh);

	end;        
	res = true;

function res = get_features_from_single_image(img, approach)
	prevdir = cd(approach); res = extract(img); cd(prevdir);
