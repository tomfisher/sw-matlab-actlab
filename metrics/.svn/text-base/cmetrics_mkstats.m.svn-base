function stats = cmetrics_mkstats(cmetrics)
% function stats = cmetrics_mkstats(cmetrics)
%
% Build statistics struct from confusion matrix.
%
% See also:
%   cmetrics_mkmatrixfromcell, cmetrics_mkmatrixfromseg, cmetrics_mkmatrix
%
% Copyright 2006 Oliver Amft

stats.classes = size(cmetrics,1);
stats.confusion = cmetrics;

stats.cases = sum(sum(cmetrics));
stats.good = sum(diag(cmetrics));
stats.falses = stats.cases - stats.good;
stats.accuracy = stats.good / stats.cases;

stats.retrieved = row(sum(cmetrics,1));
stats.relevant = row(sum(cmetrics,2));
stats.recognised = row(diag(cmetrics));

% only applicable for two-class problem
stats.p = stats.relevant;
stats.tp = stats.recognised;
stats.n = repmat(sum(stats.relevant),1,stats.classes) - stats.relevant;
stats.tn = repmat(sum(stats.recognised),1,stats.classes) - stats.recognised;
% stats.tn = (repmat(sum(stats.recognised),1,stats.classes) - stats.recognised) ...
% 	+ (repmat(sum(diag(fliplr(cmetrics))),1,stats.classes) - row(diag(fliplr(cmetrics))));

% not supported, needed for compatibility with prmetrics_* functions
stats.misses = [];
stats.hits = [];


% from prmetrics_mkstruct():
stats.deletions = stats.relevant - stats.recognised;
stats.insertions = stats.retrieved - stats.recognised;

wstate = warning;  warning('off', 'MATLAB:divideByZero');

stats.recall = stats.recognised ./ (stats.recognised + stats.deletions);
stats.precision = stats.recognised ./ (stats.recognised + stats.insertions);
stats.f = (2 * stats.precision .* stats.recall) ./ (stats.precision + stats.recall);

% class-relative accuracy (aka coverage)
stats.classacc = stats.recognised ./ stats.relevant;

% normalised accuracy
%stats.normacc = 0.5* (stats.tp./stats.p + stats.tn./stats.n);  % for two classes: 0.5* (tp/p + tn/n)
stats.normacc = mean(stats.classacc);


% odds ratio (http://de.wikipedia.org/wiki/Odds_Ratio)
% or = (tp * fp) / (tn * fn);

% Yules Q association metric (http://de.wikipedia.org/wiki/Odds_Ratio)
% Q = (OR − 1) / (OR + 1)

% geometric average
% geometric mean (g-mean) (Kubat et al., 1998)
% F-Measure (Lewis and Gale, 1994)
% Generalized Correlation (GC) (Baldi et al., 2000)
warning(wstate);