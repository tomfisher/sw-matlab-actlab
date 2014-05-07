function out = vec2onehot(in, len)
% function out = vec2onehot(in, len)
% 
% Convert integer vector to one-hot encoded vector. Parameter len is optional vector length.
% 
% Example:
%       vec2onehot([1,9,10])
% ans =
%      1     0     0     0     0     0     0     0     1     1
% 
% See also:  onesvector, vec2cells
% 
% Copyright 2008 Oliver Amft

if ~exist('len', 'var') || isempty(len),  len = max(in); end;

out = false(1, len);
out(in) = true;