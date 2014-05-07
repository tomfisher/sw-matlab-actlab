function [avgprec avgrecall] = prmetrics_avgpr(varargin)
% function [avgprec avgrecall] = prmetrics_avgpr(varargin)
%
% Compute an average PR values from individual metrics.
% 
% Copyright 2009 Oliver Amft
% 
% See also: prmetrics_getfields

[metrics options] = process_params([], varargin{:});
[avgrecall RecallDiffThres verbose] = process_options(options, ...
    'avgrecall', 0:0.01:1, 'RecallDiffThres', 0.1, 'verbose', 0);

avgprec = nan(length(avgrecall), length(metrics));
avgrecall  = col(avgrecall);

for i = 1:length(metrics)
    %[precision recall] = prmetrics_getpr(prmetrics_prunepr(prmetrics_sort(metrics{i}), 'Enable', 2));
    [precision recall] = prmetrics_paretopr(metrics{i});
    
    for j = 1:length(avgrecall)
        avgprec(j, i) = interp1(recall, precision, avgrecall(j));
    end;
end;

% avgprec = mean(avgprec, 2);
% avgprec = nanmean(avgprec, 2);
avgprec(isnan(avgprec)) = 0;
avgprec = mean(avgprec, 2);