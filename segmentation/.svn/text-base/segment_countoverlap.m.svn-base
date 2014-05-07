function counts = segment_countoverlap(SegBase, SegOV, jitter)
% function counts = segment_countoverlap(SegBase, SegOV, jitter)
%
% Count overlaps of SegOV with SegBase. Count list is returned as
% vector with respect to SegBase. If Seg* is a cell array, the first
% index will be used. Parameter jitter defaults to inf.
% 
% Copyright 2006-2008 Oliver Amft

if iscell(SegBase), 
	warning('matlab:segment_countoverlap', 'SegBase was cell array, used SegBase{1}.');	
	SegBase = SegBase{1}; 
end;
if iscell(SegOV), 
	warning('matlab:segment_countoverlap', 'SegOV was cell array, used SegOV{1}.');	
	SegOV = SegOV{1}; 
end;

if ~exist('jitter','var'), jitter = inf; end;

counts = zeros(1, size(SegBase,1));
if jitter < 0
	% handles jitter=-inf specifically
	for segbase = 1:size(SegBase,1)
		counts(segbase) = length(segment_findincluded(SegBase(segbase,:), SegOV, abs(jitter)));
	end;

elseif jitter == 0

	for segbase = 1:size(SegBase,1)
		counts(segbase) = length(find(segment_findequals(SegBase(segbase,:), SegOV)>0));
	end;

else
	% handles jitter=inf specifically
	for segbase = 1:size(SegBase,1)
		counts(segbase) = length(segment_findoverlap(SegBase(segbase,:), SegOV, jitter));
	end;

end;

