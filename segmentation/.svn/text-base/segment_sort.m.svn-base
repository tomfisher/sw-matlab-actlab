function [listout idx] = segment_sort(listin, column)
% function [listout idx] = segment_sort(listin, column)
%
% Sort a segment list according to a column
% Default: Sort accending along 1st column
% 
% Copyright 2005 Oliver Amft

if ~exist('column','var'), column = 1; end;

listout = []; idx = [];
if isempty(listin), return; end;

[tmp,idx] = sort(listin(:,column));
if ~isempty(idx)
    listout = listin(idx,:);
end;

if size(listout,2)>=5
    listout(:,5) = 1:size(listout,1);
end;