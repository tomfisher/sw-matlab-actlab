function [usedfeatures FeatureString_used] = fb_findusedfeatures(FeatureString_available, FeatureString_select, varargin)
% function [usedfeatures FeatureString_used] = fb_findusedfeatures(FeatureString_available, FeatureString_select, FMatchStyle)
% 
% Determine FeatureString_select in FeatureString_available. Returns logic vector encoded position of activated 
% features (usedfeatures) and matched strings (FeatureString_used). The latter is intersting for MatchStyle=lazy
% only. This routine can be used to determine feature activations in larger feature sets.
% 
% Parameters:
%   FeatureString_available - base string of available feature (cell list)
%   FeatureString_select - features to select (cell list)
% 
% Parameters (optional)
%   MatchStyle - Method to find features, states: 
%     lazy: find strings that match begin of string
%     exact: find exact matches only
%   ErrorIfNone - create an error if no match was found
% 
% Copyright 2008 Oliver Amft

usedfeatures = false(1, length(FeatureString_available));

[FMatchStyle ErrorIfNone verbose] = process_options(varargin, 'MatchStyle', 'lazy', 'ErrorIfNone', true, 'verbose', 1);

if ~iscell(FeatureString_select), FeatureString_select = {FeatureString_select}; end;

if (verbose), fprintf('\n%s:   Features available: %u ', mfilename, length(FeatureString_available)); end;

for f = 1:length(FeatureString_select)
	if strcmpi(FMatchStyle, 'lazy')  % hack for matlab strmatch
		% lazy match
		selfeatures = strmatch(FeatureString_select{f}, FeatureString_available);
	else
		% exact match
		selfeatures = strmatch(FeatureString_select{f}, FeatureString_available, FMatchStyle);
		if length(selfeatures)>1, error('Found more than one match for feature %s', FeatureString_select{f}); end;
	end;

	usedfeatures(selfeatures) = true;
	if ErrorIfNone && isempty(selfeatures), error('Could not find feature: %s, stop.', FeatureString_select{f}); end;
end;

if nargout>1, FeatureString_used = FeatureString_available(usedfeatures); end;