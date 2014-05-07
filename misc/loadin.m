function varargout = loadin(filename, varargin)
% function varargout = loadin(filename, varargin)
% 
% Load directly to a variable.
%
% See also lsmatfile, tryloadvar
% 
% Copyright 2005-2009 Oliver Amft

% OAM REVISIT: Maybe I just cannot find the right Matlab function for this.

varargout = [];

try
    tmp = load('-mat', filename, varargin{:});
catch
    errmsg = lasterror;
    if strcmpi(errmsg.identifier, 'MATLAB:load:couldNotReadFile'), rethrow(errmsg); return; end;
    
    % It may happen that load fails if the file is written in a concurrent process. Wait  and retry.
    pause(3);
    tmp = load('-mat', filename, varargin{:});
end;

varargout = cell(1, length(varargin));
for i = 1:length(varargin)
	if isfield(tmp, varargin{i}), 	varargout{i} = tmp.(varargin{i}); end;
end;