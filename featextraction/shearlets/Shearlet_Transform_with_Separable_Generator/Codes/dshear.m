function out = dshear(in,k,axis,res,sgn)

% Discrete shear transfrom on discrete domain :
% this routine performs resampling according to shear matrix [1 floor(k/2^(res)); 0 1]
% or [1 0; floor(k/2^(res)) 1] and it is based on resamc.c from Contourlet
% toolbox. 

if sgn == 1 && k>0
    type = 1;
elseif sgn == 0 && k<0
    type = 1;
elseif sgn == 1 && k<0
    type = 2;
else
    type = 2;
end

if axis == 0 
    in = in';
end

out = resample1(in,type,abs(k)/2^(res),'per');

if axis == 0 
    out = out';
end


%  Copyright (c) 2010. Wang-Q Lim, University of Osnabrueck
%
%  Part of ShearLab Version 1.0
%  Built Sun, 07/04/2010
%  This is Copyrighted Material
%  For Copying permissions see COPYRIGHT.m

