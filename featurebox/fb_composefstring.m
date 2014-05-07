function featurestring = fb_composefstring(FeatureTokens)
% function tokens = fb_getelements(Feature, element)
% 
% Combine feature string (one feature) from individual elemens. Elements will be separated by
% '_' and returned in a cell array.
% 
% See also: fb_getelements
% 
% Copyright 2009 Oliver Amft

if ~iscell(FeatureTokens), error('Parameter FeatureTokens shall be a cell array.'); end;

featurestring = cell2str(FeatureTokens, '_');