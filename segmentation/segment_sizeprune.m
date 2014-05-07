function [listout indices] = segment_sizeprune(listin, minsize)
% function [listout indices] = segment_sizeprune(listin, minsize)
%
% Delete segments when their size is below threshold
%
% WARNING: Labeling will be not be checked! Works on ONE class only.
% 
% Copyright 2006 Oliver Amft

listout = [];
if isempty(listin), return; end;
if ~exist('minsize','var'), minsize = 0; end;

if (size(listin,2)>2) && (sum(diff(listin(:,4)))>0)
    warning('matlab:segment_sizeprune', 'Labeling will be not be checked! Works on ONE class only.');
end;

listout = segment_sort(listin);
sizes = segment_size(listout);

indices = find(sizes < minsize);
listout(indices,:) = [];