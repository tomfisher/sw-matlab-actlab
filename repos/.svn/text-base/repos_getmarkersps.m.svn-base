function [markersps plottypes found] = repos_getmarkersps(Repository, Partindex, varargin)
% function [markersps plottypes found] = repos_getmarkersps(Repository, Partindex, varargin)
%
% Retrieve sampling frequency from MARKER. Superseds cla_getmarkersps.
% 
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getpartsize, repos_getlabellist, repos_getclasses
% 
% Copyright 2006-2009 Oliver Amft

[singlesps, verbose] = process_options(varargin, ...
    'singlesps', false, 'verbose', 0);

plottypes = repos_getplottypes(Repository, Partindex, 'verbose', verbose);

[filename detected] = repos_findlabelfile(Repository, Partindex);
[part_markerfile detected] = marker_load_markerfile(filename, 0);

if isempty(part_markerfile) || ~strmatch('markersps', detected, 'exact')
    found = false;
    if (verbose), fprintf('\n%s: No markersps found for Part %u.', mfilename, Partindex); end;
    markersps = repmat( repos_getfield(Repository, Partindex, 'SFrq'), ...
        1, length(repos_getsystems(Repository, Partindex)) );  % Repository.RepEntries(Partindex).Systems
else
    markersps =part_markerfile.markersps;
    found = true;
end;

if isempty(markersps), error('SFrq not found in Repository entry %u', Partindex(1)); end;

if singlesps
    markersps = markersps(1);
end;