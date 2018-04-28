function [w_s]=shearing_filters_Myer(n1,level)
% This function computes the shearing filters using the Meyer window
% function.
%
% Inputs: n1 - size of shearing matrix desired
%         level - the parameter determining the number of directions
%
% Outputs: w_s where w_s(:,:,k) - n1 by n1 shearing matrix at orientation k
% 
% Written by Glenn R. Easley on Feb 2, 2006. 
% Copyright 2006 by Glenn R. Easley. All Right Reserved.

[x11,y11,x12,y12,F1]=gen_x_y_cordinates(n1);

N=2*n1;
L=floor(N/2^level);
M=2^level;

wf=windowing(ones(N,1),2^level);
w=zeros(N,N/2,2^level);
w_s=zeros(n1,n1,M);

for k=1:M,
    temp=wf(:,k)*ones(N/2,1)';
    w_s(:,:,k)=rec_from_pol(temp,n1,x11,y11,x12,y12,F1);
end


