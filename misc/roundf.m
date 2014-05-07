function fixed = roundf(value, fdigits)
% function fixed = roundf(value, fdigits)
%
% Round with specified precision
% 
% See also: roundn
% 
% Copyright 2009 Oliver Amft

scaler = 10^fdigits;

fixed = round(value.*scaler)./scaler;