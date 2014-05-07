function [fh, fobj] = plotfancybars(varargin)
% function [fh, fobj] = plotfancybars(varargin)
% 
% Plot fancy bar charts
% 
% A really early first version of the code...
% 
% Options (processed in sequence of occurance):
% figure            - open a figure
% plotsingle        - create a non-grouped bar chart
% ...
% 
% Example:
% 
% plotfancybars([10 13 14], 'figure', 'plotsingle', 'legend', {'One', 'Two', 'Three'}, 'bartexttop', {'10', '12+1', '14'})


fh = [];

% process_params('options', 
Barlist = varargin{1};
if nargin > 1, params = varargin(2:end); end;

fobj.cmap = gray(length(Barlist)+2);  fobj.cmap([1 end],:) = [];
fobj.barpos = [];



argnr = 1;
while argnr<=length(params)
    switch params{argnr}

        case 'plotsingle'        % non-grouped bars
            if isempty(fobj.barpos), fobj.barpos = 1:length(Barlist); end;
            
            for f = 1:length(fobj.barpos)
                hold('on');
                fobj.bh(f) = bar(fobj.barpos(f), Barlist(f), 0.8);
                xlim([min(fobj.barpos)-1 max(fobj.barpos)+1]);
                
                if isfield(fobj, 'cmap')
                    set(fobj.bh(f), 'FaceColor', fobj.cmap(f,:));
                end;
            end; % f = 1

            
        case 'bartexttop'       % put text on top of bar
            bartexts = params{argnr+1};
            for f = 1:length(fobj.barpos)
                text(fobj.barpos(f), Barlist(f), bartexts{f}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
            end; % f = 1
        
        
        case 'verbose'
            verbose = params{argnr+1};
            if (verbose), fprintf('\n%s: Total initial points: %u', mfilename, length(Barlist)); end;
            argnr = argnr + 1;

        case 'figure'
            fh = figure;
            
        case 'fh'  % plot into fh
            fh =  params{argnr+1};
            argnr = argnr + 1;
            figure(fh);
            
        case 'cmap'
            fobj.cmap = params{argnr+1};
            argnr = argnr + 1;

        case 'colormap'
            fobj.cmap = params{argnr+1}(length(barlist)+1);
            argnr = argnr + 1;
            
        case {'le', 'legend'}
            plotfmt(fh, 'le', params{argnr+1});
            fobj.lh = legend('Location', 'SouthWest');
            argnr = argnr + 1;
            
            
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


