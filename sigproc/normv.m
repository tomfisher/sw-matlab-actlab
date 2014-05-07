function distance = normv(matrix)
% function distance = normv(matrix)
% 
% Compute vector 2-norm (Euclidean length) by interpreting data in columns
% 
% See also: mnormalise
% 
% Copyright 2007 Oliver Amft

distance = zeros(size(matrix,1),1);

for i = 1:size(matrix,1)
    distance(i) = norm(matrix(i,:), 2); % largest singular value
end