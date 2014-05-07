function [fh figelements] = prmetrics_plotbars(mode, figelements, varargin)
% function [fh figelements] = prmetrics_plotbars(mode, figelements, varargin)
%
% create PR performance metric bar graphs
%
% mode: 'laprint', 'print', 'view'
%
% figelements.fhandle
% figelements.hbars
% figelements.plotfields
% figelements.legend
% figelements.label
% figelements.title
% figelements.file
% figelements.axislabel

if (~isfield(figelements, 'filename')), figelements.filename = ''; end;
if (~isfield(figelements, 'hbars')), figelements.hbars = true; end;
if (~isfield(figelements, 'axislabel')), figelements.axislabel = 'Performance'; end;

if ~isfield(figelements, 'fhandle')
    figelements.fhandle = figure('visible', 'on');
end;
fh = figelements.fhandle;
if (~isfield(figelements, 'plotfields'))
    figelements.plotfields = {'precision', 'recall'};
    figelements.legend = {'Precision', 'Recall'};
end;

cmap=gray(max(size(figelements.plotfields))+2);

% varargin{x} may contain a list of metrics
Ys = [];
if strcmpi(figelements.plotfields{1}, 'LIST')
	Ys = varargin{1};
else
	for cf = 1:max(size(varargin))
		for f = 1:length(figelements.plotfields)
			Ys = [Ys col(prmetrics_getfields(varargin{cf}, figelements.plotfields{f}))];
		end;
	end;
end;


if figelements.hbars
    Ys = flipud(Ys); % revert order
end;

figure(fh); hold on; % axis square;

% values in cols of one row will be grouped together
% if there is just one column/row grouping makes no sense
if min(size(Ys)) > 1
    if figelements.hbars   
        bh = barh(Ys, 'group');      
        ylim([0 max(size(Ys))+1]);
    else
        bh = bar(Ys, 'group');  
        xlim([0 max(size(Ys))+1]);
    end;
    
    % bar coloring
    for f = 1:length(bh)
        set(bh(f), 'FaceColor', cmap(f+1,:));
    end;
else
    for f = 1:length(Ys)
        if figelements.hbars  
            bh(f) = barh(f, Ys(f), 0.8); 
            ylim([0 max(size(Ys))+1]);
        else
            bh(f) = bar(f, Ys(f), 0.8);  
            xlim([0 max(size(Ys))+1]);
        end;
    end;
    
    % bar coloring
    for f = 1:length(bh)
        set(bh(f), 'FaceColor', cmap(1+1,:));
    end;
end;

if figelements.hbars
    %Ys = flipud(Ys);
    xlim([0 1.01]);
else
    ylim([0 1.01]);
end;



% styling
if figelements.hbars
    plotfmt(fh, 'xl', figelements.axislabel);
    % OAM REVISIT
    % This would make number labels in increasing order (diagram style)
    plotfmt(fh, 'yt', 1:max(size(Ys)));
    if isfield(figelements, 'labeltext') plotfmt(fh, 'ytl', fliplr(figelements.labeltext) ); end;

    if isfield(figelements, 'label') plotfmt(fh, 'yl', figelements.label); end;

    plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
else
    plotfmt(fh, 'yl', figelements.axislabel);
    plotfmt(fh, 'xt', 1:max(size(Ys)));

    if isfield(figelements, 'label')
        plotfmt(fh, 'xl', figelements.label);
    end;

    plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);

    if isfield(figelements, 'labeltext') plotfmt(fh, 'xtl', figelements.labeltext ); end;
end; % if figelements.hbars

if isfield(figelements, 'legend')
    plotfmt(fh, 'le', figelements.legend);
    legend('Location', 'SouthWest');
end;
plotfmt(fh, 'gd', 'off', 'box', 'on');



switch lower(mode)
    case 'laprint'
        %plotfmt(fh, 'lapr', figelements.filename);
    case 'print'
        if isfield(figelements, 'title') plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'fs', 14);
        if isfield(figelements, 'file') plotfmt(fh, 'pr', figelements.file); end;
    otherwise
        % for viewing only
        if isfield(figelements, 'title') plotfmt(fh, 'ti', figelements.title); end;
        plotfmt(fh, 'gd', 'on', 'fs', 14);
end;

