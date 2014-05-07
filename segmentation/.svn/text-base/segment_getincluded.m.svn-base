function oseglist = segment_getincluded(interval, iseglist, varargin)
% function oseglist = segment_getincluded(interval, iseglist, varargin)
% 
% Extract included segments from an interval. Optionally remove interval base.
% 
% See also: segment_findincluded, segment_findoverlap
% 
% Copyright 2008 Oliver Amft

[RemoveBase] = process_options(varargin, ...
    'RemoveBase', true);

oseglist = iseglist(segment_findincluded(interval, iseglist),:);

if RemoveBase
    oseglist = [ oseglist(:,1:2)-interval(1)+1, oseglist(:,3:end) ];
end;