function [y,p] = majority(x)
% MAJORITY decision for a vector
%    Y = MAJORITY(X) returns the element of x with the most frequent 
%        occurence. The result will be biased towards lower elements
%    [Y,P] = MAJORITY(X) additionally returns the ratio to the next 
%        frequent element
% 
%    Example: If x = [0 0 1 1 1 0 3 3 4 4]
%             then [y,p] = majority(x) is y=0 and p=0.5
%
%             If x = [0 1 1 1 1 0 2 3 4 5]
%             then [y,p] = majority(x) is y=1 and p=0.6667


% Author: Mathias St�ger (staeger[at]ife.ee.ethz.ch)
% Date:   10. May 2004

y = 0; p = [];
if isempty(x) return; end;

x = x+1;    % include element "0" as well

for i = 1:max(x)   
    count(i) = length(find(x == i));
end

[number, y] = max(count);             %%% be careful: the result will always be biased towards lower classes

if nargout == 2
    count(y) = 0;
    number2 = max(count);
    p = 1 - number2/(number+number2);        %%% ratio to next frequent element
end

y = y-1;    % compensate for "0" element