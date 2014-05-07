function newscmetric = scmetrics_append(metric1, metric2)
% function newscmetric = scmetrics_append(metric1, metric2)
%
% Append results to an scmetrics struct (for a scoring classifier)

if isempty(metric1)
    newscmetric.scores = col(metric2.scores);
    newscmetric.labels =  col(metric2.labels);
else
    newscmetric.scores =  [metric1.scores; metric2.scores];
    newscmetric.labels =  [metric1.labels; metric2.labels];
end;

newscmetric = scmetrics_update(newscmetric);