function MergedData = mergestreams(varargin)
% function MergedData = mergestreams(varargin)
% 
% Merge several datastreams. 
% It is assumed that each stream has an independent sample time vector, of the form: samples x channels
% MergedData contains all resampled datastreams and a new time axis as first column.
% The function considers distances between samples only, thus does not need sample rate (time) information.
% 
% Example:
%       MergedData = mergestreams(InStreams{:}, 'options', 'verbose', 1);
% 
% See also: equiresample
% 
% Copyright 2012 Oliver Amft

MergedData = [];
[InStreams, params] = process_params('options', varargin{:});

[IntPMethod, NewSampleDist SampleTimeCol verbose] = process_options(params, ...
    'IntPMethod', 'LastValue', 'NewSampleDist', nan, 'SampleTimeCol', repmat(1, 1, length(InStreams)), 'verbose', 1);

% find start end end times for all streams
StartSample = zeros(1, length(InStreams)); StopSample = zeros(1, length(InStreams)); StreamCols = zeros(1, length(InStreams));
for s = 1:length(InStreams)
    StartSample(s) = InStreams{s}(1,SampleTimeCol(s));
    StopSample(s) = InStreams{s}(end,SampleTimeCol(s));
    StreamCols(s) = size(InStreams{s},2);
    SampleDist(s) = sum(diff(InStreams{s}(:,SampleTimeCol(s)))) / size(InStreams{s},1);
end;

% frequencies:  1./(SampleDist/1e6)
if isnan(NewSampleDist)
    NewSampleDist = ceil(max(SampleDist));
    if (verbose), fprintf('\n%s: NewSampleDist was not set, assuming: %usa', mfilename, NewSampleDist); end;
end;

EQTime = max(StartSample) : NewSampleDist : min(StopSample);    % new time axis

% now, use the new time axis to resample all streams
MergedData = zeros(length(EQTime), length(sum(StreamCols)));  MergedData(:,1) = EQTime;
sumcols = [0 cumsum(StreamCols-1)]+1;     % every stream 'looses' the time axis, so one less
for s = 1:length(InStreams)
    if (verbose), fprintf('\n%s: Processing stream %u...', mfilename, s); end;
    tmp = equiresample(InStreams{s}(:,1), InStreams{s}(:,2:end), NewSampleDist, 'IntPMethod', IntPMethod, 'EQTime', EQTime, 'GapSkipRatio', 0, 'verbose', verbose);
    if isempty(tmp), error; end;
    MergedData(:, sumcols(s)+1:sumcols(s+1)) = tmp;
end;
