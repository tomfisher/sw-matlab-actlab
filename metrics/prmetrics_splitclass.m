function NMetrics = prmetrics_splitclass(OMetrics, varargin)
% function NMetrics = prmetrics_splitclass(OMetrics, varargin)
%
% Split classes in a PR performance metric struct
% 
% See also: prmetrics_mergeclass, prmetrics_add, prmetrics_sum
% 
% Copyright 2006 Oliver Amft

config_DummyClass = process_options(varargin, ...
    'DummyClass', false);

for idx = 1:length(OMetrics.relevant)
    NMetrics(idx).relevant = OMetrics.relevant(idx);
    NMetrics(idx).retrieved = OMetrics.retrieved(idx);
    NMetrics(idx).recognised = OMetrics.recognised(idx);
    NMetrics(idx).misses = [];
    NMetrics(idx).hits = [];
end;

if config_DummyClass
    NMetrics(idx+1).relevant = OMetrics.relevant(1);
    NMetrics(idx+1).retrieved = OMetrics.retrieved(1);
    NMetrics(idx+1).recognised = OMetrics.recognised(1);
    NMetrics(idx+1).misses = [];
    NMetrics(idx+1).hits = [];
end;

NMetrics = prmetrics_update(NMetrics);
