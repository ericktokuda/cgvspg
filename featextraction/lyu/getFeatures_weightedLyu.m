function features=getFeatures_weightedLyu(pathToImage)

warning ('OFF','all');
lowFilter=[0.02807382 -0.060944743 -0.073386624; 0.41472545 0.7973934 0.41472545; 0.073386624 -0.060944743 0.02807382];
highFilter=[0.02807382 0.060944743 -0.073386624; -0.41472545 0.7973934 -0.41472545; -0.073386624 0.060944743 0.02807382];
nScales=4; 
threshold=0.01;

A=imread(pathToImage);
if (size(A,3)<3 ) %just colored images
    disp (['Skipping ', pathToImage, ': one colour band']);    
    features=-1;
    return;
end

[D V H] = waveletDecomposition(A,lowFilter,highFilter,nScales);

res1=getFirstSet(D, V, H, nScales); %first half of the array (108-d)
res2=getSecondSet(D,V,H, nScales,threshold); %returns a 108-D array
features=[res1 res2];

%End of Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [D V H] = waveletDecomposition(A,lowFilter,highFilter,nScales)
D=zeros(size(A,1),size(A,2),nScales); V=D; H=D;
for k=1:3  %for each color chanel
    for j=1:nScales %for each scale
        D(:,:,j,k)=conv2(conv2(A(:,:,k),highFilter, 'same'),highFilter, 'same');
        V(:,:,j,k)=conv2(conv2(A(:,:,k),lowFilter, 'same'),highFilter, 'same');
        H(:,:,j,k)=conv2(conv2(A(:,:,k),highFilter, 'same'),lowFilter, 'same');
        A(:,:,k)=conv2(conv2(A(:,:,k),lowFilter,'same'),lowFilter,'same');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v=getFirstSet (D,V,H,nScales)
% Sketch of the features vector
% _________________________________________________
% %%----|----|----%%----|----|----%%----|----|----%%
%      colour 1         colour2         colour3  
%
%  - where each segment in each colour represents
%     a scale i=1,2,3 of the subbands (D,V,H)
%
m=size(D,1);    n=size(D,2);

DD=reshape(permute(D,[2 1 3 4]),1,m*n,nScales,3); % Linearization
VV=reshape(permute(V,[2 1 3 4]),1,m*n,nScales,3); % We permute first because we want 
HH=reshape(permute(H,[2 1 3 4]),1,m*n,nScales,3); % the linearization of the LINES of the subband

v=zeros(1,108);
for k=1:3 %for each color channel
    for j=1:nScales-1 %for each scale
         v(1,(1:4)+(j-1)*12+(k-1)*36)  =getStatistics(DD(1,:,j,k));            
         v(1,(5:8)+(j-1)*12+(k-1)*36)  =getStatistics(VV(1,:,j,k));            
         v(1,(9:12)+(j-1)*12+(k-1)*36) =getStatistics(HH(1,:,j,k));                         
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function features=getSecondSet(D,V,H,nScales,threshold) 
% Get the predictors of the elements and then the errors of them
m=size(D,1);    n = size(D,2);
DD=zeros(9,m-2,n-2); VV=DD; HH=DD;	%They are the matrix of neighbours
features = zeros(1,108);

for k=1:3 %For each color channel,
	for j=1:nScales-1 %for each scale,
        for x=2:m-1 %and for each (x,y),
            for y=2:n-1 %we get the neighbours, according to Lyu(2005)
                [DD(:,x-1,y-1) VV(:,x-1,y-1) HH(:,x-1,y-1)]=get9Neighbours(x,y,j,k,D,V,H);
            end
        end
        factor=1/2^(j);		additionalFactor=1/2;
        DD=DD*factor;	VV=VV*factor;	HH=HH*factor;
        DD(1:4,:,:)=DD(1:4,:,:)*additionalFactor;	VV(1:4,:,:)=VV(1:4,:,:)*additionalFactor;	HH(1:4,:,:)=HH(1:4,:,:)*additionalFactor;
        DD(5,:,:)=DD(5,:,:)*additionalFactor;	VV(5,:,:)=VV(5,:,:)*additionalFactor;	HH(5,:,:)=HH(5,:,:)*additionalFactor;
        VV(6,:,:)=VV(6,:,:)*additionalFactor;	HH(6,:,:)=HH(6,:,:)*additionalFactor;

        features=computePredictor(features,D,DD,j,k,m,n,threshold,0);
        features=computePredictor(features,V,VV,j,k,m,n,threshold,4);                
        features=computePredictor(features,H,HH,j,k,m,n,threshold,8);
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Dneigh,Vneigh,Hneigh]=get9Neighbours(x,y,j,k,Daug,Vaug,Haug)
% The neighbours were choosen according to the work of Lyu
Dneigh=zeros(9,1);    Vneigh=zeros(9,1);    Hneigh=zeros(9,1);
c2=mod(k,3)+1;    c3=mod(c2,3)+1; % The indices of the two other colours

Dneigh(1:4) = get4neighbours(Daug,x,y,j,k); Vneigh(1:4) = get4neighbours(Vaug,x,y,j,k); Hneigh(1:4) = get4neighbours(Haug,x,y,j,k); 
Dneigh(5) =Daug(round(x/2),round(y/2),j+1,k); Vneigh(5) =Vaug(round(x/2),round(y/2),j+1,k); Hneigh(5) =Haug(round(x/2),round(y/2),j+1,k);
Dneigh(6) =Haug(x,y,j,k);  Vneigh(6) =Daug(x,y,j,k);                     Hneigh(6) =Daug(x,y,j,k);
Dneigh(7) =Vaug(x,y,j,k);  Vneigh(7) =Daug(round(x/2),round(y/2),j+1,k); Hneigh(7) =Daug(round(x/2),round(y/2),j+1,k);
Dneigh(8) =Daug(x,y,j,c2); Vneigh(8) =Vaug(x,y,j,c2);                    Hneigh(8) =Haug(x,y,j,c2);
Dneigh(9) =Daug(x,y,j,c3); Vneigh(9) =Vaug(x,y,j,c3);                    Hneigh(9) =Haug(x,y,j,c3);    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function v=get4neighbours(S,x,y,j,k)
v=zeros(1,4);
v(1)=S(x-1,y,j,k); v(2)=S(x+1,y,j,k); v(3)=S(x,y-1,j,k); v(4)=S(x,y+1,j,k);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = computePredictor(res, S,SS,j,k,m,n,threshold,offset)
v=reshape(S(2:m-1,2:n-1,j,k),(m-2)*(n-2),1); % Column oriented linearization of the subband matrix
Q=(reshape(SS,9,(m-2)*(n-2)))'; % 3d -> 2d 

w=(Q'*Q)\(Q'*v); 
pp=zeros(length(v),1);
ind1=1;
for ind2=1:length(v)
    aux1=abs(v(ind2));
    aux2=abs(Q(ind2,:)*w);
    if( aux1 > threshold && aux2 > threshold)
        pp(ind1)=log(aux1)-log(aux2); % p is an array of size m*n
        ind1=ind1+1;
    end
end
aux=find(pp);
p=pp(1:aux(end));

res(1,(1:4)+offset+(j-1)*12+(k-1)*36) =getStatistics(p); %get the statistics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s =getStatistics (a)
s(1) =mean(a); 
s(2) =var(a);
s(3) =skewness(a);
s(4) =kurtosis(a);

