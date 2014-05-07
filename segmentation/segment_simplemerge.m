function seglabels = segment_simplemerge(varargin)
% function seglabels = segment_simplemerge(varargin)
% 
% Merge segment lists. Sorted segment list is returned.

seglabels = [];
for arg = 1:nargin
    seglabels = [seglabels; varargin{arg}];
end;

seglabels = segment_sort(seglabels);


