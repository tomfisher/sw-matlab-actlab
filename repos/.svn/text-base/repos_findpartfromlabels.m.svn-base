function partnumber = repos_findpartfromlabels(seglist, partoffsets)
% function partnumber = repos_findpartfromlabels(seglist, partoffsets)
%
% guess part number from seglist and list of partoffsets
% partoffsets(1) = 0!
% 
% WARNING: This function uses methods from the segmentation toolbox!
% 
% See also: repos_findpartfromclass
% 
% Copyright 2007 Oliver Amft

if partoffsets(1)~=0
    warning('repos:partoffset', 'partoffsets(1) not zero!');
end;

partindices = false(1, length(partoffsets)-1);
for part = 1:length(partoffsets)-1
	% convert partsize to a segment
	partsegment = [ partoffsets(part)+1 partoffsets(part+1) ];
	% find seglist entries included by part
	ovsegs = segment_findincluded(partsegment, seglist);
	if ~isempty(ovsegs), partindices(part) = true; end;
end;

partnumber = find(partindices);

% largerseg = find(partoffsets < max(seglist(:,2)));
% smallerseg = find(partoffsets < min(seglist(:,1)));
% partnumber = smallerseg(end)+1:largerseg(end);
