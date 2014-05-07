function str = repos_printclasses(Repository)
% function str = repos_printclasses(Repository)
% 
% List all classes
% 
% Copyright 2008 Oliver Amft

labelstrings = Repository.Classlist;
maxLabelNum = length(labelstrings);

str = '';
str = [ str sprintf('\n  %5s    %15s  %5s  %15s', 'Class', 'Name', 'Class', 'Name') ];
for class = 1:maxLabelNum
    if rem(class,2), str = [str sprintf('\n')]; end;
    str = [str sprintf('  %5u: %15s', class, labelstrings{class}) ];
end;
str = [ str sprintf('\n') ];
