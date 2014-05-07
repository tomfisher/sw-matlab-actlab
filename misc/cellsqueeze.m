function outcells = cellsqueeze(incells)
% function outcells = cellsqueeze(incells)
% 
% Squeeze operation for cell arrays
% Works on 1-dim arrays only!
% 
% Copyright 2007 Oliver Amft, ETH Zurich

if ~iscell(incells), outcells = incells; return; end;

if (min(size(incells)) > 1), error('Works on 1-dim arrays only.'); end;

if (length(incells) == 1)
	outcells = incells{1};
else
	outcells = cell(size(incells));
	for i = 1:length(incells)
		outcells{i} = cellsqueeze(incells{i});
	end;
end;

