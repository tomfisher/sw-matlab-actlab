function out = vec2cells(in)
% function out = vec2cells(in)
% 
% Creates array of cells from input vector
% 
% Example:
%       vec2cells([1:10])
% ans = 
%     [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]
% 
% See also:  vec2cells
% 
% Copyright 2008 Oliver Amft

out = cell(1, length(in));
for i = 1:length(in)
    out{i} = in(i);
end;