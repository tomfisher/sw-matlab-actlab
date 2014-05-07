function [trainSegBest trainSegMax testSegBest testSegMax] = spot_converthresarrays(...
	trainSeg, trainDist, testSeg, testDist, bestthres, CVFolds)
% function [trainSegBest trainSegMax testSegBest testSegMax] = spot_converthresarrays(...
% 	trainSeg, trainDist, testSeg, testDist, bestthres, CVFolds)
% 
% Convert cell array strcuture of spotting threshold results to simple
% Best/Max list that include the distance in column 6.
% 
% See also: spot_loadcvresults, spot_convertfiles
% 
% Copyright 2008 Oliver Amft

% need to walk through all CV folds
trainSegBest = cell(1, CVFolds);  testSegBest = cell(1, CVFolds);
trainSegMax = cell(1, CVFolds);  testSegMax = cell(1, CVFolds);
for cvi = 1:CVFolds
	% training seglists
	ltmp = length(trainSeg{cvi});
	if ~all(isemptycell(trainSeg{cvi})) 
		trainSegBest{cvi} = trainSeg{cvi}{bestthres(cvi)};
		trainSegBest{cvi}(:,6) = trainDist{cvi}{bestthres(cvi)};

		trainSegMax{cvi} = trainSeg{cvi}{ltmp};
		trainSegMax{cvi}(:,6) = trainDist{cvi}{ltmp};
	end;

	% testing seglists
	ltmp = length(testSeg{cvi});
	if ~all(isemptycell(testSeg{cvi})) 
		testSegBest{cvi} = testSeg{cvi}{bestthres(cvi)};
		if ~isempty(testSegBest{cvi})
			testSegBest{cvi}(:,6) = testDist{cvi}{bestthres(cvi)};
		end;

		testSegMax{cvi} = testSeg{cvi}{ltmp};
		if ~isempty(testSegMax{cvi})
			testSegMax{cvi}(:,6) = testDist{cvi}{ltmp};
		end;
	end;

end % for cvi
