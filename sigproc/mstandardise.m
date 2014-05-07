function [nmatrix omeans ostds] = mstandardise(matrix, imeans, istds)
% function [nmatrix omeans ostds] = mstandardise(matrix, imeans, istds)
%
% Standardise matrix along columns using mean and sd of that column
% 
% See also: clipnormstandardise
% 
% Copyright 2008 Oliver Amft

[nrows, ncols] = size(matrix);

if (nargin < 2)
    imeans = mean(matrix, 1);
    istds = std(matrix,[],1);
    istds = istds + eps*(istds==0);
end;

nmatrix = matrix - repmat(imeans, nrows, 1);
nmatrix = nmatrix ./ repmat(istds, nrows, 1);

omeans = imeans;  ostds = istds;