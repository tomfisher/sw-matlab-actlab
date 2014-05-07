function count = wcl(filename, mode)
% function count = wcl(filename, mode)
%
% Count the lines in a text file
% mode      FAST: use system call 'wc -l'
%           SLOW: use Matlab methods

% Copyright 2006 Oliver Amft
% TODO: Determine if 'wc' is around and fallback to SLOW mode
% automatically.
% wcl('/home/oam/local/xsens/mess9/MT9_matrix_000072AA_001.log','WIN')
if (exist('mode') ~= 1) mode = 'FAST'; end;

switch upper(mode)
    case {'FAST', 'UNIX', 'LINUX', 'CYGWIN'}
        % Use the system to count for you - FAST
        [r s] = system(['wc -l ' filename]);
        count = str2num(strtok(s));
        % security check
        if isempty(count) error('%s: Something went wrong in system call.', mfilename); end;

    case {'SLOW', 'WIN', 'WINDOWS', 'NOUNIX'}
        % MATLAB way of doing things - SLOW!
        fid = fopen(filename,'r');
        count = 0;
        while ~feof(fid)
            line = fgetl(fid);
            count = count + 1;
        end;

    otherwise
        error('%s: Mode %s was not understood.', mfilename, mode);
end
