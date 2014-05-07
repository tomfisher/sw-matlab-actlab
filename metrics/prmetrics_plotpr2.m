function [fh fobj] = prmetrics_plotpr2(varargin)
% function [fh fobj] = prmetrics_plotpr2(varargin)
%
% Create PR performance metric graphs.
% 
% Example: prmetrics_prplot2(metricstruct, 'options', 'figure', fh)  % will use existing figure handle fh
%
% Options: see code  (processed sequentially)
% 
% Example:
%   prmetrics_plotpr2(prstruct_returned_from_mkstruct, 'options', 'plotlines', 'view');
% 
% This will extract precision and recall values from the struct and plot these using connected lines for viewing on the screen.
% 
% 
% See also: prmetrics_mkstruct, prmetrics_softalign
% 
% Superseeds: prmetrics_plotpr, prmetrics_plotarea
% 
% Copyright 2009-2011 Oliver Amft

fh = [];
[prmetrics, params] = process_params('options', varargin{:});
% prmetrics = prmetrics{:};

for cf = 1:max(size(prmetrics))
    if iscell(prmetrics{cf}), vin = prmetrics{cf}{1}; else vin = prmetrics{cf}; end;
    tmp_prmetrics{cf} = vin;
end;
prmetrics = tmp_prmetrics;


cmap=gray(length(prmetrics)+1);

% defaults (use lazy matches, match only when string begin is identical)
% append pruning
if  ~any(cellstrmatch({'prune'}, params, [], 'IgnoreNonStrings', true)) && ~any(cellstrmatch({'plot'}, params, [], 'IgnoreNonStrings', true)), 
    params(end+1:end+2) = {'prune', {'rmnan', 'idpoints', 'paretofront', 'bestp'}}; 
end;
% if isempty(params), params{end+1} = 'plot'; end;  % append plotting
if  ~any(cellstrmatch({'plot'}, params, [], 'IgnoreNonStrings', true)), params{end+1} = 'plotlines'; end;  % append plotting

argnr = 1;
while argnr<=length(params)
    switch params{argnr}
        case 'verbose'
            verbose = params{argnr+1};
            if (verbose), fprintf('\n%s: Total initial points: %u', mfilename, length(prmetric)); end;
            argnr = argnr + 1;

        case {'fig', 'figure'}  % plot into fh
            fh =  params{argnr+1};
            argnr = argnr + 1;
            
        case 'cmap'
            cmap = params{argnr+1};
            argnr = argnr + 1;

        case 'colors'
            cmap=jet(length(prmetrics)+1);
            
        case {'noprune', 'prunenot'} % nop (to avoid defaults, see above)
        case 'prune'
            %if isempty(params{argnr+1}), pruneopts = {'rmnan', 'idpoints', 'paretofront', 'closerec', 0.03}; else pruneopts = params{argnr+1}; end;
            pruneopts = params{argnr+1};
            clear tmp_prmetrics;
            for cf = 1:length(prmetrics)
                prmetrics{cf} = prmetrics_prprune(prmetrics{cf}, pruneopts{:});
            end;
            argnr = argnr + 1;
            
        case 'plotlines'  % plot performance lines
            if isempty(fh), fh = figure('visible', 'on'); end;
            figure(fh); hold on; xlim([0 1.01]); ylim([0 1.01]);
            % axis square;
            for cf = 1:length(prmetrics)
                if isempty(prmetrics{cf}), continue; end;
                [precision recall] = prmetrics_getpr(prmetrics{cf});
                %plotdata = sortm([recall precision], 'mode', 'hierarchy');
               
                if isbetween(precision(1), [0.1 1]) && isbetween(recall(1), [0.1 0.99])
                    fprintf('\n%s: Added PR point: 1,0.', mfilename);
                    precision = [1; precision];  recall = [0; recall];
                end;

                % plot it!
                fobj.ph(cf) = plot(recall, precision, 'color', cmap(cf,:), 'LineWidth', 1);
            end;

            plotfmt(fh, 'xl', 'Recall', 'yl', 'Precision');
            plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
            plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
            LineMarkers = { 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h'};
            plotfmt(fh, 'lm', LineMarkers, 'mec', num2cell(cmap,2), 'mfc', num2cell(cmap,2)); %, 'ms', 8);
            plotfmt(fh, 'ls', '--');
            
            
        case 'plotpoints'  % plot performance points
            if isempty(fh), fh = figure('visible', 'on'); end;
            figure(fh); hold on; xlim([0 1.01]); ylim([0 1.01]);
            % axis square;

            LineMarkers = { 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h', 'o', '^', 'd', '*', 'x', '<', '>', 'p', 'h'};
            for cf = 1:length(prmetrics)
                if isempty(prmetrics{cf}), continue; end;
                [precision recall] = prmetrics_getpr(prmetrics{cf});
                
                fobj.ph(cf) = plot(recall, precision, 'Linestyle', 'none');  % make point only!  
                set(fobj.ph(cf), 'LineWidth', 1, 'Marker', LineMarkers{cf}, ...  
                    'MarkerFaceColor', cmap(cf, :), 'MarkerEdgeColor', cmap(cf, :)); % 'Marker', '+', 'MarkerSize', 7, 'DisplayName', fobj.plotid);
            end;
            plotfmt(fh, 'xl', 'Recall', 'yl', 'Precision');
            plotfmt(fh, 'XTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
            plotfmt(fh, 'YTick', [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1]);
            %plotfmt(fh, 'lm', LineMarkers);
            
        case 'plotbars_f'  % plot performance bars
            if isempty(fh), fh = figure('visible', 'on'); end;
            figure(fh); hold on; xlim([0 1.01]); ylim([0 1.01]);
            for cf = 1:length(prmetrics)
                if isempty(prmetrics{cf}), continue; end;
                [f] = prmetrics_getfield(prmetrics{cf}, 'f');
                
                % OAM REVISIT: TODO
            end;
            
            
        case {'le', 'legend'}
            plotfmt(fh, 'le', params{argnr+1});
            fobj.lh = legend('Location', 'SouthWest');
            argnr = argnr + 1;
            
        case 'postnolines'
            plotfmt(1, 'ls', 'none');
            plotfmt(fh, 'gd', 'off', 'box', 'on');
            
        case 'diagline'
            fobj.diaglh = line([0 1], [1 0], 'color', 'k');
            
        case 'laprint'
        case 'print'  % quick diagram saving
            fn = params{argnr+1};
            plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14);
            plotfmt(fh, 'pr', fn);
            argnr = argnr + 1;
        case 'view'
            % for viewing only
            plotfmt(fh, 'gd', 'on', 'lw', 2, 'fs', 14);

            
        otherwise
            error(['Command "' lower(params{argnr}) '" not recognised.']);
    end; % switch
    argnr = argnr + 1; % default behaviour: every command has NO argument
end; % while arg


