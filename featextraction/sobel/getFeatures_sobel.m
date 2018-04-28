function features=getFeatures_sobel(A)

	%TODO: I am still applying sobel twice)!');

	% The gaussian fit is used  with the default parameters of sftool
	% Method: NonLinearLeastsquares
	% Algorithm: Trust-Region
	% DiffMinChange: 1e-08
	% DiffMaxChange: .1
	% MaxFunEvals: 600
	% MaxIter: 400
	% TolFun: 1.0e-06
	% TolX: 1.0e-06
	% Starting Points (a1, sigmax, sigmay, x0) are all started near 1


	% Assumptions:
	% -sizeMax: is the size of the grid by which the local maximum gonna be
	%   computed
	% - sizeGauss: is the size of the Gaussian by which the Gaussians, centered
	%   on the local maximums gonna be computed
	% - the blocks are normalized to 1, and centered on the "local Max" (that
	%    was maximum in the grid of size sizeMax. Hence, "local maximum" can
	%    have a neighbour of greater value
	% - We are not computing the borders of the image (border of size sizeGaussian is being taken)

	sizeMax = 3;    % Size of the window of maximum
	sizeGauss = 7;  % Size of the window of Gaussian
	threshGof = .1; % Threshold of the Sum Of the Squares of the fitting to the gaussian
	numMax = 50;   % Number of local maximum
	sizeFeatures=150; % Length of the features vector 

	n = size(A,1);
	filt=fspecial('sobel'); %Choose one kind of filter

	dxGaussian=floor(sizeGauss/2);
	aux=-ones(n*n,2);
	s=1;
	X=zeros(n+2,n+2,2);

	if size(A, 3) < 3
		for ii=1:2
			A1 = conv2(double(A),double(filt));
			X(:,:,ii) = (A1-min(A1(:)))/(max(A1(:))-min(A1(:))); % Normalization
			filt=filt';
		end
		B = sqrt(X(:,:,1).^2+X(:,:,2).^2);
		indices = getAllMax(B, sizeMax, sizeGauss); % The variable 'indices' contains the indices of the maximum
		indices = getGreaterElements(B, indices, 50*numMax);

		%    indices=sortMatrix2d(indices);
		for l = size(indices,1):-1:1
			block = getWindow(B, sizeGauss, indices(l,1)-dxGaussian,indices(l,2)-dxGaussian);
			[fitResult gof] = fitToGaussian(block); % returns fitResult and goodness-of-fit
			if gof.sse > threshGof % Unless the fitting was too bad
				aux(s,:)=coeffvalues(fitResult);
				s = s+1;
			end
			if s > numMax; break; end; %If we got the number of maximum
		end

		aux = [aux aux aux];
	else
		for k = 1:3
			for ii = 1:2
				A1 = conv2(double(A(:,:,k)),double(filt));
				X(:,:,ii) = (A1-min(A1(:)))/(max(A1(:))-min(A1(:))); % Normalization
				filt = filt';
			end
			B = sqrt(X(:,:,1).^2+X(:,:,2).^2);
			indices = getAllMax(B, sizeMax,sizeGauss); % The variable 'indices' contains the indices of the maximum
			indices = getGreaterElements(B, indices, 50*numMax);

			%    indices=sortMatrix2d(indices);
			for l=size(indices,1):-1:1
				block=getWindow(B, sizeGauss, indices(l,1)-dxGaussian,indices(l,2)-dxGaussian);
				[fitResult gof]=fitToGaussian(block); % returns fitResult and goodness-of-fit
				if gof.sse > threshGof % Unless the fitting was too bad
					aux(s,:)=coeffvalues(fitResult);
					s=s+1;
				end
				if s/k > numMax; break; end; %If we got the number of maximum
			end
		end


	end
	aux = mean(aux,2); % Here we take the mean of varX and varY
	aux(aux==-1) = [];
	aux = transpose(aux);

	features = zeros(1, sizeFeatures);
	features(1, 1:length(aux)) = aux;

function window = getWindow (matrix, size, XupperLeftCorner, YupperLeftCorner)
	indexX = XupperLeftCorner:XupperLeftCorner+size-1;
	indexY = YupperLeftCorner:YupperLeftCorner+size-1;
	window = matrix(indexX,indexY);


function localMax=getLocalMax (window)
	n=size(window,1);  %suppose a squared window
	k=floor(n/2);
	indMax=[]; 
	neighbourhood=3;
	z=floor(neighbourhood/2);

	for i=1:n;  for j=1:n ; % For each element from the window
		a=window(i,j);
		factor=1; 
		for p=-z:+z
			for q=-z:+z; % Scanning the neighbourhood of aux(i,j)
				if((i==1 && p==-z) || (i==n && p==+z) || (j==1 && q==-z) || (j==n && q==+z)  ) % Border elements
					continue; 
				end;
				if(a<window(i+p,j+q)); factor=0; %if there is a (strict) greater element
				else if(a>window(i+p,j+q)); factor=factor*2; end;
			end;  % If there's a single element that is greater  than a(i,j), then factor'll be 0
		end;
	end;
	if (factor>1); indMax(end+1,:)=[i,j]; end; % Else, if factor==0, then a(i,j) is not a local maximum
end; end; % ... and if factor==1, they are all equal (homogeneous)

myMax=-1; index=[];
for i=1:size(indMax,1)
	if window(indMax(i,1),indMax(i,2))>myMax
		myMax=window(indMax(i,1),indMax(i,2));
		index=indMax(i,:);
	end
end
localMax=index; %We want just one (the global maximum) local maximum

function [fitresult, gof] = fitToGaussian(squareBlock)
	%  Output:
	%      fitresult : an sfit object representing the fit.
	%      gof : structure with goodness-of fit info.

	block=squareBlock;
	n=size(block,1);
	indexCenter=ceil(n/2);
	x0=indexCenter; y0=x0;
	H=block(indexCenter); % We gonna normalize it

	[X Y]=meshgrid(1:n,1:n);
	X = X(:);       Y = Y(:);
	block=block/max(block(:));
	%block=block/H;   % Sometimes the middle is not the peak

	block = block(:);

	ft = fittype(    '1*exp(-(x-x0)^2/(2*sigmax^2)-(y-y0)^2/(2*sigmay^2))',...
		'independent', {'x', 'y'},'dependent',{'z'} , 'coefficients', {'sigmax','sigmay'},...
		'problem',{'x0','y0'} );
	opts = fitoptions( ft );
	opts.Display = 'Off';
	opts.Lower = [-Inf -Inf];
	opts.StartPoint = [.5 .5];
	opts.Upper = [Inf Inf];
	opts.Weights = zeros(1,0);
	opts.DiffMaxChange=0.1;
	opts.DiffMinChange=1e-8;

	[fitresult, gof] = fit( [X, Y], block, ft, opts,'problem',{x0 y0} );

function indices=getAllMax(B, sizeMax,sizeGauss)
	m=size(B,1);    n=size(B,2);
	indicesAux=zeros(floor(m*n/sizeMax^2),2);
	u=1;
	for i=sizeGauss:sizeMax:m-sizeGauss % Actually, we just needed to guarantee floor(sizeGauss/2) in the border
		for j=sizeGauss:sizeMax:n-sizeGauss
			window=getWindow(B,sizeMax,i,j);
			aux=getLocalMax(window);
			if(~isempty(aux))       % If it is not empty...
				aux2=aux+[i-1 j-1]; %   .., insert the localMax
				indicesAux(u,:)=aux2; 
				u=u+1;
			end
		end
	end

	indices=indicesAux; %This part is just to remove the trailing zeros
	for k=1:length(indicesAux)
		if (indicesAux(k,1)==0)
			indices=indicesAux(1:k-1,:);
			break;
		end;
	end


function res = getGreaterElements(matrix,indices,s) 
	%indices is a mx2, where each row represents a (i,j) element

	list=zeros(size(indices,1), 3);
	for i=1:size(indices, 1)
		list(i,1) = indices(i, 1);
		list(i,2) = indices(i, 2);    
		list(i,3) = matrix(indices(i, 1),indices(i,2));
	end
	sortedList = sortrows(list, 3);

	if(size(sortedList, 1)-s+1 < 1)
		i0 = 1;
	else
		i0 = size(sortedList, 1)-s+1;
	end
	res = sortedList(i0:end, 1:2); %Get the s greater elements
