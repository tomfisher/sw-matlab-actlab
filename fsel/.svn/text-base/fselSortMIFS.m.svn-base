function veWeight=fselSortMIFS(maDataTrain, veLabelTrain, veWeight, Beta, K)
%function veWeight=fselSortMIFS(maDataTrain, veLabelTrain, veWeight, Beta, K)
%
%
% After:  "Using Mutual Information for Selecting Features in Supervised Neural
%   Net Learning" Roberto Battiti, IEEE 1994
%
% Input: 
%       Beta: beta variable in MIFS algorithm, metric for influence of feature
%       dependence
%       K   : number of features to select
%

% V 0.91 HH
% 080214 bins are calculated as 2*sqrt(obs)
% 080214 data are extended individually (from min to max)
% 080214 no hist to calculate pdf of virtual classes

% get number of observations and features
[obs feats]=size(maDataTrain);

% Calculate number of used bins as the square root of the observation
BINS = round(2*obs.^(1/2));
if (BINS <= 10)
    fprintf('WARNING [fselSortMIFS]: low number of bins (%d)\n', BINS);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Initialization 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize sets, the sets consit of a zeor or one for a features 
F = ones(1,feats);      % set of initial features
S = zeros(1,feats);     % set of selected features

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Computation of the MI with each output class
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MI between features and classes
I_CF = fselWeightMutualInformation(maDataTrain, veLabelTrain, veWeight);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Choise of the first feature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find the highest rank
[val ind] = sort(I_CF);  
S(ind(feats)) = 1;  % insert hightes ranked feature into S
F(ind(feats)) = 0;  % remove highest ranked feature from F

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute MI for all combinations of features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
I_fs = zeros(feats,feats); % mutual information between features f and s

for i=1:feats
  % normalize f in a way that it behaves like 'classes'
  f = maDataTrain(:,i)-min(maDataTrain(:,i));   % push data to zero 
  f = BINS*f/max(f);                            % scale data to from zero to BINS
  f = round(f);                                 % round data -> virtual classes
  I_fs(:,i) = fselWeightMutualInformation(maDataTrain, f, ones(1,feats))';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Greedy selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% repeat until �S� = k (S = selected features)
while(sum(S)<K)
 
  for f=1:feats
    % for every potential (unselected) feature...
    if (F(f) == 1) 
      B(f)=I_CF(f)-Beta*sum(I_fs(f,S==1)); 
    end
  end

  % if B is negative, make it positive
  if (max(B)<=0) 
    B=B-min(B); 
  end

  % don't consider already selected features
  B(S==1)=0;

  % find the highest rank
  [val ind] = sort(B);  
  S(ind(feats)) = 1;  % insert hightes ranked feature into S
  F(ind(feats)) = 0;  % remove highest ranked feature from F
end
 
% store S in veWeight
veWeight = S;
 



 
