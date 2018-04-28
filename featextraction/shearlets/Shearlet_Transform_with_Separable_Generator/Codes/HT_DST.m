function out = HT_DST(nimage,qmf1,qmf2,ndir,scale,sigma,opt,lim1,lim2,thr,axis)

%   HT_DST  Hard (extended) Shearlet Thresholding of image
%           ( Image denoising using shearlets )
%
% Usage:  
%	y = HT_DST(x, qmf1,qmf2, ndir, scale, sigma, opt, lim_x, lim_y, thr, x_y)
%
% Input:
%   x:      input image
%
%   For j = 1,...,L (where L = size of input vector 'scale'), 
%   qmf1: 1D Quadrature mirror filter associated with scaling 2^(L-j) 
%   qmf2: 1D Quadrature mirror filter associated with scaling 2^(L-s(j)) 
%   ( see MakeONFilter.m in WaveLab )
%   ndir:    if x_y = 'hor' or 'ver'
%            then number of directions = 2^(ndir+1)+1;
%            if x_y = 'both'
%            then number of directions = 2^(ndir+2)+2;
%
%   scale: row vector consisting of sizes of shearlets across scales 
%           scale =  [s(1),...,s(L)].
%
%   For the horizontal cone associated with shear matrix [1 1;0 1],
%   the value s(j) determines the size of the support of shearlets : 
%   For j = 1,...,L, 2^(-1*(L-j)) by 2^(-1*(L-s(j))) at jth scale.
%
%   For the vertical cone associated with shear matrix [1 0;1 1],
%   the value s(j) determines the size of the support of shearlets :  
%   For j = 1,...,L, 2^(-1*(L-s(j))) by 2^(-1*(L-j)) at jth scale.
%
%   For example, when scale = [3 3 4 4 5],   
%   size of support = 2^(-4) by 2^(-2) at the finest scale
%   size of support = 2^(-3) by 2^(-2) at the second scale
%   size of support = 2^(-2) by 2^(-1) at the third scale
%   size of support = 2^(-1) by 2^(-1) at the fourth scale
%   size of support = 2^(0) by 2^(0) at the coarsest scale
%   for the horizontal cone. 
%   
%   sigma: standard deviation of Gaussian noise
%   opt:   option for thresholding (e.g. Soft or Hard)
%          see thresh_fct.m for details
%   lim_x: number of translates along the axis associated with scaling 2^(L-j)
%   lim_y: number of translates along the axis associated with scaling 2^(L-s(j))
%   thr:   row vector consisting of thresholding parameters across scales
%          thr = [T(1),...,T(L)] where T(1) is a thresholding parameter for
%          the finest scale .... T(L) is for the coarsest scale
%   x_y:   x_y = 'hor' ---> take (extended) shearlet 
%                 transform associated with shear matrix [1 1;0 1]
%                 for the horizontal cone only. 
%                 In this case, 2^(ndir+1)+1 directional components
%                 associated with shear matrices [1 k/2^(ndir); 0 1]
%                 for k = -2^(ndir)...2^(ndir) will be produced.
%                 ( see half_sampled_DST1.m )
%          x_y = 'ver' ---> take (extended) shearlet transform associated
%                 with shear matrix [1 0;1 1] for the vertical cone only.
%                 In this case, 2^(ndir+1)+1 directional components 
%                 associated with shear matirces [1 0; k/2^(ndir) 1]
%                 for k = -2^(ndir)...2^(ndir) will be produced. 
%          x_y = 'both' ---> take both types of shearings to produce 
%                 2^(ndir+2)+2 directional components
% Output:
%   y:    denoised image ( image reconstructed from hard thresholded 
%                          shearlet coefficients )  
%
%
% See also: HALF_SAMPLED_DST1, THRESH_FCT, SYM_EXT, SYM_SUM,
%           HALF_ADJ_SAMPLED_DST1

tic;
% symmetric extension : apply a vertical reflection 
% this will produce N1 by 2*N2 from N1 by N2 input image   
nimage1 = sym_ext(nimage,0);
% symmetric extension : apply a horizontal reflection 
% this will produce 2*N1 by N2 from N1 by N2 input image   
nimage2 = sym_ext(nimage,1);

% check size info. on input image
[m1 n1] = size(nimage1);
[m2 n2] = size(nimage2);

%initialize
out1 = zeros(m1,n1);
out2 = zeros(m2,n2);

ddd1 = zeros(m1,n1,2^(ndir+1)+1);
ddd2 = zeros(m2,n2,2^(ndir+1)+1);

for i = 0:lim1-1
    for j = 0:lim2-1
        if strcmp(axis,'both')
            % translate symmetrically extended image
            Noistrans1 = cyclespin2(nimage1,j,i);
            Noistrans2 = cyclespin2(nimage2,i,j);
            % take (extended) shearlet transform for shear matrix [1 1;0 1]
            % on each translated image
            dd1 = half_sampled_DST1(Noistrans1,qmf1,qmf2,scale,ndir,0);
            % take (extended) shearlet transform for shear matrix [1 0;1 1]
            % on each translated image
            dd2 = half_sampled_DST1(Noistrans2,qmf1,qmf2,scale,ndir,1);
        elseif strcmp(axis,'hor') 
            % translate symmetrically extended image (vertical reflection)
            Noistrans1 = cyclespin2(nimage1,j,i);
            % take (extended) shearlet transform for shear matrix [1 1;0 1]
            % on each translated image 
            dd1 = half_sampled_DST1(Noistrans1,qmf1,qmf2,scale,ndir,0);
        else
            % translate symmetrically extended image (horizontal reflection)
            Noistrans2 = cyclespin2(nimage2,i,j);
            % take (extended) shearlet transform for shear matrix [1 0;1 1]
            % on each translated image
            dd2 = half_sampled_DST1(Noistrans2,qmf1,qmf2,scale,ndir,1);
        end
        % Threshold shearlet coefficients across all scales
        for k = 1:2^(ndir+1)+1
            for l = 1:length(scale)
                for q = 1:2^(scale(l))
                    if strcmp(axis,'both')
                        tab1 = m1/2^(scale(l)); tab2 = n2/2^(scale(l));
                        temp1 = dd1((q-1)*tab1+1:q*tab1,n1/2^l+1:n1/2^(l-1),k);
                        temp2 = dd2(m2/2^l+1:m2/2^(l-1),(q-1)*tab2+1:q*tab2,k);
                        ddd1((q-1)*tab1+1:q*tab1,n1/2^l+1:n1/2^(l-1),k) = thresh_fct(temp1,sigma,opt,thr(l),0);
                        ddd2(m2/2^l+1:m2/2^(l-1),(q-1)*tab2+1:q*tab2,k) = thresh_fct(temp2,sigma,opt,thr(l),0);
                    elseif strcmp(axis,'hor') 
                        tab1 = m1/2^(scale(l)); tab2 = n2/2^(scale(l));
                        temp1 = dd1((q-1)*tab1+1:q*tab1,n1/2^l+1:n1/2^(l-1),k);
                        ddd1((q-1)*tab1+1:q*tab1,n1/2^l+1:n1/2^(l-1),k) = thresh_fct(temp1,sigma,opt,thr(l),0);
                    else strcmp(axis,'ver')
                        tab1 = m1/2^(scale(l)); tab2 = n2/2^(scale(l));
                        temp2 = dd2(m2/2^l+1:m2/2^(l-1),(q-1)*tab2+1:q*tab2,k);
                        ddd2(m2/2^l+1:m2/2^(l-1),(q-1)*tab2+1:q*tab2,k) = thresh_fct(temp2,sigma,opt,thr(l),0);
                    end
                end
            end
            for p = 1:length(scale)
                if strcmp(axis,'both')
                    temp1 = dd1(m1/2^p+1:m1/2^(p-1),1:n1/2^l,k);
                    temp2 = dd2(1:m2/2^l,n2/2^p+1:n2/2^(p-1),k);
                    ddd1(m1/2^p+1:m1/2^(p-1),1:n1/2^l,k) = thresh_fct(temp1,sigma,opt,thr(l),0);
                    ddd2(1:m2/2^l,n2/2^p+1:n2/2^(p-1),k) = thresh_fct(temp2,sigma,opt,thr(l),0);
                elseif strcmp(axis,'hor')
                    temp1 = dd1(m1/2^p+1:m1/2^(p-1),1:n1/2^l,k);
                    ddd1(m1/2^p+1:m1/2^(p-1),1:n1/2^l,k) = thresh_fct(temp1,sigma,opt,thr(l),0);
                else
                    temp2 = dd2(1:m2/2^l,n2/2^p+1:n2/2^(p-1),k);
                    ddd2(1:m2/2^l,n2/2^p+1:n2/2^(p-1),k) = thresh_fct(temp2,sigma,opt,thr(l),0);
                end
            end
            if strcmp(axis,'both')
                ddd1(1:m1/2^p,1:n1/2^p,k) = dd1(1:m1/2^p,1:n1/2^p,k); 
                ddd2(1:m2/2^p,1:n2/2^p,k) = dd2(1:m2/2^p,1:n2/2^p,k);
            elseif strcmp(axis,'hor')
                ddd1(1:m1/2^p,1:n1/2^p,k) = dd1(1:m1/2^p,1:n1/2^p,k); 
            else
                ddd2(1:m2/2^p,1:n2/2^p,k) = dd2(1:m2/2^p,1:n2/2^p,k);
            end
        end
        % take inverse (extended) shearlet transform on the thresholded
        % coefficients to reconstruct symmetrically extended image
        if strcmp(axis,'both')
            dout1 = 1/(2^(ndir+1)+1)*half_adj_sampled_DST1(ddd1,qmf1,qmf2,scale,ndir,0);
            dout2 = 1/(2^(ndir+1)+1)*half_adj_sampled_DST1(ddd2,qmf1,qmf2,scale,ndir,1);
            dout1 = cyclespin2(dout1,m1-j,n1-i);dout2 = cyclespin2(dout2,m2-i,n2-j);
		    out1 = out1+dout1;
            out2 = out2+dout2;
        elseif strcmp(axis,'hor')
            dout1 = 1/(2^(ndir+1)+1)*half_adj_sampled_DST1(ddd1,qmf1,qmf2,scale,ndir,0);
            out1 = out1+dout1;
        else
            dout2 = 1/(2^(ndir+1)+1)*half_adj_sampled_DST1(ddd2,qmf1,qmf2,scale,ndir,1);
            out2 = out2+dout2;
        end
    end
end

if strcmp(axis,'both')
    % obtain a restored image (N1 by N2) from two symmetrically extended 
    % images (N1 by 2*N2 and 2*N1 by N2)
    out = 0.5*(sym_sum(out1,0)+sym_sum(out2,1));
    out=1/(lim1*lim2)*(1/(2))*out;
elseif strcmp(axis,'hor') 
    % obtain a restored image (N1 by N2) from symmetrically extended image
    % (N1 by 2*N2)
    out = sym_sum(out1,0);
    out=1/(lim1*lim2)*(1/(2))*out;
else
    % obtain a resored image (N1 by N2) from symmetrically extended image
    % (2*N1 by N2)
    out = sym_sum(out2,1);
    out=1/(lim1*lim2)*(1/(2))*out;
end
%
%Devide the restored image by the total number of translates to 
% normalize it
%out=1/(lim1*lim2)*(1/(2))*out;
toc;

%
% Copyright (c) 2010. Wang-Q Lim
%  

%
% Part of ShearLab Version:100
% Created Tuesday May 01, 2010
% This is Copyrighted Material
% For Copying permissions see COPYRIGHT.m
