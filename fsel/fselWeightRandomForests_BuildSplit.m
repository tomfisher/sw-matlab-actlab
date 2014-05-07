function ISub = fselWeightRandomForests_BuildSplit(SplitPoint, maDataUse, veLabelUse, split_type)
% function ISub = fselWeightRandomForests_BuildSplit(SplitPoint, maDataUse, veLabelUse, split_type)
% 
% Subfunction of fselWeightRandomForests to build the split. The split is
% built after chosing split_type.This funtion returns the the weighted
% informtion of the subnodes.
%
% Daniel Christen, Wearable Computing Lab, Semesterthesis SS 07, Feature Selection for body-worn sensors
% code reworked, 2007/07/14, Oliver Amft, ETH Zurich

% OAM REVISIT: Optimise code!

Uc = unique(veLabelUse);

PR = zeros(1, length(Uc));  PL = zeros(1, length(Uc));
for i = 1:length(Uc)
	%in   = length(find(veLabelUse == Uc(i)));
	PR(i) = sum( maDataUse(veLabelUse==Uc(i)) >  SplitPoint) / sum(veLabelUse==Uc(i));
	PL(i) = sum( maDataUse(veLabelUse==Uc(i)) <=  SplitPoint) / sum(veLabelUse==Uc(i));
end;

switch split_type
	case 'Entropy'
		Er = sum(-PR.*log(PR+eps)/log(2));
		El = sum(-PL.*log(PL+eps)/log(2));
	case {'Variance', 'Gini'}
		Er = 1 - sum(PR.^2);
		El = 1 - sum(PL.^2);
	case 'Missclassification'
		Er = 1 - max(PR);
		El = 1 - max(PL);
		
	otherwise
		error('Possible splitting rules are: Entropy, Variance, Gini, or Missclassification')
end;

P = length(find(maDataUse <= SplitPoint)) / length(maDataUse);

ISub = P*El + (1-P)*Er;






