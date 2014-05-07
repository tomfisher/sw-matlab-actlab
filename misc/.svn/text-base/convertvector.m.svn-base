function vector = convertvector(vector, mode)
% function vector = convertvector(vector, mode)
%
% Convert vector to row/column format
%
% vector        - data
% mode          - 'col' for column, 'row' for row vector (default: row)

% OAM REVISIT
% Slow: exist()
if (exist('mode')~=1) mode = 'row'; end;
if isempty(vector) return; end;

if isempty(find(size(vector)==1))
    warning('%s: Not a 1 dim vector', mfilename);
    return;
end;

switch lower(mode)
    case 'row'
        vector=vector(:);
        vector=vector';

    case {'column', 'col'}
        vector=vector(:);
end;