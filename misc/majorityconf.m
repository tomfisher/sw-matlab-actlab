function cc = majorityconf(classlist, conflist)
% function cc = majorityconf(classlist, conflist)
% 
% Return highest frequency number (e.g. major class occurence) and average confidence for this class
% 
% See also: majority.m
% 
% Copyright 2008 Oliver Amft

[classids classcount] = countele(classlist(:,1));

[mclassid pos] = max(classcount);

cc(1) = classids(pos);
cc(2) = mean(conflist(classlist==classids(pos)));