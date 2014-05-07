function [veWeight] = fselSortBestN( maDataTrain, veLabelTrain, veWeight, N );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
%
% Dummy function for feature sorting. The highest weighted N features will 
% hold their weight, the others will be set to 0.
% In case more than N features could be chosen (because of an equal weight), 
% the first N are taken.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% rank features according to there individual weight
[dummy sortInd] = sort(veWeight, 'descend' );

for i=N+1:length(veWeight)
  veWeight(sortInd(i)) = 0;
end

    
