function thisfeature = feature_ENERGY(sdata)
% function thisfeature = feature_ENERGY(sdata)
%
% Signal time-domain energy
% 
% Copyright 2006 Oliver Amft

thisfeature = sum(sdata.^2,1) / length(sdata);
