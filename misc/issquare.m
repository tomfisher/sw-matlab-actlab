function yes = issqare(matrix)
% function yes = issqare(matrix)
% 
% Determine whether matrix is square

% (c) 2007 Oliver Amft, ETH Zurich

yes = false;
if (exist('matrix','var')~=1) || isempty(matrix), return; end;

[nrows ncols] = size(matrix);

yes = (nrows == ncols);
