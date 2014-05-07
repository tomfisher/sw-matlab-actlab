function [equallist equalidx inv_equalidx] = segment_findequals(seglist1, seglist2, varargin)
% function [equallist equalidx inv_equalidx] = segment_findequals(seglist1, seglist2, varargin)
%
% Find common segments in a list, return indices of all identicals with regard to seglist1.
%
% equalidx: seglist2 = seglist1(equalidx)
% inv_equalidx: seglist1 = seglist2(inv_equalidx)
%
% Example:
% [equallist equalidx inv_equalidx] = segment_findequals([100 200; 300 400; 300 400], [200 300; 100 200; 100 200; 300 400])
%
% equalidx = 3     4     4
% inv_equalidx = 0     1     1     3
%
% See also: segment_findidentical.m
% 
% Copyright 2007-2008 Oliver Amft

CheckCols = process_options(varargin, 'CheckCols', [1 2]);

equallist = false(size(seglist1,1),1);
if isempty(seglist2),
	if nargout > 1
		equalidx = find(equallist);
	end;
	return;
end;

for i = 1:size(seglist1,1)
	common = true(size(seglist2,1),1);
	for c = CheckCols(:)'
		common = common & (seglist1(i,c) == seglist2(:,c));
	end;
	equallist(i) = any(common);
end;

% equalidx: seglist2 = seglist1(equalidx)
if nargout > 1
	foundmore = false;
	equalidx = zeros(size(seglist1,1), 1);
	for i = 1:size(seglist2,1)
		tmp = segment_findequals(seglist1, seglist2(i,:));
		if any(tmp), equalidx(tmp) = i; end;
		if sum(tmp)>1, foundmore = true; end;
	end;
	if (foundmore), fprintf('\n%s: WARNING: Found more than one identical in seglist1', mfilename);  end;
end;

% inv_equalidx: seglist1 = seglist2(inv_equalidx)
if nargout > 2
	foundmore = false;
	inv_equalidx = zeros(size(seglist1,1), 1);
	for i = 1:size(seglist1,1)
		tmp = segment_findequals(seglist2, seglist1(i,:));
		if any(tmp), inv_equalidx(tmp) = i; end;
		if sum(tmp)>1, foundmore = true; end;
	end;
	if (foundmore), fprintf('\n%s: WARNING: Found more than one identical in seglist2', mfilename);  end;	
end;

