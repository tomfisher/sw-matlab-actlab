function ok = filewrite(mode, filename, varargin)
% function ok = filewrite(mode, filename, varargin)
%
% Write a data file with the values supplied.
% mode:         operating modes with the syntax:
%               filemode: create, append (can be abrev'd w first letter)
%               datamode: csv, binary
% filename:     ...string
% value list    format:
%               value1, datatype (precision),
%               value2, datatype (precision), ...
%
% datatype: int32, float32...
%
% Copyright 2006 Oliver Amft
% Comments or improvements: oam@ife.ee.ethz.ch


minarg = 3; % arguments other than values to be written (do not change)

% extract mode flags
tmpmode = mode;
[filemode tmpmode] = strtok(tmpmode);
[datamode tmpmode] = strtok(tmpmode);

% open file
switch lower(filemode)
    case {'create', 'c', 'write', 'w'}
        fh = fopen(filename,'w');
        beginseq = '';
    case {'append', 'a'}
        fh = fopen(filename,'a');
        beginseq = '\n';
end;
if (fh < 0), error('\n%s: Cannot write file.', mfilename); end;

% write data
arg = 1;
while (arg <= nargin-minarg+1)
    switch lower(datamode)
        case 'csv'
            if (arg == 1), fprintf(fh, beginseq); end;
            if (arg > 1), fprintf(fh, ','); end;

            formatchar = translate_datatype(varargin{arg+1});
            fprintf(fh, formatchar, varargin{arg});
            arg = arg + 2;

        case {'binary', 'b'}
            fwrite(fh, varargin{arg}, varargin{arg+1});
            arg = arg + 2;

        case {'paramval', 'pv'}
            pname = varargin{arg}; % arg:      parameter name
            pval = varargin{arg+1}; % arg+1:    parameter value
            ptype = varargin{arg+2}; % arg+2:    parameter data type

            fprintf(fh, '\n%s=', pname);
            formatchar = translate_datatype(ptype); %parameter data type

            %parameter value
            switch formatchar
                case {'%f'}
                    fprintf(fh, '%s', printmatrix(pval, 'csv', '', '', 5));
                case '%u'
                    fprintf(fh, '%s', printmatrix(pval, 'csv', '', '', 0));
                case {'%s', '"%s"', '"%s",'}
                    fprintf(fh, formatchar, pval);
            end;

            arg = arg + 3;
            if (arg > nargin-minarg+1), fprintf(fh, '\n'); end;
        
        case {'string', 's'}
            fprintf(fh, '\n%s', varargin{arg});
            arg = arg + 1;
    end;
end; % for arg

ok = fclose(fh);



% subroutines
% convert data type from precision format to fprintf
function formatchar = translate_datatype(dtype)
switch lower(dtype)
    case {'int8', 'int16', 'int32', 'int', 'i'}
        formatchar = '%u';
    case {'float32', 'float64', 'double', 'float', 'f'}
        formatchar = '%f';
    case {'schar', 'uchar', 'char', 'string', 's'}
        formatchar = '%s';
    case {'quotedstring'}
        formatchar = '"%s"';        
    case {'quotedstringc'}
        formatchar = '"%s",';        
end;
