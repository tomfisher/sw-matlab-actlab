function c = str2cellf(str, del)
% function c = str2cellf(str, del)
% 
% Partition string at position 'del' into cell array fields. This code is
% faster than the implementation in str2cell.m
% 
% See also str2cell, str2celln, num2strcell
%
% Copyright 2007 Oliver Amft

if ~exist('del', 'var'), del = ' '; end;

delpos = [0 strfind(str, del) length(str)+1];

c = cell(1,length(delpos)-1);
for i = 1:length(delpos)-1
    c{i} = str(delpos(i)+1:delpos(i+1)-1);
end;
