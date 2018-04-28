% Contents
%
% m files in codes folder
%
%%%%%%%%%%%%%%%%%%%% Forward Shearlet Transform %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1. sampled_DST : (Extended) Discrete Shearlet Transform.
%
% 2. half_sampled_DST1 : (Extended) Discrete Shearlet Transform 
%    associated with only one type of shear matrix [1 1; 0 1] (or [1 0; 1 1]).                      
%
%    Note) sampled_DST = half_sampled_DST1 associated with [1 1; 0 1]
%       + half_sampled_DST1 associated with [1 0; 1 1]
%
% 3. obtain_shear_coeff : obtain shearlet coefficients associated with 
%    specified scaling level j and shear parameter k. 
%
%%%%%%%%%%%%%%%%%%%% Inverse Shearlet Transform %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 4. half_adj_sampled_DST1 : Inverse (Extended) Discrete Shearlet Transform 
%    associated with only one type of shear matrix [1 1; 0 1] (or [1 0; 1 1]).  
%    (inverse of half_sampled_DST1)
%
%
% Forward transform :
%    [dd1 dd2] = sampled_DST(img,qmf1,qmf2,scale,ndir);
%    % img : Input image, 
%    % qmf1, qmf2 : wavelet filter coeff. (see sampled_DST.m for more detalis.)
%    % scale : scaling parameters. (see sampled_DST.m for more details.)
%    % ndir : positive integer determining the number of directions. (see sampled_DST.m for more details.) 
%    % dd1 : shearlet coeff for horizontal cone consisting of 2^(ndir+1)+1 directional components
%    % dd2 : shearlet coeff for vertical cone consisting of 2^(ndir+1)+1 directional components
%    % total number of directions (directional components) is 2^(ndir+2)+2 which is a 
%    % redundancy factor of this transform.
%
% Backward transform :
%   x1 = half_adj_sampled_DST1(dd1,qmf1,qmf2,scale,ndir,0);
%   % reconstruction for horizontal cone.
%   x2 = half_adj_sampled_DST1(dd2,qmf1,qmf2,scale,ndir,1);
%   % reconstruction for vertical cone.
%   rec_img = 1/(2^(ndir+2)+2)*(x1+x2)
%   % image reconstruction 
%
%
%%%%%%%%%%%%%%%%%%% Some sub-routines for shearlet transform %%%%%%%%%%%%%% 
%
% 5. wp_aniso_dwt : Anisotropic Discrete Wavelet Transform.
%
% 6. adj_wp_aniso_dwt : Inverse Anisotropic Discrete Wavelet Transform.
%
% 7. dshear & ddshear : dsicrete shear transform
%                       (NOTE : ddshear : shear transform with essentially no aliasing )  
%
% 8. rec_wp_decomp1 : Reconstruction from Wavelet Packet Decomposition.
%
% 9. wp_decomp1 : Wavelet Packet Decomposition.
%
% 10. resample1 : resampling according to sampling matrix [1 k; 0 1].
%
%%%%%%%%%%%%%%%%%%%%%%%%%% Image Approximations %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 11. Hop1 : Sheared Anisotropic Wavelet Transform with thresholding.
%
% 12. Gop1 : Inverse Sheared Anisotropic Wavelet Transform.
%
% 13. MP_DST : Image Approximation using Matching Pursuit with shearlets.
% 
% 14. recon_MP_DST : Image Approximation using Matching Pursuit with shearlets 
% ( reconstruct an image from shearlet coefficients in MP iterations )
%
% 15. search_match3 : find a directional component with the largest norm
%     among all directional components consisiting in shearlet
%     coefficients.
%
% 16. select_coeff : collect n most significant coefficients from 
%     2d input array. 
%
% 17. test_dst : perform (extended) discrete shearlet transform with only 
%     two directions (vertical and horizontal) and then reconstruct image
%     using only n most significant coefficients.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Image Denosing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 18. HT_DST : image denoising by shearlet thresholding estimator.
%
% 19. sym_ext : symmetric extension of input image.
%
% 20. sym_sum : obtain original image from symmetrically extended image.
% 
% 21. thresh_fct : thresholding estimator - hard, soft,...etc.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Wavelet Transform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 22. wave_comp : image approximation using wavelets.
%
% Some routines from WaveLab850 wavelet toolbox (http://www-stat.stanford.edu/~wavelab/)
%
% 22. DWT_PO : 1D Forward Wavelet Transform. 
%
% 23. IDWT_PO : 1D Inverse Wavelet Transform. 

%
%  Copyright (c) 2010. Wang-Q Lim, University of Osnabrueck
%
%  Part of ShearLab Version 1.0
%  Built Sun, 07/04/2010
%  This is Copyrighted Material
%  For Copying permissions see COPYRIGHT.m
     