function veWeight = fselWeightRandom( maDataTrain, veLabelTrain, veWeight );
% function veWeight = fselWeightRandom( maDataTrain, veLabelTrain, veWeight );
%
% Dummy function for feature ranking. Returned veWeight will be random value.

% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
% simplified, 2007/07/15, Oliver

[NrObs, NrFeatures] = size(maDataTrain);

% print random value in every feature rank
veWeight = rand(1, NrFeatures);
