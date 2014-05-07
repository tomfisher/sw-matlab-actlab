function varargout = prmetrics_getfields(prmetrics, fields)
% function varargout = prmetrics_getfields(prmetrics, fields)
%
% Extract fields to vectors from prmetrics struct
%
% See also: prmetrics_getpr
% 
% Copyright 2006, 2007 Oliver Amft

if ~exist('fields','var') || isempty(fields) 
    fields = {'precision', 'recall'}; 
end;

if ~iscell(fields), fields = {fields}; end;

tmp = [];
for f = 1:length(fields)
    if ~isfield(prmetrics, fields{f})
        fprintf('\n%s: Field ''%s'' does not exist, skipping.', mfilename, fields{f});
        continue;
    end;
    
	for i=1:length(prmetrics)
		if isempty(prmetrics(i)), continue; end;
		if (f==1) && (i==1), tmp = zeros(length(prmetrics), length(prmetrics(i).(fields{f}))); end;

		tmp(i,f) = prmetrics(i).(fields{f});
	end; % for i
end; % for f
varargout = {tmp};