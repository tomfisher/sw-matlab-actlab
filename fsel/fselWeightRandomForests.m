function veWeight = fselWeightRandomForests(maDataTrain, veLabelTrain, veWeight, varargin)
% function veWeight = fselWeightRandomForests(maDataTrain, veLabelTrain, veWeight, varargin)
% 
% NrTrees:     Number of trees that grows in the forest
% SplitType:  you can choose the criteria to split the Data. following
%              chooses are possible: 'Entropy','Variance' 'Gini', 'Missclassification'
% TreeSize:       depth of the trees
% FeatPerSplit:     How many (randomly choosen) features are available at every node for the
%              election of the feature with the best split.
% Quality:     attribute of a node: the criterie is the entropy of the
%              node: when is the pureness of a class in a node adequat
% 
% Daniel Christen, Wearable Computing Lab, Semesterthesis SS 07, Feature Selection for body-worn sensors
% code reworked, 2007/07/14, Oliver Amft, ETH Zurich

% 
%                            sources:
% "Random Forests",Leo Breimann, aus Machine Learning,45,5-32,2001
%                     "FS Book" Chapter 7 & 15
% 
%"Feature Selection Using Ensemble Based Ranking Against Artificial
%                             Contrasts"
%          Eugen Tuv, Alexander Borisov, Kari Torkkola,
%       International Joint Conference on Neural Networks,2006
% 
%" Application of Breiman's Random Forest to Modeling Structure-Activity
%            Relationships of Pharmaceutical Molecules"
%    Vladimir Svetnik, Andy Liaw, Christopher Tong, Ting Wang,
%         Biometrics Research RY33-300,Merck&Co.Inc
% 
%        "Using Random Forest to Learn Imbalanced Data"
%,            Chao Chen , Andy Liaw, Leo Breimann,
%Departement of Statistics Berkley & Biometrics Research, Merck Research Labs
%
% CART code adapted from:
%  Pattern Classification (2nd Ed.) by David G. Stork and Elad Yom-Tov.
%  2002 John Wiley & Sons, Inc.


[NrTrees, SplitType, Quality, TreeSize, FeatPerSplit, minData, ...
	BootstrapShare, verbose] = process_options(varargin, ...
	'NrTrees', 150, 'SplitType', 'Entropy', 'Quality', 0.02, 'TreeSize', 1e4, 'FeatPerSplit', 10, 'minData', 2, ...
	'BootstrapShare', 0.3, 'verbose', 1);

OldRecursionLimit = get(0,'RecursionLimit');
set(0, 'RecursionLimit', NrTrees*2+5);


[NrObs, NrFeatures]=size(maDataTrain);
NrClasses=length(unique(veLabelTrain));

% NrObs:  Number of samples
% NrFeatures: Number of features
% NrClasses:   Number of classes


% FeatPerSplit: Number of features that are random chosen for the split evaluation
% also possible is 1
if (FeatPerSplit==0), FeatPerSplit=round(sqrt(NrFeatures)); end;


if (verbose>1)
	fprintf('\n%s: Configuration:', mfilename);
	fprintf('\n%s: NrTrees=%u, SplitType=%s, Quality=%.3f, FeatPerSplit=%u, BootstrapShare=%.2f', ...
		mfilename, NrTrees, SplitType, Quality, FeatPerSplit, BootstrapShare);
	fprintf('\n%s: Processing...', mfilename);
end;


% ForestMat: Matrice in which the importance of a feature is evaluated for every tree.
ForestMat=zeros(NrFeatures,NrTrees);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         Building the Forest                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[R C]=size(veLabelTrain);
if C>R
	veLabelTrain=veLabelTrain';
end;

progress = 0.1;
for treenr=1:NrTrees
	% bootstrap sample
	maDataEval=[];
	veLabelEval=[];

	for k=1:NrClasses
		SmpKl = sum(veLabelTrain==k);
		RandVek = randsrc(SmpKl, 1, [1 0; BootstrapShare 1-BootstrapShare]);
		EvalMat = maDataTrain(veLabelTrain==k,:);
		EvalVek = veLabelTrain(veLabelTrain==k);
		EvalVek(RandVek==0) = [];
		EvalMat(RandVek==0,:) = [];
		maDataEval = [maDataEval ; EvalMat];
		veLabelEval = [veLabelEval ; EvalVek];
	end; % for k


	% build tree
	FeatureSelectCount = zeros(NrFeatures,1);% just to look how many times a feature was chosen

	[ForestMatA, FeatureSelectCount] = fselWeightRandomForests_BuildTree(FeatPerSplit,treenr, ...
		ForestMat(:,treenr), maDataEval, veLabelEval, SplitType, Quality, 0, FeatureSelectCount, TreeSize, minData);
	%sprintf('tree no. %d is built',treenr)

	% FeatureSelectCount(FeatureSelectCount==0)=eps;
	ForestMat(:,treenr)=(1/NrTrees).*ForestMatA+ForestMat(:,treenr);

	% indicate progress	
	if (treenr/NrTrees > progress)
		if (verbose), fprintf(' %u%%', round(progress*100)); end;
		progress = progress + 0.1;
	end;
end; % for treenr


%                 Build the Weighting vector
% average importance of every feature is taken
veWeight=sum(ForestMat,2);



set(0, 'RecursionLimit', OldRecursionLimit);









