function vec = onesvector(varargin)
% function vec = onesvector(varargin)
% 
% Create a vector of ones at positions indicated by parameters, vector length is
% equal to last parameter.
% 
% Example:
%       onesvector(1,9,10)
% ans =
%      1     0     0     0     0     0     0     0     1     0
% 
% See also:  vec2onehot
% 
% Copyright 2008 Oliver Amft

vlength = max(varargin{end});
vec = false(1, vlength);
vec([varargin{1:end-1}]) = true;
