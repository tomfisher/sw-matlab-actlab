function rcmatrix = cmetrics_hist2ratio(hcmatrix)
%function rcmatrix = cmetrics_hist2ratio(hcmatrix)
%
% Convert confusion matrix counts to ratios

classes = size(hcmatrix,1);
cases = sum(sum(hcmatrix));
if (cases <= classes), error('Input matrix appears to be ratios already.'); end;

relevant = col(sum(hcmatrix,2));

rcmatrix = hcmatrix ./ repmat(relevant, 1, classes);

