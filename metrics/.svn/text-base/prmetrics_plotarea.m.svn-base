function figelements = prmetrics_plotarea(mode, figelements, varargin)
% function figelements = prmetrics_plotarea(mode, figelements, varargin)
%
% create PR performance metric graphs
%
% mode: 'laprint', 'print', 'view'
%
% figelements.fhandle
% figelements.legend
% figelements.title
% figelements.file
% figelements.text
% figelements.color
% figelements.plotid
% 
% Superseeded by prmetrics_prplot
% 
% Copyright 2009 Oliver Amft

warning('Superseeded by prmetrics_prplot. Use this instead.');

if ~isfield(figelements, 'fhandle') 
    figelements.fhandle = figure('visible', 'on');
end;
fh = figelements.fhandle;

if (length(varargin)==1)
	obj = varargin{1};
else
	obj = [];
	for cf = 1:length(varargin),  obj(cf) = varargin{cf}; end;
end;

if isfield(figelements, 'color')
	if (size(figelements.color) < length(obj)+1)
		cmap = repmat(figelements.color, length(obj)+1, 1);
	else
		cmap = figelements.color;
	end;
else cmap=gray(length(obj)+1); 
end;

if ~isfield(figelements, 'plotid'), figelements.plotid = 'plotpt'; end;


figure(fh); hold on; xlim([0 1.01]); ylim([0 1.01]);

% axis square; 
for cf = 1:length(obj)    
    [precision recall] = prmetrics_getpr(obj(cf));
    
    %area(recall, precision);
	figelements.ph(cf) = plot(recall, precision, 'LineWidth', 3, 'Color', 'w', 'MarkerSize', 8, 'Marker', '+', ...
		'MarkerFaceColor', cmap(cf, :), 'MarkerEdgeColor', cmap(cf, :), 'DisplayName', figelements.plotid);
	
	% text
	if isfield(figelements, 'text')
		textoffset = 0.002;
		textpos = [recall+textoffset, precision+textoffset]; textalign = {'left', 'bottom'};  % rightwards, above 
		if (precision > 0.95), textpos(2) = precision-textoffset; textalign{2} = 'top'; end;  % below
		if (recall > 0.95), textpos(1) = recall-textoffset; textalign{1} = 'right'; end;  % leftwards

		figelements.th(cf) = text(textpos(1), textpos(2), sprintf('%s', figelements.text{cf}), 'Color', cmap(cf,:)-0.1, ...
			'HorizontalAlignment', textalign{1}, 'VerticalAlignment', textalign{2}, 'tag', ['plottext' num2str(cf)], ...
			'interpreter', 'latex' );
	end;
end;

plotfmt(fh, 'xl', 'Recall', 'yl', 'Precision');
if isfield(figelements, 'legend') 
    plotfmt(fh, 'le', figelements.legend); 
    legend('Location', 'SouthWest');
end;
plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);

plotfmt(fh, 'gd', 'off', 'box', 'on');

switch lower(mode)
    case 'laprint'
        plotfmt(fh, 'lapr');
    case 'print'
        if isfield(figelements, 'title'), plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
        if isfield(figelements, 'file'), plotfmt(fh, 'pr', figelements.file); end;
    otherwise
        % for viewing only
        if isfield(figelements, 'title'), plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14); 
end;

