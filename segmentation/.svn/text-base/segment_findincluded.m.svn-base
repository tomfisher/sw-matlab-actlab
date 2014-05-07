function ovsegs = segment_findincluded(interval, seglist, sizeratio)
% function ovsegs = segment_findincluded(interval, seglist, sizeratio)
%
% Find segments from seglist that are included by interval
% return indices of these segments
%
% WARNING: Overlapping segments are not reported, just INCLUDED ones!
% 
% See also: segment_markincluded, segment_getincluded, segment_findoverlap
% 
% Copyright 2005, 2006 Oliver Amft

ovsegs = [];

if ~exist('sizeratio','var'), sizeratio = inf; end;
if isempty(seglist), return; end;

% There are applications which provide unsorted seglist.
cand = find(seglist(:,1) >= interval(1));
ovsegs = cand(seglist(cand,2) <= interval(2));

% finish if no ratio analysis requested
if (sizeratio == inf), return; end;

ovratio = segment_size(seglist(ovsegs,:)) ./ segment_size(interval);
ovsegs = ovsegs(ovratio >= sizeratio);


% ovsegs = [];
% for seg = 1:size(seglist,1)
%     if (interval(1) <= seglist(seg,1)) & (interval(2) >= seglist(seg,2))
%         ovsegs = [ovsegs seg];
%     end;
% end;
