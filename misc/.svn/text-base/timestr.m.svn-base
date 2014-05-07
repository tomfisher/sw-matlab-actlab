function str = timestr(secs)
% function str = timestr(secs)
% 
% Copyright 2009 Oliver Amft

hours = fix(secs/3600);
min = fix(rem(secs, 3600)/60);
sec = rem(secs, 60);
str = sprintf('%02uh:%02um:%02.1fs',  hours, min, sec );
