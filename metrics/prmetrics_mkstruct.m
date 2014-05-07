function metrics = prmetrics_mkstruct(relevant, retrieved, recognised, misses, hits)
% function metrics = prmetrics_mkstruct(relevant, retrieved, recognised, misses, hits)
%
% Build a PR performance metric struct.
% 
% See the following paper for a description of the sets (parameters) used:
%   Junker, H.; Amft, O. et al., Pattern Recognition, 2008, 41, 2010-2024 
% 
% Mandatory parameters:
%   relevant - sections corresponding to ground truth
%   retrieved - sections returned by the algorithm
%   recognised - sections that were correctly returned by the algorithm (subset of retrieved sections) 
% 
% Optional parameters (for statisitcs only):
%   misses - sections missed (id numbers of each sections)
%   hits - sections recognised (id numbers of each sections)
% 
% See also: prmetrics_update.m

% Copyright 2005-2007 Oliver Amft

if (exist('misses','var')~=1), misses = []; end;
if (exist('hits','var')~=1), hits = []; end;

metrics.relevant = relevant;
metrics.retrieved = retrieved;
metrics.recognised = recognised;
metrics.misses = misses;
metrics.hits = hits;

metrics = prmetrics_update(metrics);
