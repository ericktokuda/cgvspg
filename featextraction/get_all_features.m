function res = get_all_features(imgs, outdir, startingfrom)
	approaches = {'boxcount', 'contourlets', 'curvelets', 'glcm', ...
		'hog', 'hsc', 'lbp','li', 'lsb', 'lyu', 'popescu', 'shearlets'};
	%global approaches = {'boxcount', 'contourlets', 'curvelets', 'glcm', ...
		%'hog', 'hsc', 'lbp','li', 'lsb', 'lyu', 'popescu', 'shearlets', 'sobel'};
	if (exist(imgs, 'file') == 2)
		res =  get_all_features_from_single_image(imread(imgs), ...
			approaches);
	elseif (exist(imgs, 'file') == 7)
		if exist('startingfrom','var')
			get_all_features_from_folder(imgs, approaches, ...
			outdir, startingfrom);
		else
			get_all_features_from_folder(imgs, approaches, outdir);
		end
	else
		warning('Path does not exist')
	end

function get_all_features_from_folder(pathToDataset, approaches, ...
	outdir, startingfrom)

	if ( ~exist(outdir,'dir')); 
		disp(strcat('Creating ', outdir)); 
		mkdir (outdir);
	end;

	files = dir(pathToDataset);

	if exist('startingfrom','var')
		files = files(3+startingfrom:end);
	else
		files = files(3:end);
	end

	disp('Currently just computing 12 features');

	nmethods = length(approaches);

	fh = zeros(nmethods, 1);

	for i = 1:nmethods % Create dirs
		approachesdir = fullfile(outdir, approaches{i});
		mkdir(approachesdir);
	end

	maxnumthreads = 4;
	%parfor (i = 1:length(inds), maxnumthreads)
	for (i = 1:length(files))
		if (files(i).isdir == 1); continue; end;
		[filedir, filename, ext] = fileparts(files(i).name);

		if (~strcmpi(ext, '.jpg')); continue; end

		disp([int2str(i) ' : ' files(i).name]);
		img = imread(strcat(pathToDataset,'/',files(i).name));

		canskip = true;

		for j = 1:nmethods;
			outpath = fullfile(outdir, approaches{j}, strcat(filename, '.csv'));
			if (exist(outpath, 'file') ~= 2);
				canskip = false;
			end;
		end

		if canskip; continue; end

		features = get_all_features_from_single_image(img, approaches);

		for j = 1:nmethods;
			outpath = fullfile(outdir, approaches{j}, strcat(filename, '.csv'));
			fh = fopen(outpath, 'w');
			fprintf(fh, '%f,',features{j});
			fclose(fh);
		end
	end;        

function res = get_all_features_from_single_image(img, approaches)
	res = cell(12,1);
	i = 1;
	tic
	for j = 1:length(approaches)
		%disp(appr)
		%class(appr)
		appr = approaches{j};
		prevdir = cd(appr);
		fprintf(strcat(' ', appr))
		res{i} = extract(img);
		i = i +1;
		cd(prevdir);
	end
	disp('')
	toc

