function confmat = distance2confidence(distmat, maxdist)
% function confmat = distance2confidence(distmat, maxdist)
%
% Convert distance to confidence using maxdist:
% 
%              T - d
%      c = ---------       ; T >= d
%                 T
% 
% Reference: Amft and Tröster, Artif Intell Med, 2008, 42, 121-136
% 
% distmat is a vector or matrix of distances in the form [dist1; dist2; ...]
% 
% Copyright 2006 Oliver Amft


[nrows ncols] = size(distmat);

if max(max(distmat)) > maxdist, warning('MATLAB:distance2confidence', 'Detected distances larger than treshold.'); end;
if (length(maxdist) ~= 1) && (length(maxdist) ~= size(distmat,1)), error('Param maxdist is incompatible.'); end;

if length(maxdist) == 1
    confmat = (repmat(maxdist, nrows,ncols) - distmat) ./ maxdist;
else
    confmat = (maxdist(:,ones(1,ncols)) - distmat) ./ maxdist;
end;
