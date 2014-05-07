function ovector = col(vector)
% function ovector = col(vector)
%
% Make column vector
%
% See also: row.m
%
% Copyright 2005 Oliver Amft

% Uses convertvector().
% ovector = convertvector(vector, 'col');

% This is less save (regarding matrices instead of vectors) but faster
ovector=vector(:);
