function [bestidx bestmetric] = prmetrics_findoptimum2(prmetrics, varargin)
% function [bestidx bestmetric] = prmetrics_findoptimum2(prmetrics, varargin)
%
% Find 'optimum' decision threshold based on f metric.
%
% See also: prmetrics_findoptimum, prmetrics_findoptimumfromseg
% 
% Copyright 2007 Oliver Amft

error('Work in progress.');

[OptGoals verbose] = process_options(varargin, 'optgoals', { 'f', 'max', 'precision', 0.1 }, 'verbose', 1);

% prmetrics array must be sorted with accenting recall 
% (descenting precision)
[prmetrics sidx] = prmetrics_sort(prmetrics);

% initial guess of best point
[dummy, bestidx] = max(metric);

for og = 1:2:length(OptGoals)
	
goalmetric = prmetrics_getfields(prmetrics, OptGoals{og});
if length(goalmetric) ~= length(prmetrics), error('Goal metric %s not consistent.', OptGoals{og}); end;


% go on until goal is reached
cont = 1;
recalls = prmetrics_getfields(prmetrics, 'recall');
while (bestidx < length(metric)) && (cont)
    cont = 0;
    maxrecall = max(recalls(bestidx+1:length(metric)));
    
    % check if better recall ahead
    if (prmetrics(bestidx).recall <= maxrecall) % && (prmetrics(bestidx).recall<1)
        % check if precision can be lowered
        if prmetrics(bestidx+1).precision >= precthres  % was: >
            
            % ok, advance to next index
            bestidx = bestidx + 1;
            cont = 1;
        end;
    end;
end;

bestmetric = prmetrics(bestidx);
bestidx = sidx(bestidx);



% [dummy, orderidx] = sort(recalls, 'descend');
% for pridx = 1:length(orderidx)
%     bestidx = orderidx(pridx); nextidx = orderidx(pridx+1);
%     if (prmetrics(nextidx).precision < prmetrics(bestidx).precision) | ...
%             ((prmetrics(nextidx).recall < 0.9) & ((prmetrics(nextidx).recall - prmetrics(bestidx).recall) > -0.05))
%         break;
%     end;
% end;
