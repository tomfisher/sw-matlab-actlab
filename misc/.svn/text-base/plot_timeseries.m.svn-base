function [fh lhs] = plot_timeseries(datacols, varargin)
% function [fh lhs] = plot_timeseries(datacols, varargin)
% 
% plot time series for bw reprints; datacols should contain time series in columns.
% 
% See also: plot_timeseries, prmetrics_plotpr, plotbars
% 
% Copyright 2008 Oliver Amft

[fh viewmode cmap title] = process_options(varargin, ...
	'fh', [], 'viewmode', 'view', 'cmap', gray(size(datacols,2)+1), 'title', '' );

if isempty(fh), fh = figure; else figure(fh); end;

lhs = zeros(size(datacols,2),1);
if size(datacols,2)==1,
	lhs = plot(datacols, 'color', cmap(1,:), 'LineWidth', 1);
else
	for c = 1:size(datacols,2)
		% plot it!
		lhs(c) = plot(datacols(:,c), 'color', cmap(c,:), 'LineWidth', 1); hold('on');
	end;
end;

% plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
% plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
plotfmt(fh, 'lm', {'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h'}, 'mec', num2cell(cmap,2), 'mfc', num2cell(cmap,2)); %, 'ms', 8);
plotfmt(fh, 'ls', '--');
plotfmt(fh, 'gd', 'off', 'box', 'on');

switch lower(viewmode)
	case 'laprint'
		%plotfmt(fh, 'lapr', figelements.filename);
	otherwise
		% for viewing only
		if ~isempty(title), plotfmt(fh, 'ti', title); end;
		plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14);
end;

