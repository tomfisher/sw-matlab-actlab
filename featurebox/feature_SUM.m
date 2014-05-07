function thisfeature = feature_SUM(sdata, method)
% function thisfeature = feature_SUM(sdata, method)
%
% Data conditional sum 
% 
% Copyright 2006 Oliver Amft


switch lower(method)
    case 'pos'
        thisfeature = sum(sdata(sdata > 0),1);
    case 'neg'
        thisfeature = sum(sdata(sdata < 0),1);
    otherwise
        thisfeature = sum(sdata,1);
end;

thisfeature = thisfeature / length(sdata);