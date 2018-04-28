function features=getFeatures_lbp(pathToImage)

m=24; %Number of sampling points (check function lbp.m)
r=3;

oldDir=chdir('/mnt/ext3/Dropbox/forensics/matlab/lbp/');

A=imread(pathToImage);
if (size(A,3)<3 ) %just colored images
    disp (['Skipping ', pathToImage, ': one colour band']);    
    features=-1;
    return;
end
%word=zeros(size(A));
LBPHIST=zeros(m+2,3);


for k=1:3
       MAPPING=getmapping(m,'riu2');%Rotation-invariant (ri) and uniform(u2)
       LBPHIST(:,k)=lbp(A(:,:,k),r,m,MAPPING,'hist');
end

features=LBPHIST(:);
chdir(oldDir);
%End of Main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
