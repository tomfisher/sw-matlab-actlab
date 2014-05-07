function varargout = mat2el(matrix, dim)
% function varargout = mat2el(matrix, dim)
%
% Extract elements from a matrix

if (exist('dim')~=1) dim = 1; end;

matrix = shiftdim(matrix, dim);

for e = 1:size(matrix,1)
    varargout{e} = matrix(e,:);
end;
