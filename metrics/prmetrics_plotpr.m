function [fh figelements] = prmetrics_plotpr(mode, figelements, varargin)
% function [fh figelements] = prmetrics_plotpr(mode, figelements, varargin)
%
% create PR performance metric graphs
%
% mode: 'laprint', 'print', 'view'
%
% figelements.fhandle
% figelements.legend
% figelements.title
% figelements.file
% 
% Copyright 2007 Oliver Amft

warning('Superseeded by prmetrics_plotpr2.m, use this instead.');

% OAM REVISIT: Check max nr of lines!
if ~isfield(figelements, 'fhandle') 
    figelements.fhandle = figure('visible', 'on');
end;
fh = figelements.fhandle;


% varargin{x} may contain a list of metrics use here to make a sweep plot
switch lower(mode)
	case 'view2'
		cmap=jet(length(varargin)+1);
	otherwise
		cmap=gray(length(varargin)+1);
end;

figure(fh); hold on; xlim([0 1.01]); ylim([0 1.01]);
% axis square; 
for cf = 1:max(size(varargin))
    if iscell(varargin{cf}), vin = varargin{cf}{1}; else vin = varargin{cf}; end;

    if 1
        thismetric = prmetrics_prunepr(vin, 'Enable', [1 2 5 8], 'SupportPDelta', 0.05);
%         thismetric = prmetrics_prunepr(vin, 'Enable', [1 2 5 8], 'SupportPDelta', 0.02);        
        if isempty(thismetric), thismetric = vin; fprintf('\n%s: Empty metrics (after pruning).', mfilename); end;
    else
        thismetric = vin;
    end;

	
    [precision recall] = prmetrics_getpr(prmetrics_sort(thismetric));
	%plotdata = sortm([recall precision], 'mode', 'hierarchy');
	if isbetween(precision(1), [0.1 1]) && isbetween(recall(1), [0.1 0.99])
		fprintf('\n%s: Added PR point: 1,0.', mfilename);
		precision = [1; precision];  recall = [0; recall];
	end;
	
	% plot it!
	plot(recall, precision, 'color', cmap(cf,:), 'LineWidth', 1);
end;

plotfmt(fh, 'xl', 'Recall', 'yl', 'Precision');
if isfield(figelements, 'legend') 
    plotfmt(fh, 'le', figelements.legend); 
    legend('Location', 'SouthWest');
end;
plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
LineMarkers = { 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h'};
plotfmt(fh, 'lm', LineMarkers, 'mec', num2cell(cmap,2), 'mfc', num2cell(cmap,2)); %, 'ms', 8);
plotfmt(fh, 'ls', '--');
if isfield(figelements, 'nolines') 
    plotfmt(1, 'ls', 'none');
end;
plotfmt(fh, 'gd', 'off', 'box', 'on');

if isfield(figelements, 'diagline')
    line([0 1], [1 0], 'color', 'k');
end;

switch lower(mode)
    case 'laprint'
        %plotfmt(fh, 'lapr', figelements.filename);
    case 'print'
        if isfield(figelements, 'title'), plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
        if isfield(figelements, 'file'), plotfmt(fh, 'pr', figelements.file); end;
    otherwise
        % for viewing only
        if isfield(figelements, 'title'), plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
end;

