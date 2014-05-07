function metric = prmetrics_update(metric)
% function newmetric = prmetrics_update(metric)
%
% Update fields in a PR performance metric struct
% 
% Copyright 2005 Oliver Amft

for idx = 1:length(metric)
    metric(idx).deletions = metric(idx).relevant - metric(idx).recognised;
    metric(idx).insertions = metric(idx).retrieved - metric(idx).recognised;

    
    wstate = warning;  warning('off', 'MATLAB:divideByZero');

    metric(idx).recall = metric(idx).recognised ./ (metric(idx).recognised + metric(idx).deletions);
    metric(idx).precision = metric(idx).recognised ./ (metric(idx).recognised + metric(idx).insertions);
    metric(idx).accuracy = metric(idx).recognised ./ metric(idx).relevant;
    metric(idx).f = (2 * metric(idx).precision .* metric(idx).recall) ./ (metric(idx).precision + metric(idx).recall);

    warning(wstate);
end;