function Features = fb_findforsources(FeatureString, Source)
% function Features = fb_findforsources(FeatureString, Source)
%
% Find Features from FeatureString given a Source (first token)
% 
% Copyright 2006-2008 Oliver Amft

Features = {};

for f = 1:length(FeatureString)
    tokens = fb_getelements(FeatureString{f});

    if ~isempty(strmatch(tokens{1}, Source))
        Features = {Features{:} FeatureString{f}};
    end;
end;

if isempty(Features) Features = []; end;