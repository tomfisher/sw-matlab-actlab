function summetrics = prmetrics_sumsum(varargin)
% function summetrics = prmetrics_sumsum(varargin)
%
% Sum PR performance metric structs
% 
% WARNING: This does not create a mean result.
% 
% See also: prmetrics_elementsum
% 
% Copyright 2010 Oliver Amft

if nargin>1 || iscell(varargin), prmetrics = cell2mat(varargin); 
else prmetrics = varargin{1}; end;


summetrics = [];
for i = 1:length(prmetrics)
    summetrics = prmetrics_add(summetrics, prmetrics(i));
end;