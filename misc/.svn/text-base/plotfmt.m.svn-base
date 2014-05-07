function ret = plotfmt(fh, varargin)
% function ret = plotfmt(fh, varargin)
%
% Formats plots, parameters are non-case-sensitive
%
% Examples:
%  plotfmt(1, 'lc', 'k');                       % black color lines
%  plotfmt(1, 'ls', {'-', '--', ':'});          % individual line style
%  plotfmt(1, 'lw', 2);                         % width 2
%  plotfmt(1, 'fs', 16);                        % text font size 16
%  plotfmt(1, 'prpdf', 'filename');               % save as EPS & PDF
%  plotfmt(1, 'xl', 'Time [a.u.]', 'xtl', {''}); % remove x-ticks
%  plotfmt(1, 'tarr', [.6 .4], [.3 .5], 'My arrow') % plot an arrow
%  plotfmt(1, 'lep', [.15 .13 .3 .2], {'My legend'}) % legend with position
%  plotfmt(2, 'le', {'My legend'})                  % legend w/o position
%
% Color spec:
% r-Red g-Green b-Blue c-Cyan m-Magenta y-Yellow k-Black w-White
%
% Line style spec:
% - Solid line (default) -- Dashed line : Dotted line -. Dash-dot lin
%
% more details: see Matlab help on "LineSpec"
%
% Copyright 2005-2011 Oliver Amft

ret = 0; 
LineMarkers = { 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h'};

arg = 1;
if ~any(isempty(fh)) && any(strcmpi(get(fh,'type'), 'figure')), figure(fh); end;

while arg <= length(varargin)
%for arg=1:2:length(varargin)
    switch lower(varargin{arg})
		case 'fpos'
			% get(fh, 'Position')
			set(fh, 'Position', varargin{arg+1});
			set(fh, 'activepositionproperty', 'outerposition');
        case {'xlabel', 'xl'}
            xlabel(varargin{arg+1});
        case {'ylabel', 'yl'}
            ylabel(varargin{arg+1});
        case {'zlabel', 'zl'}
            zlabel(varargin{arg+1});
            
        case {'legend', 'le'}
            if iscell(varargin{arg+1})
                % simple calling procedure
                legend(gca, varargin{arg+1});
            else
                % requires parameters: 1. Position, 2. Strings (cell array)
                %   Position = [xbeg ybeg width heigth]
                %   Strings = {'text1', 'text2'}
                %
                % find pos: get(legend, 'Position')
                legend(gca, varargin{arg+2}, 'Position', varargin{arg+1});
                arg = arg + 1;
            end;
		case 'leh'  % legend ??
			legend(varargin{arg+1}, varargin{arg+2});
			arg = arg + 1;
        case {'legendpos', 'lep'}  % position only
            legend(gca, 'Location', varargin{arg+1});
            
        case {'title', 'ti'}
            title(varargin{arg+1});

            % axis properties
        case {'xticklabel', 'xtl'}
            set(gca, 'XTickLabel', varargin{arg+1});
            % TODO: make an automatic xtl that uses xticks as they are set => check for vector size!
            %set(gca, 'XTickLabel', varargin{arg+1}(get(gca, 'XTick')+1));
		case {'extl90'} % requires: text, [ypos]
			set(gca, 'XTickLabel', '');
			xpos = get(gca, 'XTick');
                ret = text(xpos, repmat(-0.05, 1, length(xpos)), varargin{arg+1}, ...
                    'Rotation', 90, 'HorizontalAlignment', 'Right', 'tag', 'plotfmt_extl90');  % , 'units', 'normalized'
			%set(ret, 'Position', get(ret, 'Position')+[-3 0], 'Units', 'pixels');
			thisunits = get(gca, 'units'); set(gca, 'units', 'pixels');
			fpos = get(gca, 'Position'); %[left bottom width height]
			set(gca, 'Position', fpos + [0 80 0 0-80]);
			set(gca,'units', thisunits);
			set(fh, 'activepositionproperty', 'outerposition');
		case {'extl45'} % requires: text
			set(gca, 'XTickLabel', '');
			xpos = get(gca, 'XTick');
			ret = text(xpos, repmat(0, 1, length(xpos)), varargin{arg+1}, ...
				'Rotation', 45, 'HorizontalAlignment', 'Right', 'tag', 'plotfmt_extl45');  % , 'units', 'normalized'
			%set(ret, 'Position', get(ret, 'Position')+[-3 0], 'Units', 'pixels');
			thisunits = get(gca, 'units'); set(gca, 'units', 'pixels');
			fpos = get(gca, 'Position'); %[left bottom width height]
			set(gca, 'Position', fpos + [0 80 0 0-80]);
			set(gca,'units', thisunits);
			set(fh, 'activepositionproperty', 'outerposition');
		case 'extl90inside' % requires: text, yposlist
			set(gca, 'XTickLabel', '');
			xpos = get(gca, 'XTick');
            ret = text(xpos, varargin{arg+2}, varargin{arg+1}, ...
                'Rotation', 90, 'HorizontalAlignment', 'Left', 'tag', 'plotfmt_extl90inside');
			thisunits = get(gca, 'units'); set(gca, 'units', 'pixels');
			fpos = get(gca, 'Position'); %[left bottom width height]
			set(gca, 'Position', fpos + [0 80 0 0-80]);
			set(gca,'units', thisunits);
			set(fh, 'activepositionproperty', 'outerposition');
            arg = arg + 1;
		case 'extl90s' % requires: text, offset
			set(gca, 'XTickLabel', '');
			xpos = get(gca, 'XTick');
			ret = text(xpos, repmat(-0.05, 1, length(xpos)), varargin{arg+1}, ...
				'Rotation', 90, 'HorizontalAlignment', 'Right', 'tag', 'plotfmt_extl90');
			
			% handle position inset
			thisunits = get(gca, 'units'); set(gca, 'units', 'pixels');
			fpos = get(gca, 'Position'); %[left bottom width height]
			set(gca, 'Position', fpos + [0 varargin{arg+2} 0 0-varargin{arg+2}]);
			set(gca,'units', thisunits);
			set(fh, 'activepositionproperty', 'outerposition');
			arg = arg + 1;
			
		case {'extl', 'extl0'}
			% OAM REVISIT: Depending on y-resolution => need to fiddle with
			% units (pixels) to get it right.
			set(gca, 'XTickLabel', ''); 
			xpos = get(gca, 'XTick');
			ret = text(xpos, repmat(-0.2, 1, length(xpos)), varargin{arg+1}, ...
				'Rotation', 0, 'HorizontalAlignment', 'Center');
			%fpos = get(gca, 'Position'); %[left bottom width height]
			%set(gca, 'Position', fpos + [0 0 0 0]);
			set(fh, 'activepositionproperty', 'outerposition');
			
        case {'yticklabel', 'ytl'}
            set(gca, 'YTickLabel', varargin{arg+1});
        case {'zticklabel', 'ztl'}
            set(gca, 'ZTickLabel', varargin{arg+1});

        case {'xtick', 'xt'}
            set(gca, 'XTick', varargin{arg+1});
        case {'ytick', 'yt'}
            set(gca, 'YTick', varargin{arg+1});
        case {'ztick', 'zt'}
            set(gca, 'ZTick', varargin{arg+1});
			
        case {'grid', 'gd'}
            grid(varargin{arg+1});
        case {'xgrid', 'xg'}
            set(gca, 'XGrid', varargin{arg+1});
        case {'ygrid', 'yg'}
            set(gca, 'YGrid', varargin{arg+1});
        case {'zgrid', 'zg'}
            set(gca, 'ZGrid', varargin{arg+1});
			
		case {'xaxislocation', 'xal'}
			set(gca, 'XAxisLocation', varargin{arg+1});
		case {'yaxislocation', 'yal'}
			set(gca, 'YAxisLocation', varargin{arg+1});

        case {'box'}
            set(gca, 'Box', varargin{arg+1});
        case {'ticklength', 'tl'}
			tmp = varargin{arg+1};		if length(tmp)<2, tmp = repmat(tmp,1,2); end;
            set(gca, 'TickLength', tmp);


            % line properties
        case {'linewidth', 'lw', 'linestyle', 'ls', 'linemarker', 'lm', 'linecolor', 'lc'...
                'markeredgecolor', 'mec', 'markerfacecolor', 'mfc', 'markersize', 'ms'}
			if all(strcmpi(get(fh,'type'), 'line'))
				lines = fh;
			else
				lines = findobj(gca,'Type','line', '-and', '-not', 'Tag', 'helpline');
			end;
			
            switch lower(varargin{arg})
                case {'linewidth', 'lw'}
                    property = 'LineWidth';
                case {'linestyle', 'ls'}
                    property = 'LineStyle';
                case {'linemarker', 'lm'}
                    property = 'Marker';
                case {'linecolor', 'lc'}
                    property = 'Color';
                case {'markeredgecolor', 'mec'}
                    property = 'MarkerEdgeColor';
                case {'markerfacecolor', 'mfc'}
                    property = 'MarkerFaceColor';
                case {'markersize', 'ms'}
                    property = 'MarkerSize';
            end;

            if iscell(varargin{arg+1})
                % unfortunately lines are retrieved in the opposite order
                % than drawed, hence we have to reverse it here
                for i = 1:length(lines), set(lines(length(lines)-i+1), property, varargin{arg+1}{i}); end;
            else
                set(lines, property, varargin{arg+1});
            end;

        case 'lmd'  % set default line markers
			if all(strcmpi(get(fh,'type'), 'line'))
				lines = fh;
			else
				lines = findobj(gca,'Type','line', '-and', '-not', 'Tag', 'helpline');
			end;
            for i = 1:length(lines), set(lines(length(lines)-i+1), 'Marker', LineMarkers{i}); end;
            

        case {'fsize', 'fs'}
			% OAM REVISIT: Does not find chidren in axis handle that would
			% contain FontSize (Problem with findobj?). Workaround: set
			% size for every axis independently.
            set(findobj(allchild(fh), '-property', 'FontSize'), 'FontSize', varargin{arg+1});
            set(findobj(allchild(gca), '-property', 'FontSize'), 'FontSize', varargin{arg+1});

        case 'interpreter'  % tex, latex            
            th = findobj(fh, '-property', 'FontSize');
			set(findobj(th, 'flat', 'Interpreter', varargin{arg+1}));            
            
        case {'fstag'}
			th = findobj(fh, '-property', 'FontSize');
			set(findobj(th, 'flat', 'Tag', varargin{arg+1}), 'FontSize', varargin{arg+2});
			th = findobj(gca, '-property', 'FontSize');
			set(findobj(th, 'flat', 'Tag', varargin{arg+1}), 'FontSize', varargin{arg+2});
			arg = arg + 1; % anticipate default increase
			
        case {'textarrow', 'tarrow', 'tarr'}
            % requires parameters: 1. X, 2. Y, 3. String
            %   X, Y: [end, beg]; String: 'text'
            ah = annotation('textarrow', varargin{arg+1}, varargin{arg+2});
            set(ah, 'String', varargin{arg+3});
            set(ah, 'Interpreter', 'tex'); % tex, latex
            arg = arg + 2; % anticipate default increase
            
            
            % printing methods
        case {'print', 'pr', 'preps'}
            [pathstr,name] = fileparts(varargin{arg+1});
            %             print('-depsc', varargin{arg+1});
            print('-depsc', fullfile(pathstr, [name '.eps']));

        case {'makeps2pdf', 'mkps2pdf'}
            [pathstr,name,ext] = fileparts(varargin{arg+1});
            %!cd graphs; epstopdf modelvsdata.eps
            s=system(['cd' pathstr '; epstopdf ' name ext]);
        
        case {'paperorientation', 'po'}  % 'po', 'landscape'
            set(fh, 'PaperOrientation', varargin{arg+1});
            
        case {'printsyspdf', 'prsyspdf'}
            [pathstr,name] = fileparts(varargin{arg+1});
            %             fprintf('\n write %s ', fullfile(pathstr, [name '.eps']));
            print('-depsc', fullfile(pathstr, [name '.eps']));
            cmd = '';
            if (~isempty(pathstr)), cmd = ['cd ' pathstr '; ']; end;
            %             cmd = [cmd ' epstopdf ' name '.eps;' ' rm ' name '.eps'];
            cmd = [cmd ' epstopdf ' name '.eps; '];
            %             fprintf('\n create pdf %s:\n', cmd);
            if ispc, cmd = [ cmd 'del ' name '.eps;']; else cmd = [cmd 'rm ' name '.eps;']; end;
            s=system(cmd);
            
        case {'printpdf', 'prpdf'} % supported, at least on Windows platforms
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.pdf']), 'pdf') ;

        case {'printpdfviapng', 'prpdfviapng'}  % print to pdf via png
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.png']), 'png') ;

            cmd = '';
            if ~isempty(pathstr), cmd = ['cd ' pathstr '; ']; end;
            cmd = [cmd ' convert ' name '.png ' name '.pdf; '];
            if ispc, cmd = [ cmd 'del ' name '.png;']; else cmd = [cmd 'rm ' name '.png;']; end;
            s=system(cmd);
            
            
        case {'printpng', 'prpng'}
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.png']), 'png') ;
        case {'printtif', 'prtif'}
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.tif']), 'tiffn') ;
        case {'printjpg', 'prjpg'}
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.jpg']), 'jpg') ;
        case {'printfig', 'prfig'}
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.fig']), 'fig') ;
        case {'printmfile', 'prmfile'}
            [pathstr,name] = fileparts(varargin{arg+1});
            saveas(fh, fullfile(pathstr,[name '.m']), 'm') ;
            
        case {'laprint', 'lapr'}
            set(0,'defaulttextinterpreter','none');
            if (length(varargin)>arg) && (~isempty(varargin{arg+1}))
                laprint(fh, varargin{arg+1}); %, 'factor', 0.8);
            else
                laprint(fh); % GUI mode
            end;
            
        case {'del', 'rm'}
            delete(fh);
             arg = arg - 1; % anticipate default increase, however this shall be the last arg anyway
            
        otherwise
            error(['Command "' lower(varargin{arg}) '" not recognised.']);
            %arg = arg - 1; % anticipate default increase
    end; % switch
    
    arg = arg + 2; % default behaviour: every command has ONE argument
end; % while arg

