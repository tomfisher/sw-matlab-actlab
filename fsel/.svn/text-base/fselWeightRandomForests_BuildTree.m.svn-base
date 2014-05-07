function [ForestMat, NumFeatElec] = fselWeightRandomForests_BuildTree(NumFeat, TreeNum, ForestMat, ...
	maDataEval, veLabelEval, split_type, Quality, Limit, NumFeatElec, depth, minData)
% function [ForestMat, NumFeatElec] = fselWeightRandomForests_BuildTree(NumFeat, TreeNum, ForestMat, ...
% 	maDataEval, veLabelEval, split_type, Limit, NumFeatElec, depth, Quality, minData)
%
% subfunction of fselWeightRandomForests to build the split
%
% Daniel Christen, Wearable Computing Lab, Semesterthesis SS 07, Feature Selection for body-worn sensors
% code reworked, 2007/07/14, Oliver Amft, ETH Zurich

% OAM REVISIT: Optimise code!


%return if maximum tree-depth is reached.
%NumFeat=round(sqrt(AnzFeat));
Limit=Limit+1;

if Limit>depth
	disp('tree of maximum depth reached');
	return;
end;



% return if node is a leaf: entropy==0
if (length(unique(veLabelEval))==1);
	%disp('leaf');
	return;
end;



% Entropy of the Parent-Node
UniqueVeLabelEval=unique(veLabelEval);
IParent = zeros(1, length(UniqueVeLabelEval));
for i=1:length(UniqueVeLabelEval)
	IParent(i) = sum(veLabelEval==UniqueVeLabelEval(i));
end;
IParent = -sum(IParent/length(veLabelEval).*log2(IParent/length(veLabelEval)+eps));

% return if the node is pure (with respect to the classes)
if IParent<Quality
	disp('Quality reached');
	return;
end;


% return if there are to less Data to build a relevant split
if length(maDataEval)<minData
	disp('to less Data in the split');
	return;
end;



%            Random-Choose of n featuers out of All
[AnzSmp AnzFeat]=size(maDataEval);
EvalFeat=zeros(1,AnzFeat);
HelpVekA=ones(1,AnzFeat);
EvalFeatB = HelpVekA.*rand(1,AnzFeat);
HelpVek = sort(EvalFeatB);
EvalFeat(EvalFeatB<=HelpVek(NumFeat))=1;

% Only Data of the random chosen Features will be evaluated
% maDataUse=maDataEval(:,EvalFeat==1);
% veLabelUse=veLabelEval;



%             Split according to the splitting criterion
% evaluate the tree with respect to the information gain
SplitPoint = zeros(1,AnzFeat);
ISub = zeros(1,AnzFeat);
for Feat=1:AnzFeat
	if (EvalFeat(Feat)==1)
		% finding the best split-point for the appropriate feature
		op = optimset('Display','off');
		SplitPoint(Feat) = fminbnd('fselWeightRandomForests_BuildSplit',min(maDataEval(:,Feat)),max(maDataEval(:,Feat)), op, maDataEval(:,Feat), veLabelEval, split_type);

		% evt. that will also work (not tested at all)
		%SplitPoint(Feat)=fminbnd(@(x),BuildSplit(x, maDataUse, veLabelUse, Feat, split_type),min(maDataUse(:,Feat)),max(maDataUse(:,Feat)))
		% building the split and evaluate the weighted entropy of the sub-nodes
		ISub(Feat) = feval('fselWeightRandomForests_BuildSplit', SplitPoint(Feat), maDataEval(:,Feat), veLabelEval, split_type);
	else
		ISub(Feat) = inf;
	end;
end;


% gewEnt:     best weighted entropy of the splits
% BestSplit:  best split point of the different features
%
% this means: best split is buildt with feature Ind with split point
% BestSplit

[gewEnt Ind] = min(ISub);
NumFeatElec(Ind) = NumFeatElec(Ind)+1;
BestSplit = SplitPoint(Ind);

% update the ForestMat with the data of the evaluated(best) feature
ForestMat(Ind) = ForestMat(Ind)+IParent-gewEnt;

%return if there is no possible split built
if isempty(veLabelEval(maDataEval(:,Ind)>BestSplit)) || isempty(veLabelEval(maDataEval(:,Ind)<=BestSplit))
	%disp('no possible split')
	return;
end;

% recursive build next level of the tree (cultivate branches of the tree)
[ForestMatA,NumFeatElecA]=fselWeightRandomForests_BuildTree(NumFeat, TreeNum, ForestMat, ...
	maDataEval(maDataEval(:,Ind)>BestSplit,:), veLabelEval(maDataEval(:,Ind)>BestSplit), ...
	split_type, Quality, Limit, NumFeatElec, depth, minData);

[ForestMatB,NumFeatElecB]=fselWeightRandomForests_BuildTree(NumFeat, TreeNum, ForestMat, ...
	maDataEval(maDataEval(:,Ind)<=BestSplit,:), veLabelEval(maDataEval(:,Ind)<=BestSplit), ...
	split_type, Quality, Limit, NumFeatElec, depth, minData);

% summation of the Forest mat to evaluate the importance of the features
ForestMat=ForestMatA+ForestMatB;

% the look how many times a feature was chosen as the best feature
NumFeatElec=NumFeatElecA+NumFeatElecB;
