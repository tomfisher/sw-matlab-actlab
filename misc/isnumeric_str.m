function [bool,value]=isnumeric_str(str)
% Check if a string represents a number
% Written by: E. R.: February 23, 2004
% Last updated:
%
%        bool=isnumeric_str(str)
% INPUT
% str    string
% OUTPUT
% bool   logical variable; set to logical(1) if the string represents a numeric value
%        and to logical(0) if it does not or has length zero

value=str2num(str);
if isempty(str) || isempty(value)
   bool=logical(0);
else
   bool=logical(1);
end
      
