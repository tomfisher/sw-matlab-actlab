function count = prmetrics_countoverlap(seglistBase, seglistEval, max_jitter)
% function count = prmetrics_countoverlap(seglistBase, seglistEval, max_jitter)
%
% Count overlaps in seglistEval with seglistBase. Result count is wrt seglistBase.
%
% seglist* should be vectors of style:
%   [beg1 end1; beg2 end2; ... begN endN]
%
% max_jitter - Boundary fuzziness parameter [0; 1] or inf
%   Jitter mode (max_jitter<inf): Use jitter parameter to check overlaps
%   Overlap mode (max_jitter==inf): Check for overlaps only
% 
% Example: 
%   prmetrics_countoverlap([100 200; 1000 3000], [100 200; 1 99; 20 1000; 199 201; 1000 1100; 150 200], 0.5)
% ans = 2  0
%   prmetrics_countoverlap([100 200; 1000 3000], [100 200; 1 99; 20 1000; 199 201; 1000 1100; 150 200])
% ans = 4  2
%
% Warning: Will not return identicals with max_jitter=0! Use segment_findidenticals instead.
%
% See also:
%   segment_findoverlap, segment_isoverlap, segment_countoverlap, segment_findequals, segment_findincluded
% 
% Copyright 2005-2008 Oliver Amft

if (nargin < 3), max_jitter = inf; end;  % faster?!

count = zeros(1, size(seglistBase,1));
if isempty(seglistBase) || isempty(seglistEval), return; end;

isize = seglistBase(:,2)-seglistBase(:,1)+1; % segment_size() is slow
if any(isize == inf), warning('MATLAB:prmetrics_countoverlap', 'Segment from seglistBase has infinite size!'); end;
jsize = seglistEval(:,2)-seglistEval(:,1)+1; % segment_size() is slow
if any(jsize == inf), warning('MATLAB:prmetrics_countoverlap', 'Segment from seglistEval has infinite size!'); end;

% check and count for every section in seglistBase
for i = 1:size(seglistBase,1)
	ibeg = seglistBase(i,1); iend = seglistBase(i,2);
	if ~isize(i), continue; end;

	% compare to every section in seglistEval
	for j = 1:size(seglistEval,1)
		jbeg = seglistEval(j,1); jend = seglistEval(j,2);

		% check if segments overlap at all
		if (ibeg > jend) || (iend < jbeg), continue; end;

		% skip jitter tests, simply count overlap
        % This will allow sections that have larger size to match overlapping GT.
		if (max_jitter == inf)
			count(i) = count(i) + 1;
			continue;
		end;

		% check segment begin
		this_jitter = abs(ibeg-jbeg)/isize(i);
		if this_jitter >= max_jitter
			continue;
		end;

		% check segment end
		this_jitter = abs(iend-jend)/isize(i);
		if this_jitter >= max_jitter
			continue;
		end;

		count(i)  = count(i) + 1;
	end;  % for j
end; % for i