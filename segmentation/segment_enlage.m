function seglist = segment_enlage(seglist, Ratio, varargin)
% function seglist = segment_enlage(seglist, Ratio, varargin)
% 
% Grow sections by ratio
% 
% Copyright 2010 Oliver Amft

[DoMerge DoPreventNegSec verbose] = ...
    process_options(varargin, ...
	'domerge', true, 'DoPreventNegSec', true, 'verbose', 1);

for i = 1:size(seglist,1)
    s = segment_size(seglist(i,:));
    seglist(i,1) = seglist(i,1) - round(s*Ratio);  seglist(i,2) = seglist(i,2) + round(s*Ratio);
    if DoPreventNegSec && seglist(i,1) < 0, seglist(i,1) = 0; end;
    
    seglist(i,3) = segment_size(seglist(i,:));
end;

if DoMerge
    seglist = segment_distancejoin(seglist);
end;

