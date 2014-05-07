function h = strhist(Observations, varargin)
% function h = strhist(Observations, varargin)
% 
% Symbol histogram

defaultsymbols = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

[obsfield symbolset usedefaultsym] = process_options(varargin, ...
	'obsfield', 'string', 'symbolset', '', 'usedefaultsym', false);

if isempty(obsfield)
	% assume cell array of strings
	obssymbols = cell2str(Observations,'');
else
	% assume struct field
	obssymbols = cell2str({Observations(:).(obsfield)},'');
end;

if (usedefaultsym), symbolset = defaultsymbols; end;

if isempty(symbolset)
	symbolset = unique(obssymbols);
	fprintf('\n%s: WARNING: Atuomatically estimated symbol set.', mfilename);
end;


h = zeros(1, length(symbolset));
for i = 1:length(symbolset)
	h(i) = sum(obssymbols == symbolset(i));
end;
h = h ./ length(Observations);
