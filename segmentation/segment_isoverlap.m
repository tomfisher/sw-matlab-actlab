function yes = segment_isoverlap(interval, seglist)
% function yes = segment_isoverlap(interval, seglist)
% 
% Return map of segments that intersect with interval
% 
% OAM REVISIT: This code was lost between Oct 2007 and Dec 2008. Reimplemented, 2008/12/06
% 
% There are six types of segments: 
%       (1) below, (2) intersect w beg, (3) inside interval, (4) intersect w end, (5) above, (6) spanning enitre interval
% 
% Example:
%       segment_isoverlap([10 20], [2 5; 8 12; 11 15; 18 22; 30 35; 8 23])
%       ans =
%           0     1     1     1     0     1
% 
% See also: segment_findoverlap, segment_isinbounds
% 
% Copyright 2008 Oliver Amft

yes = false(size(seglist,1) ,1);
if isempty(seglist), return; end;
if isempty(interval), return; end;

% proof by inversion
yes = ~( (interval(1) > seglist(:,2)) | (interval(2) < seglist(:,1)) );