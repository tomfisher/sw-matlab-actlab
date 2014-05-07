function newlist = segment_shiftlist(oldlist, offset)
% newlist = segment_shiftlist(oldlist, offset)
%
% Move segment list (columns 1,2) by offset, leave the rest of the
% columns intact. Offset can be a single value or a vector of equal
% length as oldlist.
% 
% Copyright 2007 Oliver Amft

newlist = [];

if isempty(oldlist), return; end;
if size(offset,2)<2, offset = repmat(offset, size(oldlist,1), 2); end;
if size(offset,1)~=size(oldlist,1), offset = repmat(offset(1,:), size(oldlist,1), 1); end;

if size(oldlist,2)>2
	newlist = [ oldlist(:, 1:2) + offset   oldlist(:, 3:end) ];
else
	newlist = oldlist(:, 1:2) + offset;
end;
