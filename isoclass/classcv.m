function [TR TE CVSliceSize] = classcv(IDList, varargin)
% function [TR TE CVSliceSize] = classcv(IDList, varargin)
% 
% Create CV splits 
%
% Optional parameters:
% CVFolds  - # of cross-validations, default: 5
% TrainTestRatio - Training share for each CV, default=CVFolds-1
% ReturnIdx - Return indices instead of IDList contents, default=true
% ClassCol - column in IDList that provides class info, default=1

% (c) 2007 Oliver Amft, ETH Zurich

TR = {}; TE = {};

nIDs = size(IDList,1);

[CVFolds CVSliceSize TrainTestRatio ReturnIdx ClassCol verbose] = process_options(varargin, ...
	'CVFolds', 5, 'CVSliceSize', 0, 'TrainTestRatio', 0, 'ReturnIdx', true, 'ClassCol', 1, 'verbose', 0);

if (nIDs < CVFolds), error('Number of observations is smaller than CVFolds.'); end;

ClassIDs = unique(IDList(:,ClassCol));

if (TrainTestRatio == 0), TrainTestRatio = CVFolds-1; end;
if (TrainTestRatio ~= CVFolds-1), error('Setting for TrainTestRatio not supported.'); end;

if (verbose), fprintf('\n%s: nIDs=%u, nClasses=%u', mfilename, nIDs, length(ClassIDs)); end;

% determine size of CV slices (for each class)
if isempty(CVSliceSize) || (min(CVSliceSize) <= 0)
	CVSliceSize_class = zeros(1, length(ClassIDs));
	for classnr = 1:length(ClassIDs)
		class = ClassIDs(classnr);
		classids = length(find(IDList(:,ClassCol)==class));
		CVSliceSize_class(class) = floor(classids / CVFolds) + (classids < CVFolds);
	end;

	CVSliceSize = min(CVSliceSize_class);
	if (verbose), fprintf('\n%s: CVSliceSize=%u', mfilename, CVSliceSize); end;
end;


% create CV for each class indiviually
% train labels are splitted into equal slices, test labels of last slice is rest
for classnr = 1:length(ClassIDs)
	class = ClassIDs(classnr);

	% find labels for current class
	IDList_classidx = find(IDList(:,ClassCol)==class);
	if isempty(IDList_classidx), error('No observations for class %u', class); end;


	% create train (TR) / test (TE) slice splits
	% http://neuralnetworks.ai-depot.com/NeuralNetworks/1281.html
	SelectList = IDList_classidx;

	for cvi = 1:CVFolds
		if (cvi < CVFolds)
			TR{cvi}{class} = [ SelectList(1:(cvi-1) * CVSliceSize,:); SelectList((cvi * CVSliceSize)+1:(CVFolds*CVSliceSize),:) ];
			TE{cvi}{class} = SelectList((1+(cvi-1) * CVSliceSize):(cvi * CVSliceSize),:);
		else
			TR{cvi}{class} = SelectList(1:(cvi-1) * CVSliceSize,:);
			TE{cvi}{class} = SelectList((1+(cvi-1) * CVSliceSize):end,:);
		end;

		if (verbose>1)
			fprintf('\n%s: CV slice %u, train: %u, test: %u', mfilename, ...
				cvi, length(TR{cvi}{class}), length(TE{cvi}{class}) );
		end;

		% translate into IDList elements OR return indices only
		if (ReturnIdx==false)
			TR{cvi}{class} = IDList(TR{cvi}{class},:);
			TE{cvi}{class} = IDList(TE{cvi}{class},:);
		end;

		TR{cvi} = col(TR{cvi}); TE{cvi} = col(TE{cvi});
	end; % for cvi

	if (verbose)
		fprintf('\n%s: Class %u: CV=1: Train=%u Test=%u,   CV=%u: Train=%u Test=%u', ...
			mfilename, class, length(TR{1}{class}), length(TE{1}{class}), cvi, length(TR{cvi}{class}), length(TE{cvi}{class}) );
	end;
end; % for classnr

