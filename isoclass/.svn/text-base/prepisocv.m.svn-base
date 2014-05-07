function [trainIndices, testIndices] = prepisocv(allIndices, CVFolds, varargin)
% function [trainIndices, testIndices] = prepisocv(allIndices, CVFolds, varargin)
% 
% Determine train/test labels for isolated cross-validation
%
% OAM REVISIT: bug: may return some used testlabels => createcv! 
% 
% Copyright 2006 Oliver Amft

[verbose] = process_options(varargin, 'verbose', 1);

trainIndices  = cell(1, CVFolds);
testIndices = cell(1, CVFolds);

% check if there are instances for each class
if (min(cellfun('size',allIndices,1)) == 0)
    fprintf('\n%s: No relevant sections found, allIndices: %s.', mfilename, mat2str(cellfun('size',allIndices,1)));
    return;
end;


% perform splits
RS = [];
for cviters = 1:CVFolds
	if (verbose), fprintf('\n%s: CV iteration: %u of %u', mfilename, cviters, CVFolds); end;
	[trainIndices{cviters}, testIndices{cviters}, RS] = createcv(allIndices, CVFolds, RS);
	trainIndices{cviters} = trainIndices{cviters}';
	testIndices{cviters} = testIndices{cviters}';

	if (verbose)
		fprintf('\n%s: Total: %s,\n  Train: %s,\n  Test: %s', mfilename, ...
			mat2str(cellfun('size', allIndices,1)), ...
			mat2str(cellfun('size', trainIndices{cviters},1)), ...
			mat2str(cellfun('size', testIndices{cviters},1)));
	end;
		
end; % for cviters
