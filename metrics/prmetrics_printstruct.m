function str = prmetrics_printstruct(metric)
% function str = prmetrics_printstruct(metric)
%
% Print a PR performance metric struct
% 
% Copyright 2005 Oliver Amft

% recall = []; precision = [];

str = '';
for i = 1:max(size(metric))
	if isempty(metric(i).relevant), continue; end;
	if length(metric(i).relevant)>1, 
		fprintf('\n%s: Works on single metrics only. Use prmetrics_splitclass to separate.', mfilename);
		continue; 
	end;


	str = [ str sprintf('\n  i%u, recall: %.2f, prec: %.2f, rel: %2u, ret: %2u, rec: %2u, ins: %u, del: %u', ...
		i, metric(i).recall, metric(i).precision, ...
		metric(i).relevant, metric(i).retrieved, metric(i).recognised, ...
		metric(i).insertions, metric(i).deletions) ];

end;

if ~nargout, fprintf(str); end;
% fprintf('\n');
