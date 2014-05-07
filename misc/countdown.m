function countdown(seconds, varargin)
% function countdown(seconds, varargin)
% 
% Pause with feedback (countdown)
% 
% Optional paramters:
%   premsg - message to print before countdown
%   postmsg - message to print after countdown expired
%   verbose - 1: print any text, 0: do not print text
% 
% Copyright 2007 Oliver Amft
% based on launch feedback code from Martin Kusserow

if ~exist('seconds','var'), seconds = 10; end;

[premsg postmsg verbose] = process_options(varargin, 'premsg', 'Launching in', 'postmsg', '...', 'verbose', 1);

seconds = seconds -1;
positions = floor(log10(seconds))+1;
ctrlbs = repmat('\b', 1, positions); spaces = repmat(' ', 1, positions);

addctrlbs = 0;
if (verbose), fprintf(['\n%s ' spaces], premsg); addctrlbs = 1; end;

for i = seconds:-1:0
    fprintf([ctrlbs '%0' num2str(positions) 'd'], i);
    pause(1);
end;

%fprintf([ctrlbs '\b\b\b\b...\n\n']);
if (verbose)
	fprintf([ctrlbs repmat('\b', 1, addctrlbs) postmsg '\n\n']);
else
	fprintf([ctrlbs '\n']);
end;
