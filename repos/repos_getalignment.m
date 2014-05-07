function [alignshift alignsps alignrate plottypes found] = repos_getalignment(Repository, Partindex, varargin)
% function [alignshift alignsps alignrate plottypes found] = repos_getalignment(Repository, Partindex, varargin)
%
% Retrieve valid signal range (from MARKER labeling file).
% 
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getpartsize, repos_getlabellist, repos_getclasses
% 
% Superseds cla_getalignment.
% 
% Copyright 2006-2009 Oliver Amft

[AdaptShift SampleRate, verbose] = process_options(varargin, ...
    'adaptshift', false, 'SampleRate', 0, 'verbose', 0);

plottypes = repos_getplottypes(Repository, Partindex, 'verbose', verbose);

[filename detected] = repos_findlabelfile(Repository, Partindex);
[part_markerfile detected] = marker_load_markerfile(filename, 0);

if isempty(part_markerfile) || ~strmatch('alignshift', detected, 'exact') || ~strmatch('alignsps', detected, 'exact') 
    found = false;
    fprintf('\n%s: No alignment found for part %u.', mfilename, Partindex);
    alignshift = repmat(0, 1, length(repos_getsystems(Repository, Partindex)));
    alignsps = repmat(0, 1, length(repos_getsystems(Repository, Partindex)));
else
    found = true;
    alignshift = part_markerfile.alignshift;
    alignsps = part_markerfile.alignsps;
end;


markersps = repos_getmarkersps(Repository, Partindex);
alignrate = (markersps+alignsps)./markersps;


% alignshift must be adapted by alignrate when used. Since MARKER requires
% these values individually don't do this here.
if AdaptShift
    alignshift = ceil(alignshift .* alignrate);
end;


if (SampleRate > 0) && (found)
    %error('Resampling not supported.');
    newsps = repmat(SampleRate, 1, length(markersps));
    fresample = newsps./markersps;
    if (verbose), fprintf('\n%s: Resampling to %.5f...', mfilename, fresample); end;

    alignshift = ceil(alignshift .* fresample);
    alignsps = alignsps .* fresample;
    alignrate = alignrate .* fresample;
end;
