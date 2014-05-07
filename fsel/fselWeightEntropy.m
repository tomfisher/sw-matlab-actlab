function [veWeight] = fselWeightEntropy( maDataTrain, veLabelTrain, veWeight )
% function [veWeight] = fselWeightEntropy( maDataTrain, veLabelTrain, veWeight )
%
% returns normalized entropy of features
%
% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich

% get dimensions of train data
[nobs feats] = size( maDataTrain );

bins = 1024; % lets assume we have 1024 bins

% compute entropy of every feature
for f=1:feats
  [pdf] = hist( maDataTrain(:,f), bins ); % create pseudo pdf from histogram
  p = pdf ./ nobs;                         % compute probabilites from pdf
 
  % convention is that p=0 is not considered
  for b = 1:bins
    if ( p(b) > 0 ), veWeight(f) = veWeight(f) - ( p(b) * log2(p(b)) ); end
  end 
  
end

% normalization
veWeight = veWeight ./ max(veWeight);

