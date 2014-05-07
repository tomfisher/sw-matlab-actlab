function NewFeatureString = fb_expandfeaturestring(OldFeatureString, FeatureCounts)
% function NewFeatureString = fb_expandfeaturestring(OldFeatureString, FeatureCounts)
% 
% Expand feature string OldFeatureString accorind to number of occurances
% provided in FeatureCounts.
% 
% Copyright 2007 Oliver Amft

if length(OldFeatureString) ~= length(FeatureCounts), error('Parameters inconsistent.'); end;
if any(FeatureCounts < 0), error('FeatureCounts below zero.'); end;

NewFeatureString = {};
for feature = 1:length(OldFeatureString)
	if FeatureCounts(feature) > 1
		for i = 1:FeatureCounts(feature)
			NewFeatureString = [NewFeatureString { [OldFeatureString{feature} '_' num2str(i, '%02u')] }];
		end;
        
    elseif FeatureCounts(feature) == 0
        % do nothing - feature was deleted
	
    else
		NewFeatureString = [ NewFeatureString { OldFeatureString{feature} }];
	end;
end;
