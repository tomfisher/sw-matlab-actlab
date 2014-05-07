function metrics = prmetrics_add(metric1, metric2)
% function metrics = prmetrics_add(metric1, metric2)
%
% Add two PR performance metric structs
% 
% WARNING: This does not create a mean result.
% 
% See also: prmetrics_elementsum, prmetrics_sumsum
% 
% Copyright 2006 Oliver Amft

% if metric1 is not there create, in size of metric2
if isempty(metric1) 
    for idx = 1:length(metric2)
        % strange behaviour here when metric1(idx) is used and the function
        % is called with metric1 = [] in a variable, oam
        metric1 = [metric1 prmetrics_mkstruct(0,0,0)]; 
    end;
end;

for idx = 1:length(metric1)
    metrics(idx).relevant = metric1(idx).relevant + metric2(idx).relevant;
    metrics(idx).retrieved = metric1(idx).retrieved + metric2(idx).retrieved;
    metrics(idx).recognised = metric1(idx).recognised + metric2(idx).recognised;
    metrics(idx).misses = [metric1(idx).misses metric2(idx).misses];
    metrics(idx).hits = [metric1(idx).hits metric2(idx).hits];
end;

metrics = prmetrics_update(metrics);
