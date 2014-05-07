function cmetric = cmetrics_mkmatrixfromcell(allresults, varargin)
% function cmetric = cmetrics_mkmatrixfromcell(allresults, varargin)
%
% Build a confusion matrix (cmetrics) from a list of classifier results. This list is
% a classwise cell list of the predicted class.
% 
% Copyright 2007 Oliver Amft

classes = max(size(allresults));
cmetrics = zeros(classes);

for gtclass = 1:classes
    for prclass = 1:classes
        cmetrics(gtclass,prclass) = confusion(gtclass,prclass) + ...
            length(find(allresults{gtclass} == prclass));
    end;
end;

