function figelements = scmetrics_plotroc(mode, figelements, varargin)
% function figelements = scmetrics_plotroc(mode, figelements, varargin)
%
% create ROC performance graphs
%
% mode: 'laprint', 'print', 'view'
%
% figelements.fhandle
% figelements.legend
% figelements.title
% figelements.file
% 
% Copyright 2006 Oliver Amft

if ~isfield(figelements, 'fhandle') 
    figelements.fhandle = figure('visible', 'on');
end;
fh = figelements.fhandle;

nplots = max(size(varargin)); plotmode = 'varargin';
if max(size(varargin{1})) > 1
    nplots = max(size(varargin{1})); plotmode = 'array';
end;
cmap=gray(nplots+1);

figure(fh); hold on; xlim([0 1.01]); ylim([0 1.01]);
% axis square; 
for cf = 1:nplots
    if strcmp(plotmode, 'varargin')
%         fpr = prmetrics_getfields(varargin{cf}, 'fpr');
%         tpr = prmetrics_getfields(varargin{cf}, 'tpr');
        fpr = varargin{cf}.fpr;
        tpr = varargin{cf}.tpr;
    else
%         fpr = prmetrics_getfields(varargin{1}(cf), 'fpr');
%         tpr = prmetrics_getfields(varargin{1}(cf), 'tpr');
        fpr = varargin{1}{cf}.fpr;
        tpr = varargin{1}{cf}.tpr;
    end;
    
    plot(fpr, tpr, 'color', cmap(cf,:), 'LineWidth', 1);
end;

plotfmt(fh, 'xl', 'False positive rate', 'yl', 'True positive rate');
if isfield(figelements, 'legend') 
    plotfmt(fh, 'le', figelements.legend); 
    legend('Location', 'SouthWest');
end;
plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
if isfield(figelements, 'linemarkers')
    plotfmt(fh, 'lm', {'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h'}, 'mec', num2cell(cmap,2), 'mfc', num2cell(cmap,2)); %, 'ms', 8);
end;
plotfmt(fh, 'ls', '--');
if isfield(figelements, 'nolines') 
    plotfmt(1, 'ls', 'none');
end;
plotfmt(fh, 'gd', 'off', 'box', 'on');

if ~isfield(figelements, 'nodiagline')
    line([0 1], [0 1], 'color', 'k',  'Tag', 'helpline');
end;

switch lower(mode)
    case 'laprint'
        %plotfmt(fh, 'lapr');
    case 'print'
        if isfield(figelements, 'title') plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
        if isfield(figelements, 'file') plotfmt(fh, 'pr', figelements.file); end;
    otherwise
        % for viewing only
        if isfield(figelements, 'title') plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14);
        
end;

