function fh = plotbars(obj, varargin)
% function fh = plotbars(obj, varargin)
%
% create performance metric bar graph
%
% Optional parameters:
%
% ViewMode: 'laprint', 'print', 'view'
%
% conf.visible
% conf.hbars
% conf.plotfields
% conf.legend
% conf.label
% conf.title
% conf.file
% conf.axislabel
% conf.labeltext
% 
% Copyright 2007 Oliver Amft

[ViewMode fh conf.visible conf.hbars BarMode conf.plotfields ...
	conf.legend conf.title conf.file conf.axislabel ...
	conf.labeltext conf.label conf.errormin conf.errormax ...
	cmap colormode barpos SetTick] = process_options(varargin, ...
	'ViewMode', 'view', 'fh', [], 'visible', true, 'hbars', true, 'BarMode', 'group', ...
	'plotfields', {'precision', 'recall'}, ...
	'legend', '', 'title', '', 'file', 'plotbarspic.jpg', 'axislabel', 'Performance', ...
	'labeltext', '', 'label', '',  'errormin', [], 'errormax', [], 'cmap', [], 'colormode', '', ...
	'barpos', [], 'settick', true );



% open up a figure if no handle supplied
if isempty(fh)
	if (conf.visible), fh = figure('visible', 'on'); else fh = figure('visible', 'off'); end;
end;




% obj{x} may contain a list of metrics or a matrix
Ys = [];
if strcmpi(conf.plotfields{1}, 'LIST')
	Ys = obj;
else
	for cf = 1:max(size(obj))
		for f = 1:length(conf.plotfields)
			Ys = [Ys col(prmetrics_getfields(obj{cf}, conf.plotfields{f}))];
		end;
	end;
end;


if conf.hbars
	Ys = flipud(Ys); % revert order
end;

if isempty(barpos), barpos = 1:size(Ys,1); end;
if length(barpos)<size(Ys,1), barpos = (0:barpos:barpos*(size(Ys,1)-1))+1; end;


%figure(fh);
hold on; % axis square;


% if there is just one column/row grouping makes no sense
if min(size(Ys)) <= 1, BarMode = 'single'; end;

switch lower(BarMode)
	case {'group', 'grouped'}
		% values in cols of one row will be grouped together
		if conf.hbars
			bh = barh(barpos, Ys, 'group');
			%ylim([0 max(size(Ys))+1]);
			xlim([min(barpos)-1 max(barpos)+1]);			
		else
			bh = bar(barpos, Ys, 'group');
			%xlim([0 max(size(Ys))+1]);
			xlim([min(barpos)-1 max(barpos)+1]);			
		end;

		% bar coloring
		if isempty(cmap), cmap=gray(length(bh)+2);  cmap([1 end],:) = []; end;
		colormode = 'different';

	case {'stack', 'stacked'}
		if conf.hbars
			bh = barh(barpos, Ys, 'stack');
			xlim([min(barpos)-1 max(barpos)+1]);
		else
			bh = bar(barpos, Ys, 'stack');
			xlim([min(barpos)-1 max(barpos)+1]);
		end;

		% bar coloring
		if isempty(cmap), cmap=gray(length(bh)+2); cmap([1 end],:) = []; end;
		colormode = 'different';
		

	case 'single'
		% non-grouped bars
		for f = 1:length(Ys)
			if conf.hbars
				bh(f) = barh(barpos(f), Ys(f), 0.8);
				xlim([min(barpos)-1 max(barpos)+1]);
			else
				bh(f) = bar(barpos(f), Ys(f), 0.8);
				%xlim([0 max(size(Ys))+1]);
				xlim([min(barpos)-1 max(barpos)+1]);
			end;
		end;

		% bar coloring
		% 	if isempty(cmap),  cmap=gray(max(size(conf.plotfields))+2);  end;
		if isempty(colormode), colormode = 'equal'; end;
        if isempty(cmap),
            switch lower(colormode)
                case 'equal'
                    cmap=gray(1+2); cmap([1 end],:) = [];
                case 'different'
                    cmap=gray(f+2); cmap([1 end],:) = [];
            end;
        end;


end;


% bar coloring
switch lower(colormode)
	case 'different'
		for f = 1:length(bh)
			set(bh(f), 'FaceColor', cmap(f,:));
		end;
	case 'equal'
		for f = 1:length(bh)
			set(bh(f), 'FaceColor', cmap(1,:));
		end;
end;


if conf.hbars
	%Ys = flipud(Ys);
	xlim([0 1.01]);
else
	ylim([0 1.01]);
end;

if (~isempty(conf.errormin)) || (~isempty(conf.errormax))
	if conf.hbars
		error('Errorbars not supported in horizontal mode.');
	else
		% errorbar works for vertical bars only
		% hack from: bar.m, barweb.m, barerrorbar.m
		errbarlwidth = 2;
		errbarlcolor = [0.3 0.3 0.3];
		numgroups = size(Ys,1); % bar sets
		numbars = size(Ys,2);  % bars per group/set
		groupwidth = min(0.8, numbars/(numbars+1.5));
		barwidth = get(bh(1), 'BarWidth');
		errlinewidth = 0.1*barwidth; % size of upper/lower horz lines
		for i = 1:numbars
			%x = (1:numgroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*numbars);
            x = barpos;
			nodiff = (conf.errormax-conf.errormin)==0;
			if any(nodiff)   % ignore errorbars where there is no diff
				x(nodiff) = [];  conf.errormax(nodiff) = []; conf.errormin(nodiff) = [];  numgroups = numgroups-sum(nodiff);
				fprintf('\n%s: WARNING: Ignored errorbars for bar(s) %s since no difference was encountered.', mfilename, mat2str(find(nodiff)));
			end;
			%eh(i) = errorbar(x, Ys(:,i), Ys(:,i)-conf.errormin(:,i), conf.errormax(:,i)-Ys(:,i), 'k', 'linestyle', 'none');
			%line(x(1), [conf.errormax(1,1) conf.errormin(1,1)]);
			lh = line(repmat(x,2,1), [conf.errormax(:,1) conf.errormin(:,1)]'); % one line per column
			llh = line(repmat(x,2,1)+repmat([-errlinewidth; +errlinewidth], 1, numgroups), repmat(conf.errormin(:,1)',2,1) );
			ulh = line(repmat(x,2,1)+repmat([-errlinewidth; +errlinewidth], 1, numgroups), repmat(conf.errormax(:,1)',2,1) );
			set(lh, 'LineWidth', errbarlwidth, 'Color', errbarlcolor);
			set(llh, 'LineWidth', errbarlwidth, 'Color', errbarlcolor); set(ulh, 'LineWidth', errbarlwidth, 'Color', errbarlcolor);
		end;
	end;
end;


% styling
plotfmt(fh, 'gd', 'off', 'box', 'on');
if conf.hbars
	plotfmt(fh, 'xl', conf.axislabel);
	plotfmt(fh, 'xg', 'on');
	% OAM REVISIT
	% This would make number labels in increasing order (diagram style)
	plotfmt(fh, 'yt', barpos, 'ytl', fliplr(barpos));  % max(size(Ys)):-1:1

	if (~isempty(conf.labeltext)), plotfmt(fh, 'ytl', fliplr(conf.labeltext) ); end;

	if (~isempty(conf.label)), plotfmt(fh, 'yl', conf.label); end;

	if (SetTick), plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]); end;
else
	plotfmt(fh, 'yl', conf.axislabel);
	plotfmt(fh, 'xt', barpos);
	plotfmt(fh, 'yg', 'on');
	if (~isempty(conf.label))
		plotfmt(fh, 'xl', conf.label);
	end;

	if (SetTick), plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]); end;

	if (~isempty(conf.labeltext)), plotfmt(fh, 'xtl', conf.labeltext ); end;
end; % if conf.hbars

if (~isempty(conf.legend))
	%plotfmt(fh, 'leh', bh, conf.legend);
	legend(bh, conf.legend, 'Location', 'SouthWest');
end;




switch lower(ViewMode)
	case 'laprint'
		plotfmt(fh, 'grid', 'off');
		%plotfmt(fh, 'lapr', conf.file);
	case 'print'
		if (~isempty(conf.title)), plotfmt(fh, 'ti', conf.title); end;
		plotfmt(fh, 'fs', 14);
		if (~isempty(conf.file)), plotfmt(fh, 'prjpg', conf.file); end;
	otherwise
		% for viewing only
		if (~isempty(conf.title)), plotfmt(fh, 'ti', conf.title); end;
		plotfmt(fh, 'fs', 14);
end;

