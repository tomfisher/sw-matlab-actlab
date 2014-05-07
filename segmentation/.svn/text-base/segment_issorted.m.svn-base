function issorted = segment_issorted(listin, column)
% function issorted = segment_issorted(listin, column)
%
% Determine if list is sorted.
% Default: Sort accending along 1st column
% 
% See also: segment_sort

% Copyright 2008 Oliver Amft, ETH Zurich

if isempty(listin), issorted = true; return; end;
if ~exist('column','var'), column = 1; end;

[dummy idx] = segment_sort(listin, column);

issorted = all(row(idx) == 1:size(listin,1));
