function newmetric = prmetrics_flip(metric)
% function newmetric = prmetrics_flip(metric)
%
% reverts the entries in a PR performance metric struct list

for idx = 1:length(metric)
    idxb = length(metric)-idx+1;
    newmetric(idx).relevant = sum(metric(idxb).relevant);
    newmetric(idx).retrieved = sum(metric(idxb).retrieved);
    newmetric(idx).recognised = sum(metric(idxb).recognised);
    newmetric(idx).misses = metric(idxb).misses;
    newmetric(idx).hits = metric(idxb).hits;
end;

newmetric = prmetrics_update(newmetric);