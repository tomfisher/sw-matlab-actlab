function timeout = my_timedim(timein, fmt_from, fmt_to)
% function timeout = my_timedim(timein, fmt_from, fmt_to)
% 
% Convert time formats
%
% See also: my_time2str
%
% Copyright 2005 Oliver Amft


switch lower(fmt_from)
    case 'sec'
        sectime = timein;
    otherwise
        error('"From" time format not supported!');
end;

switch lower(fmt_to)
    case 'hr'
        timeout = sectime * (1/3600);
     otherwise
        error('"To" time format not supported!');
end;
       