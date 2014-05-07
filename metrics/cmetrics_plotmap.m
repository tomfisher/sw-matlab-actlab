function fh = cmetrics_plotmap(cmetrics, varargin)
% function fh = cmetrics_plotmap(cmetrics, varargin)
%
% Confusion matrix heat map plot.
% May be used for non-square map plots as well.
%
% Copyright 2006-2009 Oliver Amft
%
% ToDos:
% * create grid/boxes around each field (easier readability)
% * make const scale [0 1]
%
% Plot routine inspired on spy2.m:
% Copyright 2000-11-14, B. Rasmus Anthin.
% Revision 2003-09-15, 2003-09-16.

% OAM REVISIT: Problem with eps printout under 2007b, seems solved with 2009a though
% http://www.mathworks.de/matlabcentral/newsreader/view_thread/248516
% http://www.mathworks.com/support/solutions/en/data/1-2IDNDP/index.html?solution=1-2IDNDP

[ViewMode Title clim AnnotatePlot AnnotateThres] = process_options(varargin, ...
	'ViewMode', 'screen', 'Title', '', 'clim', [0 1], 'AnnotatePlot', false, 'AnnotateThres', 0);

if issquare(cmetrics)
	cstats = cmetrics_mkstats(cmetrics);
end;

fh = figure;

A=real(double(cmetrics));
A(~isfinite(A))=realmin;
A(end+1,end+1)=0;
[xs ys] = size(A);
[X,Y]=meshgrid((1:ys)-.5,(1:xs)-.5);

%surf(X,Y,A); % plot and print problems
%pcolor(A); % x-/y-labels not centered
H=tcolor(X,Y,A(1:xs-1,1:ys-1), 'normal');
%H=tcolor(X,Y,A, 'triangles'); % draws vertexes, cannot use edge coloring
%H=tcolor(X,Y,A, 'corners');

if (~isempty(clim)), caxis(clim); end;

view(2);
axis ij;
if issquare(cmetrics), axis equal; end;
axis tight;
colorbar;

%plotfmt(fh, 'YTick', {}, 'YTickLabel', {0:0.2:1});


if exist('cstats', 'var')
	% assume its a confusion matrix plot
	titlestr = [Title num2str(roundf(cstats.normacc,2))];
	plotfmt(fh, 'yl', 'Actual class', 'xl', 'Predicted class');
else
	titlestr = Title;
end;
plotfmt(fh, 'box', 'on', 'ti', titlestr, 'fs', 14);
set(gca, 'XTick',  get(gca, 'YTick'));

switch lower(ViewMode)
	case {'screen', 'view'}
		cmap = colormap('jet');
	case 'print'
		cmap = flipud(colormap('gray'));
		colormap(cmap);
	otherwise
		error('ViewMode is not supported.')
end;

if AnnotatePlot
    for i = 1:size(cmetrics,2)
        for j = 1:size(cmetrics,1)
            % Find complementary color
            if cmetrics(j,i)>0.5, thiscolor = [1 1 1]; else thiscolor = [0 0 0]; end;
            if cmetrics(j,i) > AnnotateThres
                text(i, j, num2str(cmetrics(j,i), '%.2f'), 'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'Color', thiscolor);
            end;
        end;
    end;
end;
