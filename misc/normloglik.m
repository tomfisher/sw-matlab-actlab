function conf = normloglik(logliks)
% function conf = normloglik(logliks)
%
% Normalise log liklihoods in 0,1 interval for each row (observation)

[nobs nclass] = size(logliks);

rowmin = min(logliks,[],2);
rowmax = max(logliks,[],2);
rownorm = rowmax - rowmin;

% OAM REVISIT: shift logliks towards zero? => changes prob result!

% from Oliver2004-J_CVIU:
% normL = ( L - min(L) )  /  ( max(L) - min(L) )
conf = (logliks - repmat(rowmin, 1,nclass)) ./ (repmat(rownorm, 1, nclass));
