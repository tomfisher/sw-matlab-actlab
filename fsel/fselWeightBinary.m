function veWeight = fselWeightBinary( maDataTrain, veLabelTrain, veWeight, varargin);
% function veWeight = fselWeightBinary( maDataTrain, veLabelTrain, veWeight, varargin);
%
% Discretise feature weight vector to [0, 1] for selection purposes

Threshold = process_options(varargin, 'Threshold', 0);

veWeight = veWeight > Threshold;
