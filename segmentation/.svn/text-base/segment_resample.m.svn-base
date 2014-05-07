function newlist = segment_resample(oldlist, oldsps, newsps, varargin)
% function newlist = segment_resample(oldlist, oldsps, newsps, varargin)
%
% Adapt sampling rate of oldlist
% 
% Copyright 2007 Oliver Amft

newlist = [];
config_segmentmode = process_options(varargin,  'segmentmode', true);

if isempty(oldlist), return; end;

fresample = newsps / oldsps;

if (size(oldlist,2) > 2)
    newlist = [ceil(oldlist(:,1:2) .* fresample)  oldlist(:,3:end)];
    newlist(:,3) = segment_size(newlist);
else
    newlist = ceil(oldlist(:,1:2) .* fresample);
end;

% move begin of segment to 1st sample of section
if config_segmentmode
    shift = ceil(fresample)-1;
    newlist(:,1) = newlist(:,1)-repmat(shift, size(newlist,1), 1);
    if (size(newlist,2) > 2), newlist(:,3) = segment_size(newlist); end;
end;