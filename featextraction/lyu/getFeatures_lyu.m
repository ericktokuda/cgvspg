function features=getFeatures_lyu(A)

	lowFilter=[0.02807382 -0.060944743 -0.073386624 0.41472545 0.7973934 0.41472545 0.073386624 -0.060944743 0.02807382];
	highFilter=[0.02807382 0.060944743 -0.073386624 -0.41472545 0.7973934 -0.41472545 -0.073386624 0.060944743 0.02807382];
	nScales=4; 
	threshold=0.01;

	D=cell(nScales, 3); V=D; H=D;
	is_rgb = size(A,3) == 3;

	if (~is_rgb) %just colored images
		[C L] = wavedec2(A, nScales, lowFilter, highFilter);
		for s=1:nScales
			[H{s, 1} V{s, 1} D{s, 1}] = detcoef2('all', C, L, s);
			H{s, 2} = H{s, 1}; H{s, 3} = H{s, 1};
			V{s, 2} = V{s, 1}; V{s, 3} = V{s, 1};
			D{s, 2} = D{s, 1}; D{s, 3} = D{s, 1};
		end
	else
		for k=1:3
			[C L] = wavedec2(A(:, :, k), nScales, lowFilter, highFilter);
			parfor s=1:nScales
				[H{s,k} V{s,k} D{s,k}] = detcoef2('all', C, L, s);
			end
		end

	end

	res1 = getFirstSet(D, V, H, nScales); %first half of the array (108-d)
	res2 = getSecondSet(D, V, H, nScales, threshold, is_rgb); %returns a 109-D array

	features=[res1 res2];

	%End of Main
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v = getFirstSet(D,V,H,nScales)

	v=zeros(1,108);
	for k=1:3 %for each color channel
		for j=1:nScales-1 %for each scale
			Dneigh=D{j,k}; Vneigh=V{j,k}; Hneigh=H{j,k};
			v(1,(1:4)+(j-1)*12+(k-1)*36) = getStatistics(Dneigh(:));
			v(1,(5:8)+(j-1)*12+(k-1)*36) = getStatistics(Vneigh(:));
			v(1,(9:12)+(j-1)*12+(k-1)*36)= getStatistics(Hneigh(:));
		end
	end

function features = getSecondSet(D,V,H,nScales,threshold, is_rgb) 
	% Get the predictors of the elements and then the errors of them

	features = zeros(1, 108);

	if (~is_rgb)
		for s=1:nScales-1 %for each scale
			m = size(D{s, 1}, 1);
			n = size(D{s, 1}, 2);
			Dneigh = zeros(9, m-2, n-2); Vneigh=Dneigh; Hneigh=Dneigh; 	%They are the matrix of neighbours        
			for x=2:m-1 %and for each (x,y)
				for y=2:n-1 % we get the neighbours
					[Dneigh(:,x-1,y-1) Vneigh(:,x-1,y-1) Hneigh(:,x-1,y-1)]=get9Neighbours(x,y,s,1,D,V,H);
				end
			end
			featD = computePredictor(D, Dneigh, s, 1, m, n, threshold);
			featV = computePredictor(V, Vneigh, s, 1, m, n, threshold);                
			featH = computePredictor(H, Hneigh, s, 1, m, n, threshold);
			features((s-1)*12+(1-1)*36+(1:12))=[featD featV featH];
		end
		features((s-1)*12+(2-1)*36+(1:12))=[featD featV featH];
		features((s-1)*12+(3-1)*36+(1:12))=[featD featV featH];
	else
		for k=1:3 %for each color channel
			for s=1:nScales-1 %for each scale
				m = size(D{s, k}, 1);
				n = size(D{s, k}, 2);
				%They are the matrix of neighbours        
				Dneigh = zeros(9,m-2,n-2); Vneigh = Dneigh; Hneigh = Dneigh;
				for x = 2:m-1 %and for each (x,y)
					for y=2:n-1 %we get the neighbours, according to Lyu(2005)
						[Dneigh(:,x-1,y-1) Vneigh(:,x-1,y-1) Hneigh(:,x-1,y-1)]=get9Neighbours(x,y,s,k,D,V,H);
					end
				end
				featD = computePredictor(D, Dneigh, s, k, m, n, threshold);
				featV = computePredictor(V, Vneigh, s, k, m, n, threshold);
				featH = computePredictor(H, Hneigh, s, k, m, n, threshold);
				features((s-1)*12+(k-1)*36+(1:12))=[featD featV featH];
			end
		end
	end


function [Dneigh,Vneigh,Hneigh] = get9Neighbours(x,y,s,k,Daug,Vaug,Haug)
	% The neighbours were choosen according to the work of Lyu
	Dneigh=zeros(9,1);    Vneigh=zeros(9,1);    Hneigh=zeros(9,1);
	c2=mod(k,3)+1;    c3=mod(c2,3)+1; % The indices of the two other colours

	Dneigh(1:4) = get4neighbours(Daug,x,y,s,k); Vneigh(1:4) = get4neighbours(Vaug,x,y,s,k); Hneigh(1:4) = get4neighbours(Haug,x,y,s,k); 
	Dneigh(5) =Daug{s+1,k}(round(x/2),round(y/2)); Vneigh(5) =Vaug{s+1,k}(round(x/2),round(y/2)); Hneigh(5) =Haug{s+1,k}(round(x/2),round(y/2));
	Dneigh(6) =Haug{s,k}(x,y);  Vneigh(6) =Daug{s,k}(x,y);                     Hneigh(6) =Daug{s,k}(x,y);
	Dneigh(7) =Vaug{s,k}(x,y);  Vneigh(7) =Daug{s+1,k}(round(x/2),round(y/2)); Hneigh(7) =Daug{s+1,k}(round(x/2),round(y/2));
	Dneigh(8) =Daug{s,c2}(x,y); Vneigh(8) =Vaug{s,c2}(x,y);                    Hneigh(8) =Haug{s,c2}(x,y);
	Dneigh(9) =Daug{s,c3}(x,y); Vneigh(9) =Vaug{s,c3}(x,y);                    Hneigh(9) =Haug{s,c3}(x,y);    

function v=get4neighbours(S,x,y,s,k)
	v=zeros(1,4);
	v(1)=S{s,k}(x-1,y); v(2)=S{s,k}(x+1,y); v(3)=S{s,k}(x,y-1); v(4)=S{s,k}(x,y+1);

function res = computePredictor(S,SS,s,k,m,n,threshold)
	% Column oriented linearization of the subband matrix
	v = reshape(S{s,k}(2:m-1,2:n-1),(m-2)*(n-2),1); 
	Q = (reshape(SS,9,(m-2)*(n-2)))'; % 3d -> 2d 

	w=(Q'*Q)\(Q'*v); 

	% p=log(abs(v))-log(abs(Q*w)); % p is an array of size m*n
	pp=zeros(length(v),1);
	ind1 = 1;

	for ind2=1:length(v)
		aux1 = abs(v(ind2));
		aux2 = abs(Q(ind2,:)*w);
		if( aux1 > threshold && aux2 > threshold) %Just values above threshold
			pp(ind1)=log(aux1)-log(aux2); % p is an array of size m*n
			ind1=ind1+1;
		end
	end

	aux = find(pp);
	if (size(aux, 1) == 0)
		res = [ 0 0 0 0];
	else
		p = pp(1:aux(end));
		res = getStatistics(p);
	end

function s =getStatistics (a)
	s=zeros(1,4);
	s(1) = mean(a); 
	s(2) = var(a);
	s(3) = skewness(a);
	s(4) = kurtosis(a);
