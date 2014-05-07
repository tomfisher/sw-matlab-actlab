function fh = plotmap(matrix, varargin)
% function fh = plotmap(matrix, varargin)
%
% Create heat map plot
%
% Optional parameters:
% 
% ViewMode: 'laprint', 'print', 'view'
%
% visible
% title
% file
% xlabel, ylabel

% Copyright 2007 Oliver Amft, ETH Zurich

[ViewMode fh visible title file xlabel ylabel rectangelist linewidth cmap clim ShowColorbar setaxis] = process_options(varargin, ...
	'ViewMode', 'view', 'fhandle', [], 'visible', true, ...
	'title', '', 'file', '', 'xlabel', '', 'ylabel', '', 'rectangelist', [], 'linewidth', 5, 'cmap', [], 'clim', [], ...
	'ShowColorbar', true, 'setaxis', 'square');

% open up a figure if no handle supplied
if isempty(fh)
	if (visible), fh = figure('visible', 'on'); else fh = figure('visible', 'off'); end;
end;

%imagesc(matrix, [min(min(matrix,[],1))   max(max(matrix,[],1))]); 
imagesc(matrix);
if (~isempty(clim)), caxis(clim); end;  % imagesc may take this as last param as well

hold on;  axis(setaxis);

if (ShowColorbar), colorbar; end;

% rectange handling
%cmap=lines(size(rectangelist,1)+2);
if isempty(cmap), cmap = diag([1 1 1]); end;
recth = zeros(size(rectangelist,1),1);
for i = 1:size(rectangelist,1)
	recth(i) = rectangle('Position', rectangelist(i,:), 'LineWidth', linewidth, 'EdgeColor', cmap(mod(i,size(cmap,1))+1,:)); % [x y w h]
end;

% styling
plotfmt(fh, 'gd', 'off', 'box', 'on', 'xlabel', xlabel, 'ylabel', ylabel);



switch lower(ViewMode)
    case 'laprint'
        %plotfmt(fh, 'lapr', conf.file);
    case 'print'
        if (~isempty(title)), plotfmt(fh, 'ti', title); end;
        plotfmt(fh, 'fs', 14);
        if (~isempty(file)), plotfmt(fh, 'prjpg', file); end;
    otherwise
        % for viewing only
        if (~isempty(title)), plotfmt(fh, 'ti', title); end;
        plotfmt(fh, 'fs', 14);
end;

