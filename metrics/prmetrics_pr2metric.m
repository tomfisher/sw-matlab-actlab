function pmetric = prmetrics_pr2metric(precision, recall)
% function pmetric = prmetrics_pr2metric(precision, recall)
%
% Convert a PR list to a prmetric struct
% 
% See also: prmetrics_getfields
% 
% Copyright 2009 Oliver Amft

for i = 1:length(recall)
    pmetric(i).recall = recall(i);
    pmetric(i).precision = precision(i);
end;