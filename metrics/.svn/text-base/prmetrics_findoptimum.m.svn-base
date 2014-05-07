function [bestidx bestmetric] = prmetrics_findoptimum(prmetrics, precthres)
% function [bestidx bestmetric] = prmetrics_findoptimum(prmetrics, precthres)
%
% Find 'optimum' decision threshold based on f metric.
% 1. Find max(f) threshold.
% 2. Decrease precision below precthres (ignored if precthres = 1)
%
% precthres         - precision threshold, default: 0.5
%
% prmetrics array must be sorted with accenting recall 
% (descenting precision)
% 
% See also: prmetrics_findoptimum2, prmetrics_findoptimumfromseg
% 
% Copyright 2006 Oliver Amft

[prmetrics sidx] = prmetrics_sort(prmetrics);

if ~exist('precthres','var'), precthres = 1; end;  % will return max F point

metric = prmetrics_getfields(prmetrics, 'f');
% metric = prmetrics_getfields(prmetrics, 'recall');
% prmetrics_plot('view', [], prmetrics);

% initial guess of best point
[dummy, bestidx] = max(metric);

% descent until precision < precthres while keeping recall up
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
