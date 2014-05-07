function str = errorprinter(errorlog, varargin)
% function str = errorprinter(errorlog, varargin)
%
% Print Matlab error stack and dump to file.
%
% Example calling procedure:
%
%  errorprinter(lasterror, 'DoWriteFile', false)
%
% Options:
%   MsgOffset - pos. nr.: omit error trace up to level (usful when run from a stack of scripts)
%     neg. nr.: show last entries only, default: 0
%   DoWriteFile - true: Write error file, default: true
%   ErrFilename - Name and path of the error file, default: DATA/LOG/error_<TaskTitle>.log
%   TaskTitle - Identifier for this job, default: base ws tasktitle (whitespaces are replaced with '_')
%
% Copyright 2007-2011 Oliver Amft

VERSION = '006';

if ~exist('errorlog','var')  || isempty(errorlog), errorlog = lasterror; end;

[MsgOffset DoWriteFile ErrFilename TaskTitle verbose] = process_options(varargin, ...
    'MsgOffset', 0, 'DoWriteFile', false, 'ErrFilename', '', 'TaskTitle', '', 'verbose', ~nargout);

str = '';
str = [ str sprintf('\n%s: %s', mfilename, datestr(now)) ];
if isfield(errorlog, 'identifier'), str = [ str sprintf('\n%s: Error message: %s', mfilename, errorlog.identifier) ]; end;

if isfield(errorlog, 'message')
    str = [ str sprintf('\n%s: Error message: \n\n%s\n', mfilename, errorlog.message) ];
else
    str = [ str sprintf('\n%s: Error message not found in structure.\n\n', mfilename) ];
end;

if isfield(errorlog, 'stack')
    str = [ str sprintf('\n%s: Error stack trace (stack total: %u):', mfilename, length(errorlog.stack)) ];
    
    if abs(MsgOffset)>length(errorlog.stack) || (MsgOffset==0)
        MsgOffset = length(errorlog.stack)-1; % return at least last trace element
    end;
    
    % critical - Matlab likes crashing on out-of-bound struct access!
    if (MsgOffset>=0), showstacksize = length(errorlog.stack)-MsgOffset;
    else showstacksize = abs(MsgOffset); end;
    
    for i = 1:showstacksize
        str = [ str sprintf('\n%s: Trace %2u: File: %s (%u), Path: %s (%u)', mfilename, i, ...
            errorlog.stack(i).name, errorlog.stack(i).line, errorlog.stack(i).file, errorlog.stack(i).line) ];
        %fprintf('%s', evalc('errortrace'));
    end;
    str = [ str sprintf('\n') ];
end;


% write to file
if (DoWriteFile)
    % try to identify the job/simulation this error was created from
    weaktt = false;
    if isempty(TaskTitle), try TaskTitle = evalin('base', 'tasktitle'); catch TaskTitle = ''; end; end;
    if isempty(TaskTitle), try TaskTitle = evalin('base', 'getenv(''HOSTNAME'')'); weaktt = true; catch TaskTitle = ''; end; end;
    if isempty(TaskTitle), try TaskTitle = evalin('base', 'getenv(''HOST'')'); weaktt = true; catch TaskTitle = ''; end; end;
    if isempty(TaskTitle),
        str = [ str sprintf('\n%s: WARNING: Unable to determine TaskTitle. Can not create error log.', mfilename) ];
    end;
    if (weaktt)  % need to pad TaskTitle with a random number
        TaskTitle = [ TaskTitle num2str(round(rand*1e6)) ];
    end;
    
    if isempty(ErrFilename) || ~exist(fileparts(ErrFilename), 'dir')
        ErrFilename = fullfile('DATA', 'LOG', ['error_' strrep(TaskTitle,' ','_') '.log']);
    end;
    if ~exist(fileparts(ErrFilename), 'dir')
        ErrFilename = fullfile('DATA', ['error_' strrep(TaskTitle,' ','_') '.log']);
    end;
    if ~exist(fileparts(ErrFilename), 'dir')
        str = [ str sprintf('\n%s: WARNING: Unable to write error log file. Directory %s does not exist.', mfilename, ErrFilename) ];
    else
        % ok to write, overwrite if exists
        filewrite('c s', ErrFilename, ...
            ['# Error log file: ' TaskTitle], ...
            ['# File created with ' mfilename ', version ' VERSION ' at ' datestr(now)], ...
            '# (c) 2008 Oliver Amft, oam@ife.ee.ethz.ch', '');
        
        filewrite('a s', ErrFilename, str);
        filewrite('a s', ErrFilename, '', '# End of error log');
    end;
    
    if (verbose), fprintf('\n%s: Wrote error log: %s.', mfilename, ErrFilename); end;
end;  % if (DoWriteFile)

% escape backslash char on Windows machines
str = strrep(str, '\', '\\');

% dump to console
if verbose, fprintf(str); end;