function mhandles = plotmarker(fh, X, Y, varargin)
% function mhandles = plotmarker(fh, X, Y, varargin)
% 
% Plot markers only, no lines. All options are passed on to Matlab plot.
% 
% Example:
% 
% mh1 = plotmarker(fh, x, y, 'Marker', '+', 'MarkerSize', 12, 'LineWidth', 4, ...
%   'MarkerFaceColor', [1 1 1], 'MarkerEdgeColor', [1 0 0], 'Color', 'w');
% 
% See also: prmetrics_plotpr, plotbars, plot_timeseries
% 
% Copyright 2008 Oliver Amft

if isempty(fh), figure; else figure(fh);  end;

% remember hold state
hstate = ishold; hold('on');

% plot every point individually (to avoid lines)
mhandles = zeros(length(X),1);
for i = 1:length(X)
	mhandles = plot(X(i), Y(i), 'Marker', '+', 'LineWidth', 4, 'MarkerSize', 14,   varargin{:});
end;

% reset hold state
if hstate, hold('on'); else hold('off'); end;