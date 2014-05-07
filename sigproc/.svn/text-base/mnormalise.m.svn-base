function [nmatrix onorms] = mnormalise(matrix, method, inorms)
% function [nmatrix onorms] = mnormalise(matrix, method, inorms)
%
% Normalise matrix along columns using vector norm of that column
% Uses normv() function
% 
% Copyright 2005-2008 Oliver Amft

[rows, cols] = size(matrix);

if ~exist('method','var') || isempty(method), method = 'norm'; end;
if ~exist('inorms','var') || isempty(inorms), inorms = repmat(1,1,cols); end;

onorms = inorms;
nmatrix = zeros(size(matrix));
for c = 1:cols
    switch method
        case {'norm', 'L2norm'}  % L2-norm
            onorms(c) = normv(matrix(:,c)');
        case {'sum', 'L1norm'}  % L1-norm
            onorms(c) = sum(abs(matrix(:,c)));
        case {'max', 'Linfnorm'}  % Linf-norm
            onorms(c) = max(abs(matrix(:,c)));

		case 'apply'
        otherwise
            onorms(c) = 1;
    end;
    onorms(c) = onorms(c) + (abs(onorms(c))<eps)*eps;
    
    nmatrix(:,c) = matrix(:,c)/onorms(c);
end;