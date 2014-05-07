function [EQData EQTime] = equiresample(MeasuredTimes, OldData, StepSize, varargin)
% function [EQData EQTime] = equiresample(MeasuredTimes, OldData, StepSize, varargin)
%
% Convert a list of measurement time/values to equidistant samples.
% MeasuredTimes should be a monotonly increasing list of timestamps. These will be matched
% to StepSize increments in a new timescale using the algorithm selected via IntPMethod.
% StepSize is the new sample distance.
%
% Superseeds: equidistdata.m
%
% Copyright 2007-2012 Oliver Amft
EQData = []; EQTime = [];
[IntPMethod IfNoSample StartSample, StopSample, GapSkipRatio, EQTime, SamplePrefetch, verbose] = process_options(varargin, ...
    'IntPMethod', 'LastValue', 'IfNoSample', nan, ...
    'StartSample', MeasuredTimes(1), 'StopSample', MeasuredTimes(end), ...
    'GapSkipRatio', 0.01, 'EQTime', [], ...
    'SamplePrefetch', 20, 'verbose', 0);

if isempty(EQTime)
    if length(MeasuredTimes) ~= size(OldData,1), error('Timestamp and data sizes do not match.'); end;
    if any(diff(MeasuredTimes)<0), error('MeasuredTimes not monotonly increasing.'); end;
    
    if (verbose>1), fprintf('\n%s: Permitted sample gaps: %.2fxStepSize (%usa).', mfilename, GapThres/StepSize-1, GapThres); end;
    % if (verbose>1), fprintf('\n%s: Sample start: %u, stop: %u.', mfilename, StartSample, StopSample); end;
    OldSampleDiff = sum(diff(MeasuredTimes))/length(MeasuredTimes);
    if (verbose>1), fprintf('\n%s: Avg. sample diff=%.1fxStepSize (max: %.1f, prefetch: %u).', mfilename, ...
            OldSampleDiff/StepSize, max(diff(MeasuredTimes))/StepSize, SamplePrefetch); end;
    
    % check whether all this is indeed needed, to disable this feature set GapSkipRatio=0
    if all(abs(diff(MeasuredTimes)-StepSize)  <= StepSize*GapSkipRatio)
        EQData = OldData; EQTime = MeasuredTimes;   % return input
        if verbose, fprintf('\n%s: No timeseries adjustment needed, skipping.', mfilename); end;
        return;
    end;
    
    % % check that SamplePrefetch is sufficiently large for searching the next best sample
    % if max(diff(MeasuredTimes)) > SamplePrefetch*StepSize
    %     fprintf('\n%s: SamplePrefetch too low: actual=%usa, needed=%usa.', mfilename, SamplePrefetch*StepSize, max(diff(MeasuredTimes)));
    %     return;
    % end;
    
    % new time axis
    EQTime = StartSample : StepSize : StopSample;
end;

TotalSamples = length(EQTime);
EQData = zeros(TotalSamples, size(OldData,2));  % initialise array for new data

if (verbose>1), fprintf('\n%s: Resampling...', mfilename); end;
prate = 0.1;
MeasuredTimes(end+1:end+SamplePrefetch) = inf;      % append dummy value to save time in the for loop
mpoint = 1; % start at first new sample ;-)
for pos = 1:TotalSamples
    if (verbose>0), prate = print_progress(prate, pos/TotalSamples); end;
    %if (mpoint + SamplePrefetch) > length(MeasuredTimes), SamplePrefetch = length(MeasuredTimes)-mpoint; end;
    
    % find measurement point that is newest
    old_mpoint = mpoint;
    mpoint = find(MeasuredTimes(mpoint:mpoint+SamplePrefetch) <= EQTime(pos), 1, 'last') + mpoint-1;
    
    % there is a chance that we miss, then roll back
    if mpoint == old_mpoint+SamplePrefetch
        mpoint = find(MeasuredTimes(mpoint:end) <= EQTime(pos), 1, 'last') + mpoint-1;
        if (verbose>1), fprintf('o', mfilename); end;
    end;
    
    if isempty(mpoint) || (mpoint == 0) || (MeasuredTimes(mpoint) > EQTime(pos))  % no initial point found
        EQData(pos) = IfNoSample;
        mpoint = 1;
        continue;
    end;
    
    switch(lower(IntPMethod))
        case 'lastvalue'  % use last observed measurement as the EQ value
            EQData(pos,:) = OldData(mpoint,:);
        case 'linear'  % interpolate previous and next measurement
            EQData(pos,:) = interp1(MeasuredTimes(mpoint:mpoint+1), OldData(mpoint:mpoint+1,:), EQTime(pos), 'linear');
        case { 'nn', 'nearestneighbour' } % interpolate previous and next measurement
            EQData(pos,:) = interp1(MeasuredTimes(mpoint:mpoint+1), OldData(mpoint:mpoint+1,:), EQTime(pos), 'nearest');
        case {'mean', 'average'}  % use average between neighbouring points
            EQData(pos,:) = mean(MeasuredTimes(mpoint:mpoint+1,:));
        otherwise
            error('IntPMethod not recognised:%s.', IntPMethod);
    end;
end; % for pos