function result = findn(p1, p2, cmp)
% function result = findn(p1, p2, cmp)
% 
% Returns row-wise comparison result of vectors p1, p2. cmp is one of the
% following comparison operations:
%   'eq' :  is equal
% 
% 
% Example: 
% findn([1 2 3 4 2], [1 6 2], 'eq')
% ans =
% 
%      1     1     0     0     1
% 
% Copyright 2007 Oliver Amft


if (~exist('cmp', 'var')), cmp = 'eq'; end;

np1 = length(p1); np2 = length(p2);


%result = zeros(1, np1*np2);
result = repmat(false, 1, np1);

for i = 1:np2
	switch lower(cmp)
		case {'eq', 'isequal'}
			thisresult = row(p1 == p2(i));
			result = bitor(result, thisresult);
		case {'ne', 'notequal'}
			thisresult = row(p1 ~= p2(i));
			result = bitand(result, thisresult);
		otherwise
			error('Parameter cmp not supported.');
	end;
	
	%result(1,(i-1)*np1+1:i*np1) = thisresult;

end;