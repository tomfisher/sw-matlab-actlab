function string=cell2str(cellvec, sep)
% function string=cell2str(cellvec, sep)
% 
% Function converts cell vector of strings to a string
%
% INPUT
%   cell    Cell array of strings
%   sep     separator between strings output; default is blank
% OUTPUT
%   string  All strings in the cell array lined up
% 
% Example:
%   string=cell2str(cellvec,sep)
% 
% See also: str2cell, str2cellf, str2celln
% 
% Copyright 2007-2008 Oliver Amft
% based on cell2str.m of other authors

if (nargin == 1), sep=' '; end;
if isempty(cellvec), string = ''; return; end;
if ~iscell(cellvec), cellvec = {cellvec}; end;

for i = 1:length(cellvec)
    if isnumeric(cellvec{i}), cellvec{i} = mat2str(cellvec{i}); end;
	if islogical(cellvec{i}), cellvec{i} = mat2str(cellvec{i}); end;
    
    if (i == 1)
        string = cellvec{i};
    else
        string = [string, sep, cellvec{i}];
    end;
end;

