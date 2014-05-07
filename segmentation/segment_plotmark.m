function ph = segment_plotmark(data, SegTS, varargin)
% segment_plotmark: plot segment marker in current figure
%
% main modes (typical calling examples):
% segment_plotmark(data, SegTS);                Plot mode (all default)
% segment_plotmark(data, SegTS, line);          Vertical line mode
% segment_plotmark(data, SegTS, 'plotall');     Plot start&end points
% segment_plotmark(data, SegTS, 'fill');        Mark segments using texture
% segment_plotmark(data, SegTS, 'gap');         Mark gap between segments
% segment_plotmark(data, SegTS, 'segment');     Horizontal line mode
% segment_plotmark(data, SegTS, 'position');    Segment position mode
% segment_plotmark(data, SegTS, 'similarity');  Similarity mode
%
% parameters:
% segment_plotmark(data, SegTS, [mode], 'yrange', [<yrange_min> <yrange_max>]);
% segment_plotmark(data, SegTS, [mode], 'style', '<color><marker>');
% segment_plotmark(data, SegTS, [mode], 'width', <linethickness>);
% segment_plotmark(data, SegTS, [mode], 'xscale', <max_xlength>);
% segment_plotmark(data, SegTS, [mode], 'label', <none/inside/outside>);
%
% examples:
%
% segment markers only, at height 1, no brackets, thickness 5, x scaling to 2e4:
% ylim([0 1]); xlim([0 1]); ...
% segment_plotmark(0, [1 3; 5 7], 'segment', 'yr', [1 1], 'width', 5, 'xscale', 2e4);
%
% Copyright 2006 Oliver Amft

if iscell(SegTS), SegTS = SegTS{1}; end;
if (isempty(SegTS)), return; end;

ph = 0;  % TODO: should be set for each plot mode

arg = 1; style = 'rx';
range = 2;
method = 'plot';
plwidth = 0.5;
xscale = 1;
yrange = ylim;
label = 'none';

while (size(varargin,2) >= arg)
    switch varargin{arg}
        case {'line'}
            method = 'line';
            range = 1:2;
            style = 'r--';
        case {'fill', 'mark'}
            method = 'fill';
            range = 1;
        case 'foll'
            method = 'foll';
            range = 1;
			
        case {'gaps', 'gap'}
            method = 'gap';
            range = 1;
            style = 'k';
        case {'plotall'}
            method = 'plot';
            range = 1:2;
        case {'plotend', 'plote'}
            method = 'plot';
            range = 2;
        case {'plotbeg', 'plotb'}
            method = 'plot';
            range = 1;
        case {'segment'}
            method = 'segment';
            style = 'k-';
            range = 1;
        case {'position'}
            method = 'position';
            style = 'k-';
            range = 1;
        case {'similarity'}
            method = 'similarity';
            style = 'k-';
            range = 1;
            yval = varargin{arg+1};
            arg = arg + 1;

        case {'yrange', 'yr'}
            yrange = varargin{arg+1};
            arg = arg + 1;
        case {'style'}
            style = varargin{arg+1};
            arg = arg + 1;
        case {'width'}
            plwidth = varargin{arg+1};
            arg = arg + 1;
        case {'xscale'}
            xscale = varargin{arg+1};
            arg = arg + 1;
        case {'label'}
            label = varargin{arg+1};
            arg = arg + 1;
        case {'pcolor'}
            pcolor = varargin{arg+1};
            arg = arg + 1;
    end;
    arg = arg + 1;
end;

if (exist('pcolor','var')~=1), pcolor = char(style(1)); end;

pltype = char(style(2:end));
% xscale_refsize = 0.001;

if isempty(data), data = 1:SegTS(end,2); end;
data = data ./ xscale;


% plot first segment start
if (strcmp(method, 'plot') && (range == 2)), plot(SegTS(1,1), data(SegTS(1,1)), style); end;

% plot now
for seg = 1:size(SegTS,1)
    if (SegTS(seg,1)<=length(data))
        SegTS_xscaled = SegTS(seg,1:2)/xscale;
%         SegTS_rxscaled = [SegTS_xscaled(1) SegTS_xscaled(2)+((xscale/xscale_refsize)/xscale)];

        switch lower(method)
            case 'line'
                for i = range
                    line([SegTS(seg,i) SegTS(seg,i)], yrange, ...
                        'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                end; % for i = range
            case {'plot'}
                for i = range
                    plot(SegTS(seg,i), data(SegTS(seg,i)), ...
                        'color', pcolor, 'marker', pltype, 'linewidth', plwidth);
					%'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                end; % for i = range

            case {'fill'}
                ph = fill([SegTS(seg,1) SegTS(seg,1) SegTS(seg,2) SegTS(seg,2)], ...
                    [yrange(1) yrange(2) yrange(2) yrange(1)], pcolor, 'FaceAlpha', 0.3);
                xsize = SegTS(seg,2)-SegTS(seg,1); ysize = yrange(2)-yrange(1);
				
			case 'foll'  % fill (see above) without transparency
                ph = fill([SegTS(seg,1) SegTS(seg,1) SegTS(seg,2) SegTS(seg,2)], ...
                    [yrange(1) yrange(2) yrange(2) yrange(1)], pcolor);
                xsize = SegTS(seg,2)-SegTS(seg,1); ysize = yrange(2)-yrange(1);
				

            case {'gap'}
                switch (seg)
                    case 1
                        fill([0 0 SegTS(seg,1)-1 SegTS(seg,1)-1], ...
                            [yrange(1) yrange(2) yrange(2) yrange(1)], pcolor, 'FaceAlpha', 0.3);
                        fill([SegTS(seg,2)+1 SegTS(seg,2)+1 SegTS(seg+1,1)-1 SegTS(seg+1,1)-1], ...
                            [yrange(1) yrange(2) yrange(2) yrange(1)], pcolor, 'FaceAlpha', 0.3);
                    case size(SegTS,1)
                        fill([SegTS(seg,2)+1 SegTS(seg,2)+1 length(data) length(data)], ...
                            [yrange(1) yrange(2) yrange(2) yrange(1)], pcolor, 'FaceAlpha', 0.3);
                    otherwise
                        fill([SegTS(seg,2)+1 SegTS(seg,2)+1 SegTS(seg+1,1)-1 SegTS(seg+1,1)-1], ...
                            [yrange(1) yrange(2) yrange(2) yrange(1)], pcolor, 'FaceAlpha', 0.3);
                end; % switch (seg)

            case {'segment', 'position', 'seglist'}  % draws rect-curve
                if (strcmp(method, 'position'))  % draws rect-curve
                    switch (seg)
                        case 1
                            line([0 SegTS_xscaled(1)], [yrange(1) yrange(1)], ...
                                'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                        case size(SegTS,1)
                            line([SegTS(seg-1,2)/xscale SegTS_xscaled(1)], [yrange(1) yrange(1)], ...
                                'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                            line([SegTS_xscaled(2) length(data)/xscale], [yrange(1) yrange(1)], ...
                                'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                        otherwise
                            line([SegTS(seg-1,2)/xscale SegTS_xscaled(1)], [yrange(1) yrange(1)], ...
                                'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                    end; % switch (seg)
                end; % if (strcmp(method, 'position'))
                
                if (strcmp(method, 'seglist'))  % draws line at y-pos depending on class
                    yrange = repmat(SegTS(seg,4), 1,2);
                    line(SegTS_xscaled, yrange, ...
                        'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                else
                    
                line([SegTS_xscaled(1) SegTS_xscaled(1)], yrange, ...
                    'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                % adapt size if segment too short to be visible
%                 if ((SegTS_xscaled(2)-SegTS_xscaled(1)) < xscale_refsize)
%                     disp('special');
%                     line([SegTS_xscaled(1) SegTS_xscaled(2)+xscale_refsize], [yrange(2) yrange(2)], ...
%                         'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
%                     line([SegTS_xscaled(2)+xscale_refsize SegTS_xscaled(2)+xscale_refsize], yrange, ...
%                         'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
%                 else
                    line(SegTS_xscaled, [yrange(2) yrange(2)], ...
                        'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
                    line([SegTS_xscaled(2) SegTS_xscaled(2)], yrange, ...
                        'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);
%                 end;
                end;
                
            case {'similarity'}
                line([SegTS(seg,1) SegTS(seg,2)], [yval(seg) yval(seg)], ...
                    'color', pcolor, 'linestyle', pltype, 'linewidth', plwidth);

            otherwise
                error(['Oops, method ' lower(method) ' not understood, exiting.']);
        end; % switch lower(method)
        
        switch lower(label)
            case 'none'
            case 'index'
                text(SegTS(seg,1)+0.1*xsize, yrange(1)+0.05*ysize, ['S#' mat2str(seg)], 'Clipping', 'on');
                text(SegTS(seg,1)+0.1*xsize, yrange(2)-0.05*ysize, ['S#' mat2str(seg)], 'Clipping', 'on');
            otherwise
                text(SegTS(seg,1)+0.1*xsize, yrange(1)+0.05*ysize, label, 'Clipping', 'on');
                text(SegTS(seg,1)+0.1*xsize, yrange(2)-0.05*ysize, label, 'Clipping', 'on');
        end;                

    end; % if ((SegTS(seg,i)<=length(data)) || (data == 0))
end; % seg
