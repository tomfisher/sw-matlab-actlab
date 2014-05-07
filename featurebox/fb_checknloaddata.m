function [DataStruct RelRange] = fb_checknloaddata(DataStruct, Range)
% function [DataStruct RelRange] = fb_checknloaddata(DataStruct, Range)
% 
% Check/load data if Range is not available yet (DynamicLoad mode)
%
% RelRange:     relative ragnges, based on the data slice in DataStruct
% 
% Example:
%       Range = [500 1000];  DataStruct.Range = [500 1000];
%       => RelRange = [1 501];

RelRange = [];

if (size(Range,2)<2)
    error('\n%s: Range must be one segment of the format [beg end].', mfilename);
    return;
end;
Range = Range(:,1:2); % remove any additional stuff

% check, return when data available
if (~isempty(segment_findincluded(DataStruct.Range, Range))) 
    RelRange = Range - DataStruct.Range(1)+1;
    
    % need to correct [1 inf] requests
    if (RelRange(2) >= inf) RelRange(2) = fb_getdatasize(DataStruct); end;
    return; 
end;



% need to load the section
% simple, just load, no caching, no incremental loading

sysname = DataStruct.Name;

% load data
if (length(DataStruct.Partlist)>1) error('Not implemented.'); end;

DataStruct.Data = repos_prepdata(DataStruct.Repository, DataStruct.Partlist, sysname, ...
    'SampleRate', DataStruct.SampleRate, 'Range', Range, 'verbose', 1);

% OAM REVISIT: What if out of range?

% correct Range if [x inf] was supplied, i.e. data until end was loaded
if (Range(2) == inf) Range(2) = fb_getdatasize(DataStruct); end;

DataStruct.Range = Range;

% adapt Range to available data, return relative size
RelRange = Range - DataStruct.Range(1)+1;
