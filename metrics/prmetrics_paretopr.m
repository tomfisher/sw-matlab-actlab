function [newprecision newrecall ] = prmetrics_paretopr(metric)
% function [newprecision newrecall] = prmetrics_paretopr(metric)
% 
% Determine pareto front
% 
% See also: prmetrics_prunepr
% 
% Copyright 2009 Oliver Amft

[precision recall] = prmetrics_getpr(metric);
[newrecall idx iidx] = unique(recall); newprecision = precision(idx); uiidx = unique(iidx);
%   [B,I,J] = UNIQUE(...) also returns index vectors I and J such
%   that B = A(I) and A = B(J) (or B = A(I,:) and A = B(J,:)).

for k = 1:length(uiidx)
    eqs = uiidx(k)==iidx;
    if sum(eps) < 2, continue; end;
    [pmax p] = max(precision(eqs));
    tmp = find(eqs);
    
    newprecision(newrecall(tmp(p)) == newrecall) = pmax;
end;
