function veWeight = fselSortCorr(maDataTrain, veLabelTrain, veWeight, N, varargin)
% function veWeight = fselSortCorr(maDataTrain, veLabelTrain, veWeight, N, varargin)
% 
% Independence-based selection of relevance-weighted features. 
% Uses correlation to determine redundancy between features for each class. 
% First feature is selected according to veWeight.
%
% CorrType - select correlation type (Pearson/Spearman)
%   Pearson: continuous, normal distributed data
%   Spearman: continuous, non-parametric? distribution
% veWeight - initial feature weight, used to combine relevance and redundancy selection
% N - number of features to select
%
%
% Copyright 2007 Oliver Amft, ETH Zurich
% Derived from a Semesterthesis SS 07 by Daniel Christen (Feature Selection for body-worn sensors)
% This version is bugfixed, optimised for speed and memory footprint.
%
%                            Sources: 
%"A Signigicance Test Based Feature Selection Method for the Detection 
%           of Prostata Cancer from Proteomic Patterns", 
%            Qianren Xu Waterloo, Ontario,Canada, 2004
%
%       "Wahrscheinlichkeitsrechnung und Statistik mit MATLAB
%Anwendungsorientierte Einfuehrung fuer Ingenieure und Naturwissenschaftler"
%                        Beucher, Ottmar

error('Adapt using CorrDD code');

[CorrType, Beta] = process_options(varargin, 'CorrType', 'Pearson', 'Beta', 1);

[NObs, NFeatures] = size(maDataTrain);

Classes = unique(veLabelTrain);
NClasses = length(Classes); 

% analyse correlation for each class
totalind = zeros(NFeatures*(NFeatures-1)/2,1);
for c = 1:NClasses
	% 	selected = veWeightNew > 0;
	classobs = veLabelTrain==Classes(c);

	warning('off', 'MATLAB:divideByZero');
	switch lower(CorrType)
		case 'pearson'
			%cmat = corr(maDataTrain(classobs, selected), maDataTrain(classobs, ~selected), 'type', 'Pearson');
			cmat = corr(maDataTrain(classobs, :), 'type', 'Pearson');
		case 'spearman'
			%cmat = corr(maDataTrain(classobs, selected), maDataTrain(classobs, ~selected), 'type', 'Spearman');
			cmat = corr(maDataTrain(classobs, :), 'type', 'Spearman');
		otherwise
			error('Parameter CorrType=%s not supported.', CorrType);
	end;
	warning('on', 'MATLAB:divideByZero');

	% keep half of the matrix only, squareform(.) could convert it back
	cmat = cmat(tril(true(size(cmat,1)),-1));

	totalind = totalind + sqrt(1-cmat.^2);
end; % for c
totalind = totalind ./ NClasses;

% % combine difference & independence
% fsignificance = zeros(NFeatures*(NFeatures-1)/2,1);
% for i = 1:NFeatures
% 	for j = i+1:NFeatures
% 		x = (i-1)*(NFeatures-i/2)+j-i;
% 		fsignificance(x) = totalind(x) * veWeight(i);
% 	end; % for j
% end; % for i


%% determine first feature using maximum difference
veWeightNew = zeros(1, NFeatures);
[v idx] = max(veWeight);
veWeightNew(idx(1)) = v;

selfeatures = zeros(1,N);
selfeatures(1) = find(veWeightNew > 0);

%% select further features using correlation to determine independence
fsig = zeros(NFeatures, N);
for f = 2:N
	% Find highest feature significance for already selected features:
	%
	% For every selected feature one ROW in fsig is filled. Each row
	% contains the relation (independence*relevance) of every feature to
	% the selected one. Then, by summing each column the overall most 
	% important feature is determined.

	% fill fsig for the latest selected feature
	i = selfeatures(f-1);
	for j = 1:NFeatures
		if (j==i), continue; end;
		if (j < i), x1 = j; x2 = i; else x1 = i; x2 = j; end;
		x = (x1-1)*(NFeatures-x1/2)+x2-x1;

		fsig(f, j) = Beta * totalind(x) * veWeight(j);
		%disp([x1 x2]);
	end; % for j
	
	% find column of most relevant feature
	[maxsf maxsfpos] = max(sum(fsig,1));
	if (maxsfpos==0), break; end;

	% now since we know, add maxsf
	veWeightNew(maxsfpos) = maxsf;
	selfeatures(f) = maxsfpos;  % not done for f==1
	
	%disp([maxsf maxsfpos]);
end; % for f
