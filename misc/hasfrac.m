function hf = hasfrac(in)
% function hf = hasfrac(in)
% 
% Determine of a number has fractional. 
% This function operates independent of the variable type, e.g. while isfloat(.) would return true
% for a double value, hasfrac(.) checks whether it contains a float value.
% 
% Copyright 2007 Oliver Amft

hf = false(1, length(in));
for i=1:length(in)
    hf(i) = ((round(in(i)) - in(i)) ~= 0);
end;