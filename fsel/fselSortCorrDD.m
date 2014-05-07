function veWeightNew = fselSortCorrDD(maDataTrain, veWeight, NSelFeatures, varargin)
% function veWeightNew = fselSortCorr(maDataTrain, veWeight, NSelFeatures, varargin)
% 
% Independence-based selection of relevance-weighted features for data
% description (DD) problems. Uses correlation to determine redundancy
% between features for the target class. First feature is selected according to
% veWeight. 
%
% CorrType - select correlation type (Pearson/Spearman)
%   Pearson: continuous, normal distributed data
%   Spearman: continuous, non-parametric? distribution
% veWeight - initial feature weight, used to combine relevance and redundancy selection
% NSelFeatures - number of features to select
%
%
% Copyright 2007 Oliver Amft, ETH Zurich
%
%                            Sources: 
%"A Signigicance Test Based Feature Selection Method for the Detection 
%           of Prostata Cancer from Proteomic Patterns", 
%            Qianren Xu Waterloo, Ontario,Canada, 2004


[CorrType, Beta, verbose] = process_options(varargin, 'CorrType', 'Pearson', 'Beta', 1, 'verbose', 0);

[NObs, NFeatures] = size(maDataTrain);

%% initial weighting shall be normalised
veWeight = veWeight / max(veWeight);
veWeight(isnan(veWeight)) = 0;

%% determine first feature using maximum weight
veWeightNew = zeros(1, NFeatures);
[v idx] = max(veWeight);
veWeightNew(idx(1)) = NSelFeatures; %v;

selfeatures = zeros(1,NSelFeatures);  % scoreboard of selected features
selfeatures(1) = find(veWeightNew > 0);

%% select further features using correlation to determine independence

fsig = zeros(NSelFeatures, NFeatures);
for f = 2:NSelFeatures
	% select feature from previous iteration
	i = selfeatures(f-1);
	%veWeight(i) = 0;
	
	% Find highest feature independence compared to previously selected feature 
	warning('off', 'MATLAB:divideByZero');
	switch lower(CorrType)
		case 'pearson'
			cmat = corr(maDataTrain(:,i), maDataTrain, 'type', 'Pearson');
		case 'spearman'
			cmat = corr(maDataTrain(:,i), maDataTrain, 'type', 'Spearman');
		otherwise
			error('Parameter CorrType=%s not supported.', CorrType);
	end;
	warning('on', 'MATLAB:divideByZero');
	cmat(isnan(cmat)) = 1;  % set divideByZero to redundant

	% cmat is one row with corr of each feature to previously selected feature  
	totalind = sqrt(1-cmat.^2);
	%totalind(i) = 0;  % set self-independence to zero

	% For every selected feature one ROW in fsig is filled. Each row
	% contains the relation (independence*relevance) of every feature to
	% the selected one. Then, by summing each column the overall most 
	% important feature is determined.

	% fill fsig for the latest selected feature
	fsig(f-1, :) = ( totalind .* veWeight )  * Beta;
	
	% features that have been selected until now should be excluded
	fsig(:, selfeatures(1:f-1)) = 0;
	
	% find column of most relevant NEXT feature
	[maxsf maxsfpos] = max(sum(fsig,1));   % reweighted compared to previously selected 
	if (maxsf==0) || (maxsfpos==0), break; end;

	% now since we know, add maxsf
	veWeightNew(maxsfpos) = NSelFeatures-f+1;  % maxsf;
	selfeatures(f) = maxsfpos;
	
	if (verbose), fprintf('\n  F %3u,  %f', maxsfpos, maxsf); end;
end; % for f

veWeightNew = veWeightNew / max(veWeightNew);
veWeightNew(isnan(veWeightNew)) = 0;