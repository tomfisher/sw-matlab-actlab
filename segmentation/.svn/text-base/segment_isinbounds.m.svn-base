function yes = segment_isinbounds(seglist, points)
% function yes = segment_isinbounds(seglist, points)
%
% Determine whether point is between segment bounds
% 
% probably was: segment_isoverlap.m 
% 
% See also: isbetween, segment_findoverlap
% 
% Copyright 2008 Oliver Amft

yes = false(size(seglist,1), length(points));
for c = 1:length(points)
	yes(:,c) = (points(c) >= seglist(:,1)) & (points(c) <= seglist(:,2));
end;
