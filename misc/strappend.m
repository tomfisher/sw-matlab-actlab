function outstr = strappend(varargin)
% function outstr = strappend(varargin)
% 
% Append multiple varables into one string.  Works memory-efficient.

% Copyright 2008 Oliver Amft

appendstrs = varargin;

outstr = repmat(' ', 1, sum(cellfun('size', appendstrs,2)));
insbase = 1;
for i = 1:length(appendstrs)
	outstr(insbase:insbase+length(appendstrs{i})-1) = appendstrs{i};
	insbase = insbase + length(appendstrs{i});
end;