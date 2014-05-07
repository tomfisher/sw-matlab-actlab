function y = my_downsample(x,N,p)
%MY_DOWNSAMPLE Downsample input signal.
%   MY_DOWNSAMPLE(X,N) downsamples input signal X by keeping every
%   N-th sample starting with the first. If X is a matrix, the
%   downsampling is done along the columns of X.
% 
%   DOWNSAMPLE(X,N,PHASE) specifies an optional sample offset.
%   PHASE must be an integer in the range [0, N-1].
% 
%   Take care in case X has more than 2 dimensions.
% 
%   Use this function instead of downsample in case you do not have the
%   signal processing toolbox installed.
%
%   See also DOWNSAMPLE, UPSAMPLE, MY_UPSAMPLE, UPFIRDN, INTERP, DECIMATE,
%   RESAMPLE.

%   georg:::csn:::umit, summer 2005

if nargin < 3
    p = 0; 
elseif p > N-1
    error('Offset must be from 0 to N-1.')
end

y = x( 1+p : N : size(x,1) , : ) ;
