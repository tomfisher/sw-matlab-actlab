function varargout = sandbox(sandbox_script, varargin)
% function varargout = sandbox(script, varargin)
% 
% Invoke a workspace and run script here. The namespace sandbox_* is
% reserved for THIS function and may not be altered.
% 
% Example: (will return 'thisTargetClasses' on scuccess of the script 'main_spotstats') 
% 
%   sandbox('main_spotstats', 'in', {'fidx', 'SCOMP', 'SubjectList', {'Name'}}, 'out', {'thisTargetClasses'} )  
% 
% 
% Copyright 2007 Oliver Amft

% OAM REVISIT: Is there are more intelligent way to get a fresh workspace? 

varargout = {};

[sandbox_param_in sandbox_param_out sandbox_verbose] = process_options(varargin, 'in', {}, 'out', {}, 'verbose', true);
if ~iscell(sandbox_param_out), sandbox_param_out = {sandbox_param_out}; end;

%clear varargin;


% run it...
[whosstruct sandbox_success] = sandbox_run(sandbox_verbose, sandbox_script, sandbox_param_in);
if ~sandbox_success, return; end;

% catch requested output
for sandbox_i = 1:length(sandbox_param_out)
	varpos = strmatch(sandbox_param_out{sandbox_i}, {whosstruct(:).name}, 'exact');
	if isempty(varpos)
		varargout{sandbox_i} = [];
	else
		varargout{sandbox_i} = whosstruct(varpos).value; 
	end;
end;

if (sandbox_verbose), fprintf('\n%s: Done.', mfilename); end;


% nested
function [whosstruct sandbox_success] = sandbox_run(sandbox_verbose, sandbox_script, sandbox_param_in)

% setup environment to run the script
if (sandbox_verbose), fprintf('\n%s: Setting up variables:', mfilename); end;
for sandbox_i = 1:2:length(sandbox_param_in)
	eval([sandbox_param_in{sandbox_i} '= sandbox_param_in{sandbox_i+1};']);
	if (sandbox_verbose), fprintf('  %s', sandbox_param_in{sandbox_i}); end;
end;

try
    eval([sandbox_script ';']);
	sandbox_success = true;
catch
	fprintf('\n%s: Error in script ''%s'':', mfilename, sandbox_script);
	errorprinter(lasterror, 'DoWriteFile', false, 'MsgOffset', -2);
    sandbox_success = false;
	whosstruct = [];
	return;
end;

% save the environment
whosstruct = whos;
for i = 1:length(whosstruct)
	whosstruct(i).value = eval([whosstruct(i).name ';']);
end;