function [outvar found] = tryloadvar(filename, loadvar)
% function [outvar found] = tryloadvar(filename, loadvar)
%
% Try loading directly to a variable. 
% Returns [] if variable does not exist.
%
% See also lsmatfile, loadin
% 
% Copyright 2008 Oliver Amft

% OAM REVISIT: Maybe I just cannot find the right Matlab function for this.


if ~isempty(lsmatfile(filename, loadvar))
	%warning('off', 'MATLAB:load:variableNotFound');
	tmp = load('-mat', filename, loadvar);
	%warning('on', 'MATLAB:load:variableNotFound');
else
	outvar = []; found = false; return;
end;

outvar = tmp.(loadvar);

