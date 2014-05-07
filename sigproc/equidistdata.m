function [EQData EQTime] = equidistdata(MeasuredTimes, OldData, StepSize, varargin)
% function [EQData EQTime] = equidistdata(MeasuredTimes, OldData, StepSize, varargin)
%
% Convert a list of measurement time/values to equidistant list.
% MeasuredTimes should be a monotonly increasing list of timestamps. These will be matched
% to StepSize increments (new samples). StepSize is the new sampling rate.
%
% Superseeded by: equiresample.m
% 
% Copyright 2007, 2009, 2010 Oliver Amft

% t = dlmread('/home/oam/ifehome/eth/projects/nutrition/devices/Scales/Messreihe3.csv',';',3,0);
[MaxTime, GapThres, verbose] = process_options(varargin, ...
    'MaxTime', MeasuredTimes(end), 'GapThres', 2*StepSize, 'verbose', 0);

if length(MeasuredTimes) ~= size(OldData,1), error('Timestamp and data sizes do not match.'); end;

% check whether all this is indeed needed
if all(abs(diff(MeasuredTimes)-mean(diff(MeasuredTimes)))<=GapThres), 
    EQData = OldData; EQTime = MeasuredTimes;
    return; 
end;

EQTime = 0:StepSize:MaxTime;
TotalSamples = length(EQTime);
EQData = zeros(TotalSamples, size(OldData,2));

count_losses = 0;  
mpoint_r = 0; prate = 0.1;
for pos = 1:TotalSamples
    if (verbose>1), prate = print_progress(prate, pos/TotalSamples); end;
    
    %mpoints = find(MeasuredTimes == t);
    %mpoints =  findclosestmatches(t, MeasuredTimes, StepSize);
    %mpoints = findnearestval(EQTime(pos), MeasuredTimes, 'UseSides', 'lower');
    % ------------------------------------------------------------------------------------------------------------------
    % Operation principle
    % ------------------------------------------------------------------------------------------------------------------
    % Equidist:      V  V  V  V  V
    % Measured:  .    ...  .. .. .. .  .
    % ------------------------------------------------------------------------------------------------------------------    
    % Org code: compute diffs, determine max from diffs(diffs < 0)
    if 1
        % Timings: 33%  of org code
        diffs = MeasuredTimes(mpoint_r+1:end)-EQTime(pos);
        diffs = diffs(diffs < 0);  % omit instances from list that are in the future        
        %diffs(diffs > 0) = inf;  % Timings: 66% of org code
    else
        % Timings: 50%  of org code
        diffs = MeasuredTimes-EQTime(pos);
        diffs(1:mpoint_r) = [];
        diffs = diffs(diffs < 0);  % omit instances from list that are in the future
    end;
    [dummy mpoint] = max(diffs); % largest neg diff is best sample to use from the past
    if isempty(diffs)
        if (pos>1)
            fprintf('\n%s: NO measurement found for time:%f, using first value: %s. ', mfilename, EQTime(pos), mat2str(OldData(mpoint)));
        end;
        mpoint = 1; 
    end;
    
    if length(mpoint) > 1
        mpoint = mpoint(end);
        fprintf('\n%s: More than one measurement found for time:%f, using values: %s. ', mfilename, EQTime(pos), mat2str(OldData(mpoint)));
        %error('Stop');
    end;
    if ~isempty(diffs) && abs(diffs(mpoint(end)) > GapThres)
        count_losses = count_losses + 1;
        if (verbose>1)
            fprintf('\n%s: NO measurement found for time:%f, using first value: %s. ', mfilename, EQTime(pos), mat2str(OldData(mpoint)));
        end;
    end;

    % copy data
    EQData(pos,:) = OldData(mpoint+mpoint_r,:);
    mpoint_r = mpoint-1+mpoint_r;
end