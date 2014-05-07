function newmetric = prmetrics_elementsum(metric)
% function newmetric = prmetrics_elementsum(metric)
%
% Sum columns in a PR performance metric struct
% 
% See also: prmetrics_sumsum, prmetrics_add
% 
% Copyright 2006 Oliver Amft

for idx = 1:length(metric)
    newmetric(idx).relevant = sum(metric(idx).relevant);
    newmetric(idx).retrieved = sum(metric(idx).retrieved);
    newmetric(idx).recognised = sum(metric(idx).recognised);
    newmetric(idx).misses = metric(idx).misses;
    newmetric(idx).hits = metric(idx).hits;
end;

newmetric = prmetrics_update(newmetric);