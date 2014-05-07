function matchpos = findtoolboxpath(toolboxstring)
% function matchpos = findtoolboxpath(toolboxstring)
% 
% Find toolbox entries in Matlab search path

% Copyright 2008 Oliver Amft

% fetch current path settings
currpaths = str2cellf(path, pathsep);

matchpos = find(~isemptycell(strfind(currpaths, toolboxstring)));

