function Data = crnt_maketimestamp(Data, varargin)
% function Data = crnt_maketimestamp(Data, varargin)
% 
% Convert 2 column timestamps of CRNT to one column. 
% Time stamp format: sec*1e6+usec
% 
% See also:  crnt_timemerge
% 
% Copyright 2008-2012 Oliver Amft

[RelativeTime, ErrorOnNoData, verbose] = process_options(varargin, 'RelativeTime', true, 'ErrorOnNoData', true, 'verbose', 0);

if isempty(Data) && ErrorOnNoData==false, return; end;

Data(:,1) = Data(:,1) .* 1e6 + Data(:,2);  
Data(:,2) = [];

if Data(:,1) ~= sort(Data(:,1), 'ascend')
    fprintf('\n%s: WARNING: Data source %u has unsorted timestamps.', mfilename, sys);
    return;
end;

% make timestamp relative
if RelativeTime, Data(:,1) = Data(:,1) - Data(1,1); end;