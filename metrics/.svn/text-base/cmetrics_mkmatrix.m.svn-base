function cmetrics = cmetrics_mkmatrix(trueclasses, predictedclasses, varargin)
% function cmetrics = cmetrics_mkmatrix(trueclasses, predictedclasses, varargin)
%
% Build a confusion matrix from a list of classifier results. 
% Rows: Actual/true class, Column: Predicted class
%
% Example:
% 
% ref = [1 1 2 1 3 1 1]; pred = [1 1 2 2 3 1 1];
% cmetrics_mkmatrix(ref, pred)
% 
% ans =
% 
%      4     1     0
%      0     1     0
%      0     0     1
% 
% 
% See also: 
%   cmetrics_mkmatrixfromcell, cmetrics_mkmatrixfromseg, cmetrics_mkstats 
% 
% Copyright 2006-2008 Oliver Amft
%
% changelog:
% 20061203: made this independent of absolute class labels, mk
% 20080226: added classids option for partial results, oam

classids = process_options(varargin, 'classids', unique(trueclasses));
classes = length(classids);
cmetrics = zeros(classes);

for class = 1:classes
    for predicted = 1:classes
        cmetrics( class, predicted ) = cmetrics(class,predicted) + ...
			sum( predictedclasses( trueclasses == classids(class) ) == classids(predicted) );
    end;
end;
