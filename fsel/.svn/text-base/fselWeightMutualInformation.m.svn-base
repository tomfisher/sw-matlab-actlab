function [veWeight]=fselWeightMutualInformation(maDataTrain,veLabelTrain,veWeight)

%
% function [veWeight]=fselWeightMutualInformation(maDataTrain,veLabelTrain,veWeight)
%
% Relevance measurement: calculates MI(feature,classes), modifies veWeight
%
% Input: maDataTrain  : train data, col = feature, row = observation
%        veLabelTrain : column vector with train labels (one per observation)
%        veWeight     : row vector with rank of features
%
% Output: veWeight : row vector with relevance of features
%
% (c) 20071009 Holger Harms, Wearable Lab, ETH Zurich
%

cl = unique(veLabelTrain);          % vector with classes
cls=length(cl);                     % determine number of classes
[obs,feats]=size(maDataTrain);      % determine number of obs and feats

% Calculate number of used bins as the square root of the observation
BINS = round(2*obs.^(1/2));
if (BINS <= 10)
    fprintf('WARNING [fselWeightMutualInformation]: low number of bins (%d)\n', BINS);
end;

% calculate observations per class
obsCl(1:cls) = 0;
for i=1:cls 
  obsCl(i)=sum(veLabelTrain==cl(i)); 
end;

% normalize data space to bins 
for f=1:feats
  maDataTrain(:,f) = maDataTrain(:,f) - min(maDataTrain(:,f));
  maDataTrain(:,f) = (BINS * maDataTrain(:,f))/max(maDataTrain(:,f));
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Px = PDF for features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Px(1:1:feats,:) = (hist(maDataTrain,BINS)/obs)';  % calculate feature's pdf 
Px = Px';                                         % row = feature, col = bin

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Py = PDF for classes 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Py(1,1:1:cls)=1/cls;    % assumption: classes are equally distributed:
Py=obsCl/obs;            % determine exact distribution of classes:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MI between classes and features                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pxy=P(x¦y)
% PVer=P(x,y)
% Px=P(x)

MutInf = zeros(cls,feats);              

bin=1:1:BINS;                 % evaluation points for hist

% go trough every feature (=x)
for f=1:feats
    % do not features with zero relevance
    if veWeight(f)>0
        % go trough every class (=y)
        for y=1:cls
            % determine the conditional probability
            Pxy=hist(maDataTrain(veLabelTrain==y,f),bin)/obsCl(y);
            % determine the joint probability between x and y at q
            PVer=Pxy.*Py(y);
          
            for x=1:BINS
                %Determine the Mutual Information
                if ( (PVer(x)>0) && (Py(y)>0) && (Px(x,f)>0) )  
                    MutInf(y,f) = MutInf(y,f) + PVer(x)*log2(PVer(x)/(Py(y)*Px(x,f)));
                end
            end
        end
    end
end

% set and normalize relevance vector
veWeight=sum(MutInf);
veWeight=veWeight/max(veWeight);























