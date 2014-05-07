function index = repos_findassoc(Repository, Partindex, sensorstr, system)
% function index = repos_findassoc(Repository, Partindex, sensorstr, system)
%
% Find sensor index by associated string/name
%
% Example:
% repos_findassoc(Repository, 101, 'RSCM2')
%         ans = 2
% repos_findassoc(Repository, 101, 'THRO', 'WAV')
%         ans =  1
% 
% Copyright 2006-2008 Oliver Amft

if ~exist('system', 'var'), system = repos_getsystems(Repository, Partindex,1); end;

%assoc = repos_getfield(Repository, Partindex, 'Assoc', system);
assoc = repos_getdtable(Repository, Partindex, system);  % used by repos_loaddata, needs virtual channels

if iscell(sensorstr)
	index = zeros(1, length(sensorstr));
	for i = 1:length(sensorstr)
        tmp = strmatch(sensorstr{i}, assoc, 'exact');
        if isempty(tmp), 
            % some functions probe through various combinations, hence dont complain
            %warning('repos:findassoc', 'Cannot find the requested sensor %s', sensorstr{i}); 
        else
            index(i) = strmatch(sensorstr{i}, assoc, 'exact'); 
        end;
	end;
else
	% index = find(strcmp(assoc, sensorstr));
	index = strmatch(sensorstr, assoc, 'exact');
    if isempty(index), 
        % some functions probe through various combinations, hence dont complain
        %warning('repos:findassoc', 'Cannot find the requested sensor %s', sensorstr); 
        index = 0; 
    end;
end;