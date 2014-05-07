function fselEvalPrintStats(acc, veWeight, veFeature)

%  
% fselEvalPrintStats( acc, veWeight, veFeature)
% 
% prints classifiaction statistics:
% achieved accuracy, rank and name of feature
%
% Input:    acc             : accuracy (see fselEvalClassification)
%           veWeight        : ranking vector
%           veFeature       : name of features
%
% Output:   None
%
% (c) 20070510 Holger Harms, Wearable Computing Lab., ETH Zurich
%

% get number of selected features (>0)
feats = sum(veWeight > 0 );

% print
fprintf('[EvalPrintStats] Accuracy : %3.2f percent\n', acc*100 );
%fprintf('[EvalPrintStats] Features selected: %d\n', feats);

[rankNum featNum] = sort(veWeight, 'descend');

fprintf('\n¦ Rank ¦ Value ¦ Description\n');
fprintf('¦------+-------+------------\n');

for f=1:feats
  fprintf('¦ %4.0f ¦ %1.3f ¦ %s \n', f, rankNum(1,f), veFeature{1,featNum(f)} );   
end;



% print feature
% veFeature(find(veWeight ~= 0))

