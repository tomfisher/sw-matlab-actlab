function smatrix = printmatrix(matrix, mode, hlegend, vlegend, precision)
% function smatrix = printmatrix(matrix, mode, hlegend, vlegend, precision)
%
% Print matrix line wise.
% The advantage over printmat() is that it allows to print latex tables (in
% future).
%
% Modes:
% 'latex'       print a tex formatted table
% 'text'        print a ascii screen formatted table (default)
% 'csv'         print a cvs formatted table
%

if (exist('mode')~=1) mode = 'ascii'; end;
if (exist('precision')~=1) precision = 0; end;

[vsize, hsize] = size(matrix);

switch lower(mode)
    case 'latex'
        % not fully implemented yet
        crlf_sign = ' \\';
        colsep_sign = '&';
        valdist = 2;
    case 'text'
        crlf_sign = '';
        colsep_sign = ' ';
        valdist = 2;
    case 'csv'
        crlf_sign = '';
        colsep_sign = ',';
        valdist = 0;
    otherwise
        crlf_sign = '';
        colsep_sign = '';
        valdist = 1;
end;

hlegend_on = 1;
if (exist('hlegend')~=1) | isempty(hlegend)
    hlegend = repmat({''}, 1, size(matrix,2));
    hlegend_on = 0;
end;
if (exist('vlegend')~=1) | isempty(vlegend)
    vlegend = repmat({''}, size(matrix,1), 1);
end;

% horizontal column spacing
vmaxspacing = max(cellfun('length', vlegend));
hspacing = [vmaxspacing cellfun('length', hlegend)];
if (max(max(abs(matrix)))>0)
    ff = ceil(log10(max(max(abs(matrix))))) + precision + valdist;
else
    ff = 0 + precision + valdist;
end;
hspacing(find(hspacing<ff)) = ff;
hmaxspacing = max(hspacing);

% prepare print masks for lines and header
lprintmask = ''; hprintmask = '';
for col = 1:max(size(hspacing))
    colspc = hspacing(col);
    
    % column > 1 need a colsep_sign
    switch col
        case 1
            %             lprintmask = [lprintmask ['%' mat2str(colspc) '.' mat2str(precision) 'f']];
            %             hprintmask = [hprintmask ['%' mat2str(colspc) 's']];
        case 2
            if (vmaxspacing)
                lprintmask = [lprintmask [colsep_sign '%' num2str(colspc) '.' mat2str(precision) 'f']];
                hprintmask = [hprintmask [colsep_sign '%' mat2str(colspc) 's']];
            else
                lprintmask = [lprintmask ['%' num2str(colspc) '.' mat2str(precision) 'f']];
                hprintmask = [hprintmask ['%' mat2str(colspc) 's']];
            end;
        otherwise
            lprintmask = [lprintmask [colsep_sign '%' num2str(colspc) '.' mat2str(precision) 'f']];
            hprintmask = [hprintmask [colsep_sign '%' mat2str(colspc) 's']];
    end;
end;



smatrix = '';

% make header row
if (hlegend_on)
    smatrix = [smatrix sprintf('%s', repmat(' ', 1, vmaxspacing))]; % 1st col empty
    smatrix = [smatrix sprintf(hprintmask, hlegend{:})];
    smatrix = [smatrix sprintf('%s \n', crlf_sign)];
end;

% make value lines
for row = 1:size(matrix,1)
    if (row > 1) smatrix = [smatrix sprintf('\n')]; end;
    valline = sprintf(lprintmask, matrix(row,:));
    vleg = sprintf(['%' mat2str(vmaxspacing) 's'], vlegend{row});
    smatrix = [smatrix sprintf('%s%s%s', vleg, valline, crlf_sign)];
end;
% smatrix = [smatrix sprintf('%s\n', crlf_sign)];
