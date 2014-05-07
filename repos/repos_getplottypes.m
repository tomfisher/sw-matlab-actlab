function [plottypes found] = repos_getplottypes(Repository, Partindex, varargin)
% function [plottypes found] = repos_getplottypes(Repository, Partindex, varargin)
%
% Retrieve plot type fields (from MARKER labeling file).
%
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getpartsize, repos_getlabellist, repos_getclasses
% 
% Copyright 2008-2009 Oliver Amft

verbose = process_options(varargin, 'verbose', 1);

[filename detected] = repos_findlabelfile(Repository, Partindex);
[part_markerfile detected] = marker_load_markerfile(filename, 0);

if isempty(part_markerfile) || ~strmatch('plottypes', detected, 'exact')
    found = false;
    if (verbose), fprintf('\n%s: No plottype information found for part %u.', mfilename, Partindex); end;
    plottypes = repos_getsystems(Repository, Partindex);
    if (verbose), fprintf('\n%s: Using default: %s.', mfilename, cell2str(plottypes)); end;
else
    plottypes = part_markerfile.plottypes;
    found = true;
end;

