function newcells = cellappend(oldcells, appendcells, dim)
% function newcells = cellappend(oldcells, appendcells, dim)
% 
% Combine cell array
% 
% See also: cellstringprod.m, fb_featurestringprod.m
% 
% Copyright 2007 Oliver Amft

newcells = {};

if (~iscell(oldcells)) || (~iscell(appendcells))
    %warning('MATLAB:cellappend','At least one input is no cell array, changed it.');
end;
if (~iscell(oldcells)), oldcells = {oldcells}; end;
if (~iscell(appendcells)), appendcells = {appendcells}; end;

if (~exist('dim','var')), 
	if size(oldcells,2)>1, dim = 2; else dim = 1; end;
end;

if isempty(oldcells)
    newcells = appendcells;
    return;
end;
if isempty(appendcells)
    newcells = oldcells;
    return;
end;

if (min(size(oldcells)) > 1) || (length(size(oldcells)) > 2)
    error('Cell array size not compatible.');
end;

if any( size(oldcells) ~= size(appendcells) )
    warning('MATLAB:cellappend', 'Cell sizes do not match.');
end;

for i = 1:length(oldcells)
	if dim==1  % append row
		newcells{i} = [ oldcells{i}; appendcells{i} ];
	else
		%size(oldcells,2)>1  % append col
		newcells{i} = [ oldcells{i} appendcells{i} ];
	end;
end;