function prmetric = prmetrics_fromsegments(segments_REF, segments_EVAL, jitter)
% function prmetric = prmetrics_fromsegments(segments_REF, segments_EVAL, jitter)
%
% Create a PR performance metric struct from segmentation lists
% uses prmetrics_mkstruct()
%
% segments_REF  - ground truth
% segments_EVAL - evaluation segmentation (can be a cell list)
% jitter        - allowances for segment jitter (any overlap: =0)


warning('MATLAB:prmetrics_fromsegments', '\n%s: Use prmetrics_softalign instead.', mfilename);

if (~exist('jitter','var')), jitter = 0; end;

if iscell(segments_EVAL)
    listcnt = length(segments_EVAL);
else
    listcnt = 1;
    segments_EVAL = {segments_EVAL};
end;

for list = 1:listcnt
    % compute metrics
    matchlist = segment_countoverlap(segments_REF, segments_EVAL{list}, jitter);
    matches = find(matchlist > 0);
    
    % OAM REVISIT
    % When jitter is large, segments from EVAL may overlap with more than
    % one REF segment satisfying the jitter requirement (the segment fits in
	% between two GT labels). Generally jitter should be decreased in this
	% case. This is a shortcomming of the method.
	% Here stupid results (insertions<0) are prevented by limiting the 
	% number of recognised to the number of retrieved segments.
    if (length(matches) > size(segments_EVAL{list},1)) 
		if (jitter < inf)
			fprintf('\n%s: Limiting multiple GT matches: matches=%u, retrieved=%u, jitter=%0.1f.', ...
				mfilename, length(matches), size(segments_EVAL{list},1), jitter);
			fprintf('\n%s: Probable reason is a large value for variable jitter', mfilename);
		end;
        matches = matches(1:size(segments_EVAL{list},1)); 
    end;

    recognised = length(matches);
    retrieved = size(segments_EVAL{list},1);
    relevant = size(segments_REF,1);

    misses = find(matchlist==0);
    hits = matches;

    prmetric(list) = prmetrics_mkstruct(relevant, retrieved, recognised, misses, hits);
end; % for list