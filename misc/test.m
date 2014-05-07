function result = test(expression)
% function result = test(expression)
%
% Test if expression works, i.e. object exists...
% Result: 1 = expr. works; 0 = not
% Parameter object should be a char array.
% 
% Copyright 2005 Oliver Amft

result = 1;

try
    evalin('caller', [expression ';']);
catch
    result = 0;
end;
