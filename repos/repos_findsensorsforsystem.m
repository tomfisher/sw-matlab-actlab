function [foundsensors indices] = repos_findsensorsforsystem(Repository, Partindex, System, sensorlist)
% function [foundsensors indices] = repos_findsensorsforsystem(Repository, Partindex, System, sensorlist)
% 
% Return sensors for a particular system out of a sensor list
% 
% See also: repos_getsysfromsensor
% 
% Copyright 2009 Oliver Amft

if ~exist('sensorlist', 'var'), sensorlist = repos_getdtable(Repository, Partindex, System); end;

if ~iscell(sensorlist), sensorlist = {sensorlist}; end;
if isemptycell(sensorlist), sensorlist = repos_getdtable(Repository, Partindex, System); end;

DTableVirtual = repos_getdtable(Repository, Partindex, System);
indices = cellstrmatch(sensorlist, DTableVirtual, 'exact', 'ReturnZeros', false);

foundsensors = DTableVirtual(indices);