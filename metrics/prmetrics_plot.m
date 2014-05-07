function [fh figelements] = prmetrics_plot(mode, figelements, prmetrics)
% function [fh figelements] = prmetrics_plot(mode, figelements, prmetrics)
%
% create performance metric graph
%
% mode: 'laprint', 'print', 'view'
%
% figelements.fhandle
% figelements.plotfields
% figelements.legend
% figelements.title
% figelements.file
% 
% Copyright 2007 Oliver Amft

if ~isfield(figelements, 'fhandle') 
    figelements.fhandle = figure('visible', 'on');
end;
fh = figelements.fhandle;

if ~isfield(figelements, 'plotfields') 
    figelements.plotfields = {'precision', 'recall'};
end;
if ~isfield(figelements, 'legend') 
    figelements.legend = figelements.plotfields;
end;

cmap=gray(max(size(figelements.plotfields))+1);

figure(fh); hold on; 
% xlim([0 1.01]); 
ylim([0 1.01]);
% axis square; 
for cf = 1:max(size(figelements.plotfields))
    vals = prmetrics_getfields(prmetrics, figelements.plotfields{cf});
    
    plot(vals, 'color', cmap(cf,:), 'LineWidth', 1);
end; % for cf

plotfmt(fh, 'xl', 'Indices', 'yl', 'Performance');
if isfield(figelements, 'legend') 
    plotfmt(fh, 'le', figelements.legend); 
    legend('Location', 'SouthWest');
end;
% plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
plotfmt(fh, 'lm', {'o', '^', 'd', '*'}, 'mec', num2cell(cmap,2), 'mfc', num2cell(cmap,2)); %, 'ms', 8);
plotfmt(fh, 'ls', '--');
plotfmt(fh, 'gd', 'off', 'box', 'on');

switch lower(mode)
    case 'laprint'
        plotfmt(fh, 'lapr');
    case 'print'
        if isfield(figelements, 'title') plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
        if isfield(figelements, 'file') plotfmt(fh, 'pr', figelements.file); end;
    otherwise
        % for viewing only
        if isfield(figelements, 'title') plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
end;

