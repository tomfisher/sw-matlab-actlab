function [varnames whosstruct] = lsmatfile(filename, varargin)
% function [varnames whosstruct] = lsmatfile(filename, varargin)
%
% Print content of mat-file on console or return info struct. Further
% parameters can identify individual variables.
% 
% To determine if a variable in a file exist:
%     varname = lsmatfile(<filename>, <varname>);
% Returns empty varname if variable does not exist, otherwise the name. 
% 
% See also: loadin, tryloadvar
% 
% Copyright 2005-2013 Oliver Amft

if (nargin > 1)
    if (nargout == 0)
        whos('-file', filename, varargin{:})
    end;
    whosstruct = whos('-file', filename, varargin{:});
    %     return;
else
    if (nargout == 0)
        whos('-file', filename)
    end;
    whosstruct = whos('-file', filename);
end;

if (nargout == 0), clear('whosstruct'); return; end;

varnames = cell(1, length(whosstruct));
for i = 1:length(whosstruct)
    varnames{i} = whosstruct(i).name;
end;