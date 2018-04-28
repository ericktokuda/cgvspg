function [coeff_h coeff_v] = demo_shear_coeff(img)

% Display shearlet coefficients across all scales (5 levels)
% Input : 
%   img : Input image
% Output :
%   coeff_h : cell array consisting of shearlet coefficients 
%             associated with [1 1; 0 1] for horizontal cone in frequency
%   coeff_v : cell array consisting of shearlet coefficients 
%             associated with [1 0; 1 1] for vertical cone in frequency
%
%   coeff_h{1} = shearlet coefficients at the finest level 
%                ( size of support of shearlets = 2^(-4) by 2^(-2) )
%                the number of directions = 9 
%   coeff_h{2} = shearlet coefficients at the second level 
%                ( size of support of shearlets = 2^(-3) by 2^(-2) )
%                the number of directions = 9 
%   coeff_h{3} = shearlet coefficients at the third level 
%                ( size of support of shearlets = 2^(-2) by 2^(-1) )
%                the number of directions = 5
%   coeff_h{4} = shearlet coefficients at the fourth level 
%                ( size of support of shearlets = 2^(-1) by 2^(-1) )
%                the number of directions = 5
%   coeff_h{5} = shearlet coefficients at the coarsest level 
%                ( size of support of shearlets =  2^(0) by 2^(0) ) 
%                the number of directions = 3
%   coeff_v{5} = shearlet coefficients at the finest level 
%                ( size of support of shearlets = 2^(-2) by 2^(-4) )
%                the number of directions = 9
%   ...............
%
%   coeff_v{1} = shearlet coefficients at the coarsest level 
%                ( size of support of shearlets =  2^(0) by 2^(0) ) 
%                the number of directions = 3

if nargin < 1
    img = double(imread('zoneplate.png','png'));
end
[row col] = size(img);
ndir = [2 2 1 1 0];

for j = 1:5
    for k = -2^(ndir(j)):2^(ndir(j))
        coeff_h{j}(:,:,k+(2^(ndir(j))+1)) = obtain_shear_coeff(img,[3 3 4 4 5],ndir(j),'hor',j,k);
        coeff_v{j}(:,:,k+(2^(ndir(j))+1)) = obtain_shear_coeff(img,[3 3 4 4 5],ndir(j),'ver',j,k);
    end
end

% Display original image

colormap gray;
subplot(1,1,1), imagesc( img, [0 255] ) ; 
title( sprintf('Original Image' )) ;

% Display shearlet coeff for horizontal cone

figure; clf;
colormap gray;
tmp1 = []; tmp2 = []; tmp3 = []; tmp4 = []; tmp5 = [];
for k = 1:9
    if k < 9 
        tmp1 = [ tmp1; coeff_h{1}(:,:,k); 255*ones(5,col/2) ];
    else
        tmp1 = [ tmp1; coeff_h{1}(:,:,k)];
    end
end
for k = 1:9
    if k < 9 
        tmp2 = [ tmp2; coeff_h{2}(:,:,k); 255*ones(5,col/4) ];
    else
        tmp2 = [ tmp2; coeff_h{2}(:,:,k)];
    end
end
for k = 1:5
    if k < 5
        tmp3 = [ tmp3; coeff_h{3}(:,:,k); 255*ones(5,col/8) ];
    else
        tmp3 = [ tmp3; coeff_h{3}(:,:,k)];
    end
end
for k = 1:5
    if k < 5 
        tmp4 = [ tmp4; coeff_h{4}(:,:,k); 255*ones(5,col/16) ];
    else
        tmp4 = [ tmp4; coeff_h{4}(:,:,k)];
    end
end
for k = 1:3
    if k < 3
        tmp5 = [ tmp5; coeff_h{5}(:,:,k); 255*ones(5,col/32) ];
    else
        tmp5 = [ tmp5; coeff_h{5}(:,:,k)];
    end
end

subplot(1,5,1), imagesc( tmp1 ) ; 
subplot(1,5,2), imagesc( tmp2 ) ; 
subplot(1,5,3), imagesc( tmp3 ) ; 
title( sprintf('Shearlet Coefficients for horizontal cone' )) ;
subplot(1,5,4), imagesc( tmp4 ) ; 
subplot(1,5,5), imagesc( tmp5 ) ; 

% Display shearlet coeff for vertical cone 

figure; clf;
colormap gray;
tmp1 = []; tmp2 = []; tmp3 = []; tmp4 = []; tmp5 = [];
for k = 1:9
    if k < 9
        tmp1 = [ tmp1 coeff_v{1}(:,:,k) 255*ones(row/2,5) ];
    else
        tmp1 = [ tmp1 coeff_v{1}(:,:,k)];
    end
end
for k = 1:9
    if k < 9
        tmp2 = [ tmp2 coeff_v{2}(:,:,k) 255*ones(row/4,5) ];
    else
        tmp2 = [ tmp2 coeff_v{2}(:,:,k)];
    end
end
for k = 1:5
    if k < 5
        tmp3 = [ tmp3 coeff_v{3}(:,:,k) 255*ones(row/8,5) ];
    else
        tmp3 = [ tmp3 coeff_v{3}(:,:,k)];
    end
end
for k = 1:5
    if k < 5
        tmp4 = [ tmp4 coeff_v{4}(:,:,k) 255*ones(row/16,5) ];
    else
        tmp4 = [ tmp4 coeff_v{4}(:,:,k)];
    end
end
for k = 1:3
    if k < 3
        tmp5 = [ tmp5 coeff_v{5}(:,:,k) 255*ones(row/32,5) ];
    else
        tmp5 = [ tmp5 coeff_v{5}(:,:,k)];
    end
end

subplot(5,1,1), imagesc( tmp1 ) ; 
title( sprintf('Shearlet Coefficients for vertical cone' )) ;
subplot(5,1,2), imagesc( tmp2 ) ; 
subplot(5,1,3), imagesc( tmp3 ) ; 
subplot(5,1,4), imagesc( tmp4 ) ; 
subplot(5,1,5), imagesc( tmp5 ) ; 



%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m







