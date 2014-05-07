function [unsorteduniques ia ib] = unique_nosort(vec)
% function [unsorteduniques ia ib] = unique_nosort(vec)
%
% Find unique elements, keep original sorting
%
% See also: unique
%
% Copyright 2008 Oliver Amft
%
% based on an idea by 'reza j' on MATLAB Central, discussion on unique_no_sort
% http://www.mathworks.com/matlabcentral/fileexchange/15209

% vec = vec(:)';
vec = vec(:);
[v a b] = unique(vec, 'first');
if nargout > 2
    [ia v] = sort(a);
    [v ib] = ismember(b, v);
else
    ia = sort(a);
end
unsorteduniques = vec(ia);