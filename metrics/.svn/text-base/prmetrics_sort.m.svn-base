function [newmetrics sidx] = prmetrics_sort(oldmetrics, measure, dir)
% function [newmetrics sidx] = prmetrics_sort(oldmetrics, measure, dir)
%
% Sort a PR metric struct list according to measure in order of dir.
% Param measure can be any existing and sortable filed in oldmetrics, dir
% may be 'ascend' or 'descend', default: 'ascend'.
%
% See also: prmetrics_getfields
% 
% Copyright 2006 Oliver Amft 

if ~exist('dir','var'), dir = 'ascend'; end;
if ~exist('measure','var'), measure = 'recall'; end;

metric = prmetrics_getfields(oldmetrics, measure);

% [dummy sidx] = sortm(metric, 'mode', 'hierarchy');
[dummy sidx] = sort(metric, dir);

newmetrics = oldmetrics(sidx);
