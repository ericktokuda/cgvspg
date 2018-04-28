function [C P] = separate(img,level2,itermax,stop,gamma,coeff,display,shear)

% This routine performs image separation to separate two geometrically 
% different objects (points + curves).
% This routine builds up on MCA2_Bcr.m (in MCALab110 ) written by J. M. Fadili. 
%
%Output : P : separated image which mainly contains points.
%         C : separated image which mainly contains curves. 
%
%Input : 
%
%img : input image
%level2 : The number of levels for wavelet transform
%
%stop : stopping criterion ( eg. stop = 3 or 4)
%;
%itermax : the number of iterations of modified relaxation method.
%
%gamma: paramater for TV (soft-threshold) (e.g gamma = 3 or 4).
%
%coeff : coeff = [coeff(1)...coeff(L)] where 
%        L : the number of frequency bands.
%        coeff(j) : weight coefficient for each frequency band.
%        coeff(1) : weight for low frequecny 
%        ...
%        coeff(L) : weight for high frequency
%        ( see 're_weight_band.m'. )     
%
%display : display = 1 ---> display output of each iteration
%          
%shear : cell array of shearlet filters computed from shearing_filters_Myer.m
%      (see shearing_filters_Myer.m)

% Written by Wang-Q Lim on May 5, 2010. 
% Copyright 2010 by Wang-Q Lim. All Right Reserved.




n = length(img);

%obtain wavelet filter
%qmf = MakeONFilter('Symmlet',4);
%qmf = wfilters('sym2');

pfilt = 'maxflat';
tic;
opt = [2 1];
E = com_norm(pfilt,size(img),shear);
% compute the L^2 norm of shearlets

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

orig = img;
img = re_weight_band(img,coeff); 
%reconstruction with diffrent weight for each frequency band. 
%for example, coeff = [1 4 4 8 8] : weights ---> 1: low frequency... 8: high frequency. 


%estimate a starting thresholding parameter at each scale j.
N = length(img);
h1=MakeONFilter('Daubechies',4);
wc = FWT2_PO(img,log2(N)-1,h1);
hh = wc(N/2+1:N/2+floor(N/2),N/2+1:N/2+floor(N/2));hh = hh(:);
sigma = MAD(hh);
stop = stop*sigma;

Ct = shear_trans(img,pfilt,shear);
[coeff buff(1)] = thresh(Ct,0,2,E,ones(1,length(shear)+1),1);
ylh = swt2(img,level2,'sym4');
[coeff buff(2)] = thresh1(ylh,0,1,E,ones(1,length(shear)+1),1);
%[yl,yh] = mrdwt(img,qmf,level2);
%buff(2) = max(abs(yh(:)));
deltamax = min(buff);
    
lambda=(deltamax/stop)^(1/(1-itermax)); % Exponential decrease.
delta = deltamax;
part = zeros(n,n,2);
if display
    %aviobj = avifile('neuron256.avi','compression','None','fps',2);
screen_size=get(0,'screensize');
            f1 = figure(1);
            set(f1,'position',[0 0 screen_size(3),screen_size(4)]);
end
%Approximately solve l0 minimization at each scale j.

for iter = 1:itermax
    residual = img - (part(:,:,1)+part(:,:,2));
    for k = 1:2
        Ra = part(:,:,k)+residual;
        if k == 1
             %estimate curve part at jth level
             Ct = shear_trans(Ra,pfilt,shear);
             %apply the forward shearlet transform
             Ct = thresh(Ct,(1.4)*delta,opt(1),E,ones(1,length(shear)+1),0);
             part(:,:,k) = inverse_shear(Ct,pfilt,shear);
             %apply the inverse shearlet transform with thresholded coeff. 
             part(:,:,k) = TVCorrection(part(:,:,k),gamma);
             %apply soft-thresholding with the (undecimated) Haar wavelet transform 
        else
             %estimate point part at jth level
             %[yl,yh] = mrdwt(Ra,qmf,level2);
             Ct = swt2(Ra,level2,'sym4');
             Ct = thresh1(Ct,1.4*delta,opt(2),E,0,0);
             part(:,:,k) = iswt2(Ct,'sym4');
             % apply the undecimated wavelet transform
             %Ct{1} = yl; Ct{2} = yh;
             %Ct = thresh(Ct,1.4*delta,opt(2),E,0,0);
             %part(:,:,k) = mirdwt(Ct{1},Ct{2},qmf,level2);
             % apply the inverse undecimated wavelet transform with
             % thresholded coeff.
             % apply soft-thrsholding with the (undecimated) Haar wavelet transform 
        end
        
        %%%%%%%%%%%%%%%%%%%%%%% display output %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if display,
           
            
            subplot(2,2,1);imagesc(orig);axis image; rmaxis;drawnow;
            colormap 'jet';
            c1 = max([max(max(sum(part,3))) 10]);
            subplot(2,2,2);imagesc(sum(part,3),[0 c1]);axis image;rmaxis;title('\Sigma_i Part_i');drawnow;
            colormap 'jet';
            for np=1:2
                c = max([max(max(part(:,:,np))) 10]);
                subplot(2,2,np+2);imagesc(part(:,:,np),[0 c]);axis image;rmaxis;title(sprintf('Part_%d',np));drawnow;
                colormap 'jet';
            end
            % Save in an AVI movie file.
	        %frame = getframe(f1);
            %aviobj = addframe(aviobj,frame);
	        %clear frame
        end
    end
    delta=delta*lambda; % Updating thresholding parameter (Exponential decrease).
end
C = part(:,:,1); P = part(:,:,2);
%aviobj = close(aviobj);
%close(f1);    
toc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = TVCorrection(x,gamma)
% Total variation implemented using the approximate (exact in 1D) equivalence between the TV norm and the l_1 norm of the Haar (heaviside) coefficients.

%qmf = MakeONFilter('Haar');
%[ll,wc] = mrdwt(x,qmf,1);
wc = swt2(x,1,'haar');
wc = SoftThresh(wc,gamma);
y = iswt2(wc,'haar');
%y = mirdwt(ll,wc,qmf,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%