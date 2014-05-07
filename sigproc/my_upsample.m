function y = my_upsample(x,N,p)
%UPSAMPLE Upsample input signal.
%   UPSAMPLE(X,N) upsamples input signal X by inserting
%   N-1 zeros between input samples.  X may be a vector
%   or a signal matrix (one signal per column).
%
%   UPSAMPLE(X,N,PHASE) specifies an optional sample offset.
%   PHASE must be an integer in the range [0, N-1].
%
%   Use this function instead of downsample in case you do not have the
%   signal processing toolbox installed.
%
%   See also UPSAMPLE, DOWNSAMPLE, MY_DOWNSAMPLE, UPFIRDN, INTERP,
%   DECIMATE, RESAMPLE. 

%   georg:::csn:::umit, summer 2005

if nargin < 3
    p = 0 ;
elseif p > N-1
    error('Offset must be from 0 to N-1.') ;
end

d = size(x) ;
if d(1) > 1
    y = zeros( d(1)*N, d(2) ) ;
    y( 1 : N : d(1)*N , : ) = x ;
else
    y = zeros( d(1), d(2)*N ) ;
    y( : , 1 : N : d(2)*N ) = x ;
end    
