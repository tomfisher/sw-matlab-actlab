function smatrix = matrixprint(matrix, hlegend, vlegend, mode)
% function matrixprint(matrix, hlegend, vlegend, mode)
%
% Print matrix line wise.
% The advantage over printmat() is that it allows to print latex tables (in
% future).
%
% Modes:
% 'latex'       print a tex formatted table
% 'ascii'       print a ascii screen formatted table (default)

if (~exist('mode','var')), mode = 'ascii'; end;

switch lower(mode)
    case 'latex'
        % not fully implemented yet
        crlf_sign = '\\';
        colsep_sign = '&';
    otherwise
        crlf_sign = '';
        colsep_sign = '';
end;

if (~exist('hlegend','var'))
    hlegend = repmat({''}, 1, size(matrix,2));
end;
if (~exist('vlegend','var'))
    vlegend = repmat({''}, size(matrix,1), 1);
end;

% column one space
hspacing = (cellfun('length', hlegend));
h1spacing = max(cellfun('length', vlegend));

% column spacing
hspacing = (cellfun('length', hlegend));
vspacing = max(cellfun('length', vlegend));

lprintmask = []; hprintmask = [];

for col = 1:max(size(hspacing))
    colspc = hspacing(col);
    
    switch col
        case 1
            lprintmask = [lprintmask [' %' mat2str(colspc) 'u']];
            hprintmask = [hprintmask [' %' mat2str(colspc) 's']];

        otherwise
            lprintmask = [lprintmask [colsep_sign ' %' mat2str(colspc) 'u']];
            hprintmask = [hprintmask [colsep_sign ' %' mat2str(colspc) 's']];
    end;
end;


fprintf('\n %s', repmat(' ', 1, h1spacing));
fprintf(hprintmask, hlegend{1:size(matrix,2)});

for row = 1:size(matrix,1)
    valline = sprintf(lprintmask, matrix(row,:));
    vleg = sprintf(['%' mat2str(vspacing) 's'], vlegend{row});
    fprintf('%s\n %s%s', crlf_sign, vleg, valline);
end;
fprintf('%s\n', crlf_sign);
