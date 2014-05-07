function ovsegs = segment_markincluded(intervals, seglist)
% function ovsegs = segment_markincluded(intervals, seglist)
%
% Mark segments from seglist that are included by interval
% return one-hot encoded indices of these segments
%
% WARNING: Overlapping segments are not reported, just INCLUDED ones!
% 
% See also: segment_findincluded, segment_getincluded, segment_findoverlap
% 
% Copyright 2008-2009 Oliver Amft

ovsegs = false(size(seglist,1),1);
if isempty(seglist), return; end;

for i = 1:size(intervals,1)
    inc1 = seglist(:,1) >= intervals(i, 1);
    inc2 = seglist(:,2) <= intervals(i, 2);
    ovsegs = ovsegs | (inc1 & inc2);
end;