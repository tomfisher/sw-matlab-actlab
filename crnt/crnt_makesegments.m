function segments = crnt_makesegments(timestamps, labels, labelbase)
% function segments = crnt_makesegments(timestamps, labels, labelbase)
% 
% Convert keyboard reader labels to segments labels as used by Marker toolbox
% Parameter timestamps is interpreted without any conversion.
% 
% Copyright 2009 Oliver Amft

if ~exist('labelbase', 'var'), labelbase = 0; end;

% note that offsets2segments reduces the list by the first offset automatically
segments = offsets2segments(timestamps, labels);

rmidx = ( segments(:,4) <= labelbase );
segments = segments(~rmidx,:);