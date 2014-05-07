function [indices elements] = cmpvectors(base, searchlist)
% function [indices elements] = cmpvectors(base, searchlist)
%
% Compare two vector lists, return elements appearing in both lists
% Efficiency is achieved by assigning searchlist the smaller vector.
% 
% Copyright 2006 Oliver Amft

indices = [];
for i = 1:length(searchlist)
    indices = [indices find(base == searchlist(i))];
end;

if (nargout > 1)
    elements = base(indices);
end;