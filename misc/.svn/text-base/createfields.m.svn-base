function S = createfields(S, names, values)
% function S = createfields(S, names, values)
% 
% Create/copy variables into struct fields
% 
% See also: rmfield, fieldnames, isfield
% 
% Copyright 2007-2009 Oliver Amft

if isempty(S), clear S; end;
if ~iscell(names), names = {names}; end;
if ~iscell(values), values = {values}; end;

for i = 1:length(names)
    S.(names{i}) = values{i};
end;
