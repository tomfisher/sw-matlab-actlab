function newscmetric = scmetrics_update(oldscmetric)
% function newscmetric = scmetrics_update(oldscmetric)
%
% Update automatic fields in an scmetrics struct (for a scoring classifier)
% 
% Copyright 2006 Oliver Amft

newscmetric = oldscmetric;

[newscmetric.fpr, newscmetric.tpr, newscmetric.auc] = generateROC(oldscmetric.scores, oldscmetric.labels-1);
