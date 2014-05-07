function yes = isbetween(Values, Ranges)
% function yes = isbetween(Values, Ranges)
%
% Check if scalar value is in bounds given by Ranges. Bounds are considered
% valid results (inclusive). Parameter Ranges may be a list of segments:
%     [beg1 end1; beg2 end2; ...].
% 
% Example:
%       isbetween(5, [1 2; 3 5])
% ans =
%      0
%      1
%
% See also: segment_isinbounds
% 
% Copyright 2006, 2011 Oliver Amft

nRanges = size(Ranges,1);
nValues = numel(Values,1);

if (nRanges>1) && (nValues>1)
	error('Operation  not supported. Either Ranges or Values may be more than one item.');
end;

if (nRanges>1)
	% Ranges is a list
	yes = zeros(nRanges, 1);

	for i = 1:nRanges
		yes(i) = ( Values(1) >= Ranges(i,1)) * (Values(1) <= Ranges(i,2) );
	end;

else
	% Values is a vector
	yes = ( Values(:) >= Ranges(1)) & (Values(:) <= Ranges(2) );
end;