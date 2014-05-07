function matrix = cell2matrix(obj, element, verbose)
% function matrix = cell2matrix(obj, element, verbose)
% Converts a cell list into a matrix, default is: element=1
% Does nothing if obj is not a cell.
if (exist('verbose')~=1) verbose = 0; end;
if (exist('element')~=1) element = 1; end;

if iscell(obj)
    if (verbose) warning(['Cell not supported, used cellobj{' mat2str(element) '}']); end;
    matrix = obj{element};
else
    matrix = obj;
end;
