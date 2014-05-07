function [DTableVirtual DTableActual] = repos_getdtable(Repository, Partindex, Systems)
% function [DTableVirtual DTableActual] = repos_getdtable(Repository, Partindex, Systems)
% 
% Load DTable (raw sensor features provided by a stream description in initdata).  
% DTableActual is the table of physically available channels.
% DTableVirtual is the one that repos_loaddata() can provide, but at least DTableActual.
% 
% See also: repos_findsensorsforsystem
% 
% Copyright 2006-2008 Oliver Amft

DTableActual = [];  DTableVirtual = [];

if ~iscell(Systems), Systems = {Systems}; end;

for sys = 1:length(Systems)
    DTable = repos_getfield(Repository, Partindex(1), 'Assoc', Systems{sys});
    
    DTableVirtual = [ DTableVirtual, DTable ];
    
    tmp = repos_getfield(Repository, Partindex(1), 'AssocActual', Systems{sys}, 0);
    if isempty(tmp), tmp = DTable; end;
    
    DTableActual = [ DTableActual, tmp ];
end;
