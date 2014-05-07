function dummy = paramtester(varargin)
% function dummy = paramtester(varargin)
%
% Silly parameter test function

for i = 1:length(varargin)
    i
 disp(varargin{i})
 
end;