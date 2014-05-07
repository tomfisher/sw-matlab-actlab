function filename = spot_isfile(SpotType, SimSetID, spotclass)
% function filename = spot_isfile(SpotType, SimSetID, spotclass)
% 
% Creates spot file name and checks if exist. Param spotclass can be
% omitted, then first hit is returned.
% 
% Cpoyright 2008 Oliver Amft

switch upper(SpotType)
	case 'SIMSMAX'
		SpotType = 'SIMS';
end;

if (~exist('spotclass','var')) || isempty(spotclass) || length(spotclass)>1
	filename = repos_makefilename([], 'prefix', SpotType, 'indices', '*', 'suffix', SimSetID, 'subdir', 'SPOT');
else
	filename = repos_makefilename([], 'prefix', SpotType, 'indices', spotclass, 'suffix', SimSetID, 'subdir', 'SPOT');
end;

filename = findfiles(filename, 'notfoundmode', 'empty', 'returnmode', 'first');