function [allseglist partoffsets segsps] = cla_getsegmentation(Repository, Partlist, varargin)
% function [allseglist partoffsets segsps] = cla_getsegmentation(Repository, Partlist, varargin)
%
% Load segmentation for a Partlist
% Segmentation is assumed to be computed AFTER alignment!  
% 
% Copyright 2006 Oliver Amft

[SegType SegMode, SampleRate, verbose] = process_options(varargin, ...
    'SegType', 'SWAB', 'SegMode', '', 'SampleRate', 0, 'verbose', 0);


allseglist = [];

%determine segmentation sampling rate
filename = repos_makefilename(Repository, 'indices', Partlist(1), 'prefix', SegType, 'suffix', SegMode, 'subdir', 'SEG');
load(filename, 'segsps'); 

% fetch partsizes
partoffsets = repos_getpartsize(Repository, Partlist, 'SampleRate', segsps, 'OffsetMode', true);

% load the segmentation for each part and concatinate it
for partno = 1:length(Partlist)
    part = Partlist(partno);
    filename = repos_makefilename(Repository, 'indices', part, 'prefix', SegType, 'suffix', SegMode, 'subdir', 'SEG');

    load(filename, 'seglist');
    allseglist = [allseglist; seglist+partoffsets(partno)];
end; % for part

% adapt sampling rate, if required
if (SampleRate > 0)
    allseglist = segment_resample(allseglist, segsps, SampleRate);   % ,  'segmentmode', false
    segsps = SampleRate;
end;

% remove all misc columns
allseglist(:,3:end) = [];

