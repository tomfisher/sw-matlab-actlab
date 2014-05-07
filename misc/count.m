function [gtzeros zeros] = count(Vector)
% function [gtzeros zeros] = count(Vector)
% 
% Trivial element counter. Returns elements count that are greater than
% zero and zero. Vector must be single column.

gtzeros = length(find(Vector>0));
zeros = length(Vector) - gtzeros;