function [foundsystems indices] = repos_getsysfromsensor(Repository, Partindex, sensors)
% function [foundsystems indices] = repos_getsysfromsensor(Repository, Partindex, sensors)
%
% Return cell list of systems for a given set of sensors.
% WARNING: Sensors names must be unique over all systems.
%
% Example:
% repos_getsysfromsensor(Repository, 101, 'RSCM2')
%         ans = 'EMG'
% 
% See also: repos_getsysindex, repos_getsystems, repos_findsensorsforsystem
% 
% Copyright 2007 Oliver Amft

systems = repos_getsystems(Repository, Partindex);
if ~iscell(sensors), sensors = {sensors}; end;

foundsystems = {}; indices = [];
for s = 1:length(sensors)
    % scan systems
    for sys = 1:length(systems)
        index = repos_findassoc(Repository, Partindex, sensors{s}, systems{sys});
        if (index), found = 1; break; end;
        found  = 0;
    end;

    % found system for the sensor, add it to the indices list
    if (found)
        foundsystems = {foundsystems{:} systems{sys}};
        indices = [ indices row(index) ];
    else
        foundsystems = {foundsystems{:} []};
        %indices = [indices 0];
		fprintf('\n%s: WARNING: Sensor ''%s'' was not found.', mfilename, sensors{s});
		fprintf('\n%s: Check input: %s', mfilename, cell2str(sensors, ', '));
    end;
end;
if isempty(indices), foundsystems = []; end;
% if (max(indices)==0), foundsystems = []; end;