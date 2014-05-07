function [veWeight]=fselWeightKRUSKAL(maDataTrain,veLabelTrain,veWeight)

% function [veWeight]=fselWeightKRUSKAL(maDataTrainA,veLabelTrain,veWeight)
% 
% statistical Filter Method for:
% continuous, not normal distributed Data : KRUSKAL-WALLIS
%
% (c) 20071009 Holger Harms, Wearable Lab, ETH Zurich

[obs, feats]=size(maDataTrain);     % number of observations and features
cl = unique(veLabelTrain);          % different classes
cls = length(cl);                   % number of classes
rank = tiedrank(maDataTrain);       % ranks

% 1. compute ranksum for every class (Ri)
% -> rankSum(Class, Feature)
% 2. compute observations per class (ni)
% -> assumed that every feature has the same number of observations
for i=1:cls
  rankSum(i,:) = sum(rank(veLabelTrain == cl(i),:));
  obsCl(i) = sum(veLabelTrain == cl(i));
end

% parallels to literature
% n = obs (number of observations)
% I  = cls (number of classes)
% ni = obsCl (observations per class)
% Ri = rankSum (ranksum per class)
% H = H(i) = test statistic for every feature

H = zeros(1,feats);

for f=1:feats
  if (veWeight(f) > 0)              % don't consider unrelevant features
    for i=1:cls
      Ei = (obsCl(i)*(obs+1)/2);      % expectation for ranksum in class i
      H(1,f)=H(1,f)+(1/obsCl(i))*(rankSum(i,f)-Ei)^2;
    end
    H(1,f) = H(1,f)*12/(obs*(obs+1));
  end
end

%normalize
veWeight = H/max(H);



























