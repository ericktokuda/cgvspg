function ret = getFeatures_popescu(A)

	A = double(A);
        maxiter = 1000;

	if (size(A, 3) < 3)
		[imw, imh] = size(A);

		err = 0.001;
		p0 = 1/(max(A(:))-min(A(:))); 
		%alpha = cell(3,1);

		neigh_i={-1, -1, -1,  0, +1, +1, +1,  0};
		neigh_j={-1,  0, +1, +1, +1,  0, -1, -1};
		n_neigh=length(neigh_i);
		epsilon=1e-6;

		s=10;
		B=A;
		a = rand([1 8]);
		a_prev = a*10;  % Just to enter in the while loop

		shiftedB={};
		for l=1:n_neigh
			shiftedB=cat (2,shiftedB, shiftN(B(:,:),neigh_i{l},neigh_j{l}));
		end

                iter = 0;
		while (norm(a-a_prev)>err)
			a_prev=a;
			% Expectation
			acc=0;
			for k=1:n_neigh
				acc=acc+a(k)*shiftedB{k};
			end

			r = abs(B - acc);

			r2 = r.^2;
			P = exp(-r2/(2*(s+epsilon)^2))/(s*sqrt(2*pi)+epsilon);
			w=P./(P+p0);
			% Maximization
			C=zeros(n_neigh,1);
			M = zeros(n_neigh);        
			for k=1:n_neigh
				aux=w.*shiftedB{k}.*B;
				C(k)=sum(aux(:));
				for l=1:n_neigh
					aux=w.*shiftedB{k}.*shiftedB{l};
					M(k,l)=sum(aux(:));
				end
			end
			a=(M\C)';
			aux=w.*r2;
			s=sqrt(sum(aux)/sum(w));
                        iter = iter + 1
		end
		%alpha{c}=a;    
		%ret=[ret alpha{c}];	
		% ret=[ret P(:)]
		%mapP=-log(abs(fft2(P)));
		newP=P(2:imw-1,2:imw-1);
		aux2 = getStatistics(newP(:));
		ret = [aux2 aux2 aux2];
	else
		[imw, imh rgb] = size(A);

		err = 0.001;
		p0 = 1/(max(A(:))-min(A(:))); 
		%alpha = cell(3,1);

		neigh_i={-1, -1, -1,  0, +1, +1, +1,  0};
		neigh_j={-1,  0, +1, +1, +1,  0, -1, -1};
		n_neigh=length(neigh_i);
		ret=[];
		epsilon=1e-6;

		for c=1:rgb
			s=10;
			B=A(:,:,c);
			a = rand([1 8]);
			a_prev = a*10;  % Just to enter in the while loop

			shiftedB={};
			for l=1:n_neigh
				shiftedB=cat (2,shiftedB, shiftN(B(:,:),neigh_i{l},neigh_j{l}));
			end

                        iter = 0;
			while (norm(a-a_prev)>err & iter < maxiter)
				a_prev=a;
				% Expectation
				acc=0;
				for k=1:n_neigh
					acc=acc+a(k)*shiftedB{k};
				end

				r = abs(B - acc);

				r2 = r.^2;
				P = exp(-r2/(2*(s+epsilon)^2))/(s*sqrt(2*pi)+epsilon);
				w=P./(P+p0);
				% Maximization
				C=zeros(n_neigh,1);
				M = zeros(n_neigh);        
				for k=1:n_neigh
					aux=w.*shiftedB{k}.*B;
					C(k)=sum(aux(:));
					for l=1:n_neigh
						aux=w.*shiftedB{k}.*shiftedB{l};
						M(k,l)=sum(aux(:));
					end
				end
				a=(M\C)';
				aux=w.*r2;
				s=sqrt(sum(aux)/sum(w));
                                iter = iter + 1
			end
			%alpha{c}=a;    
			%ret=[ret alpha{c}];	
			% ret=[ret P(:)]
			%mapP=-log(abs(fft2(P)));
			newP=P(2:imw-1,2:imw-1);
			ret=[ret getStatistics(newP(:))];
		end
	end


function N=shiftN(M,dx,dy)
	[m,n,rgb]=size(M);
	N=zeros(size(M));
	for k=1:rgb
		MM=zeros(m+2*abs(dx),n+2*abs(dy));
		MM(abs(dx)+1:abs(dx)+m,abs(dy)+1:n+abs(dy))=M(:,:,k);
		N(:,:,k)=MM(abs(dx)+1+dx:abs(dx)+m+dx,abs(dy)+1+dy:abs(dy)+n+dy);
	end

function s =getStatistics (a)
	s=zeros(1,4);
	s(1) = mean(a); 
	s(2) = var(a);
	s(3) = skewness(a);
	s(4) = kurtosis(a);


function features=getHaralick4features(A)
	C=graycomatrix(A,'NumLevels',256);                      
	D=graycoprops(C);
	features(1)=getfield(D,'Contrast');     features(2)=getfield(D,'Correlation');
	features(3)=getfield(D,'Energy');       features(4)=getfield(D,'Homogeneity');



