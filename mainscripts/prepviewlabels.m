function viewlabels = prepviewlabels(Repository, Partlist, Partindex, labellist, varargin)
% function viewlabels = prepviewlabels(Repository, Partlist, Partindex, labellist, varargin)
%
% Adapt view labels for Marker display
% 
% Copyright 2008 Oliver Amft

if ~any(Partlist == Partindex), error('Could not find Partindex in Partlist.'); end;

[partoffsets MapClassSpec verbose] = process_options(varargin, ...
	'partoffsets', repos_getpartsize(Repository, Partlist, 'OffsetMode', true), ...
	'MapClassSpec', [], 'verbose', 0);

if (verbose)
	fprintf('\n%s: Partlist=%s', mfilename, mat2str(Partlist));
	fprintf('\n%s: Partindex=%s', mfilename, mat2str(Partindex));
	fprintf('\n%s: labellist size %s', mfilename, mat2str(size(labellist)));
end;

[dummy labellist] = segment_mergespec2mapspec(MapClassSpec, labellist);

viewlabels = repos_findlabelsforpart(segment_sort(labellist), find(Partlist==Partindex), partoffsets, 'remove');
