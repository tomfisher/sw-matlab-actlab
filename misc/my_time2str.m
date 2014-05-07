function str = my_time2str(timein, varargin)
% function str = my_time2str(timein, varargin)
% 
% Print time string
% 
% See also: my_timedim, time2str
% 
% Copyright 2005 Oliver Amft

[ShowDays] = process_options(varargin, 'ShowDays', true);

switch max(size(timein))
    case 1
        % HMS time
        minuestime = rem(timein, 1)*60;
		if (timein<24) || (~ShowDays)
			str = sprintf('%02u:%02u:%02u',  fix(timein), fix(minuestime), fix(rem(minuestime, 1)*60) );
		else
			str = sprintf('%ud, %02u:%02u:%02u',  fix(timein/24), rem(fix(timein), 24), fix(minuestime), fix(rem(minuestime, 1)*60) );
		end;
		
    case 6
        % clock() time
        str = sprintf('%02u:%02u:%02u',  timein(4), timein(5), round(timein(6)));
	
	otherwise
        error('Format not recognised!');
end;