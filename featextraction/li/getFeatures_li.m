function features=getFeatures_li(A)
	threshold=0.01; %above this, we get a lot of NaN s

	if (size(A,3)<3) %just colored images
		aux = zeros([size(A) 3]);
		aux(:, :, 1) = A;
		aux(:, :, 2) = A;
		aux(:, :, 3) = A;
		A = aux;
	end

	B = rgb2hsv(A);
	C = imresize(B, 0.5);

	[D1,D2,V,H] = getSecondOrderDiff(B);
	[D1_scaled,D2_scaled,V_scaled,H_scaled] = getSecondOrderDiff(C);

	res1 = getFirstSet(D1, D2, V, H); % 1st quarter of the array (24-d)
	res2 = getSecondSet(D1, D2, V, H, threshold); % 2nd quarter of the array (24-d)

	res3 = getFirstSet (D1_scaled, D2_scaled, V_scaled, H_scaled); % 3rd quarter of the array (24-d)
	res4 = getSecondSet(D1_scaled, D2_scaled, V_scaled, H_scaled, threshold); % 4th quarter of the array (24-d)

	features=[res1 res2 res3 res4];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Approximate second order derivative
function [D1,D2,V,H] = getSecondOrderDiff(B)
	[m n p]=size(B);
	D1=zeros(m-2,n-2,p); D2=D1; V=D1; H=D1;
	for k=1:p
		for i=2:m-1
			for j=2:n-1
				H(i,j,k) = 2*B(i,j,k) - B(i  ,j-1,k) - B(i,j+1,k);
				V(i,j,k) = 2*B(i,j,k) - B(i-1, j ,k) - B(i+1,j,k);            
				D1(i,j,k)= 2*B(i,j,k) - B(i-1,j-1,k) - B(i+1,j+1,k);
				D2(i,j,k)= 2*B(i,j,k) - B(i-1,j+1,k) - B(i+1,j-1,k);            
			end
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Half-scale image(according to eq.14 from the article)
function C=scaleImage(B)
	[m n p] = size(B);
	if (mod(m,2)==0); q=m/2-1; else q=(m-1)/2; end;
	if (mod(n,2)==0); r=n/2-1; else r=(n-1)/2; end;
	C=zeros(q,r,p);
	for i=1:q
		for j=1:r
			for k=1:p
				i2=2*i; j2=2*j;
				aux = (B(i2,j2,k) + B(i2+1,j2,k) + B(i2,j2+1,k) + B(i2+1,j2+1,k))/4;
				C(i,j,k) = uint8(aux); 
			end
		end
	end

	% Get the first set of statistics according to the work of 2010
function features=getFirstSet (D1,D2,V,H)
	features=zeros(1,24);
	features(1:6)=get2Statistics(D1);
	features(7:12)=get2Statistics(D2);
	features(13:18)=get2Statistics(V);
	features(19:24)=get2Statistics(H);

function res=get2Statistics(A)
	[m n p]=size(A);
	B=reshape(A,1,m*n,p); % Linearization
	res=zeros(1,2*p);
	for k=1:p
		res(2*k-1)=var(B(:,:,k));
		res(2*k)=kurtosis(B(:,:,k));
	end

	% Get the first 4 orders statistics
function res=get4Statistics(A)
	[m n p]=size(A);
	B=reshape(A,1,m*n,p); % Linearization
	res=zeros(1,4*p);
	for k=1:p
		res(4*k-3)= mean(B(:,:,k));
		res(4*k-2)= var(B(:,:,k));
		res(4*k-1)= skewness(B(:,:,k));    
		res(4*k)  = kurtosis(B(:,:,k));
	end

	% Get the predictors of the elements and then the errors of them
function features=getSecondSet(D1,D2,V,H, threshold) 
	[m n k]=size(D1);


	features = zeros(1,48);
	numSubbands=4;
	A=zeros(m,n,k,4);
	A(:,:,:,1)=D1; A(:,:,:,2)=D2; A(:,:,:,3)=V; A(:,:,:,4)=H; 
	A=abs(A);

	for rgb=1:k % 3 colours
		for l=1:numSubbands % 4 subbands, check formula (11) in the article
			[Q v]=assembleQandV(A,l,rgb);
			w=(Q'*Q)\(Q'*v); 
			p=assembleP(v,Q,w,threshold);
			aux=(rgb-1)*numSubbands*4+4*(l-1);
			features(aux+1:aux+4)=get4Statistics(p);
		end
	end

function [Q v]=assembleQandV(A, ind, rgb)
	[m,n,~,~ ]=size(A);
	Q=zeros(m*n,3); v=zeros(m*n,1);
	aux=1:4; aux(ind)=[]; % aux will be used to know which neighbours to use
	for i=1:m  % First, we gonna assemble Q and v
		for j=1:n % For each (i,j) position
			Q((i-1)*n+j,:)=[A(i,j,rgb,aux(1)) A(i,j,rgb,aux(2)) A(i,j,rgb,aux(3))];
			v((i-1)*n+j)=A(i,j,rgb,ind);
		end
	end

function p=assembleP(v,Q,w,thresh)
	p=zeros(size(v,1),1);
	ind_p=1;
	for ind_v=1:length(v) 
		aux1=abs(v(ind_v)); %Check if they are above threshold
		aux2=abs(Q(ind_v,:)*w);
		if( aux1 > thresh && aux2 > thresh)
			p(ind_p)=log(aux1)-log(aux2); % p is an array of size m*n
			ind_p=ind_p+1;
		end
	end
	p(ind_p:end)=[];
