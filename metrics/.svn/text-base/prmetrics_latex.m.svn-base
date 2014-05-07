function tab = prmetrics_latex(varargin)
% function prmetrics_latex(metrics)
%
% Print a PR performance metric in latex table format
% 
% 
% See also: latextable
% 
% Copyright 2005-2011 Oliver Amft

[prmetrics, params] = process_params('options', varargin{:});
[TableOrientation, TabSpec, RuleBefore, BoldColumn, BoldRow, InsetSpaces] = process_options(params, ...
    'TableOrientation', 'horizontal', ...
    'TabSpec', { 'Relevant', 'Retrieved', 'Recognised', 'Insertions', 'Deletions', 'Recall', 'Precision', 'F'}, ...
    'RuleBefore', {'Relevant', 'Recall'}, ...
    'BoldColumn', [], 'BoldRow', [], 'InsetSpaces', 2 );

tab = nan(length(TabSpec), length(prmetrics));
for i = 1:length(prmetrics)
    if iscell(prmetrics(i)), metric = prmetrics{i};
    else metric = prmetrics(i); end;
    
    tab(:,i) = getfields(metric, lower(TabSpec));
end;
InsetStr = repmat(' ', 1, InsetSpaces);

fprintf('\n \\toprule');

% see: edit /home/oamft/projects/0_papers/TBME2008/TBME2008.m
% latextable(allme, 'RowLabels', RowLabels, ... 
% 	'RowMode', [ {'v', 'v'}, repmat({'v', 'vb'}, 1, 4) ], 'ColumnMode', [ {'s'}, repmat({'v$', 'v$<'}, 1, 3) ], ...
% 	'ColumnFormat', [ {'%s'}, repmat({'%.1f', '(%.1f)'}, 1, 3) ] );


for r = 1:size(tab,1) % per row
    % create rules before
    if strmatch(TabSpec{r}, RuleBefore), fprintf('\n \\midrule'); end;

    for c = 1:size(tab,2) % per col
        % create table line
        if (c == 1), fprintf('\n%s%s ', InsetStr, TabSpec{r}); end;
        
        switch TabSpec{r}
            case { 'Relevant', 'Retrieved', 'Recognised', 'Insertions', 'Deletions' }  % use integers
                formatstr = ' & $%u$';
                if any(c == BoldColumn) || any(c == BoldRow)
                    formatstr = ' & $\\textbf{%u}$'; 
                end;

            case { 'Recall', 'Precision', 'F' }  % use floats
                formatstr = ' & $%.2f$';
                if any(c == BoldColumn) || any(c == BoldRow)
                    formatstr = ' & $\\textbf{%.2f}$'; 
                end;
        end;
        
        fprintf(' %s', num2str(tab(r,c), formatstr) );
        if (c == size(tab,2)), fprintf('  \\\\'); end;  %  \\\\[-1ex]
    end; % for c
end; % for r

fprintf('\n \\bottomrule');
fprintf('\n\n');


% for f = 1:length(fields)
% 
%         fprintf('\n %12s ', fields{f});
%         for i=1:length(metrics(idx).(fields{f}))
%             if length(metrics(idx).(fields{f})) > 20
%                 fprintf(' & too many fields!');
%                 break;
%             end;
%             if max(hasfrac(metrics(idx).(fields{f})))
%                 fprintf(' & %1.2f ', metrics(idx).(fields{f})(i));
%             else
%                 fprintf(' & %4u ', metrics(idx).(fields{f})(i));
%             end;
%         end;
%         fprintf(' \\\\ ');
% 
%     end;
% end;
% fprintf('\n');