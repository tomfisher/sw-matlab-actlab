function [overlap_indices, overlap_shares] = segment_findoverlap(iseg, seglist, max_jitter)
% function [overlap_indices, overlap_shares] = segment_findoverlap(iseg, seglist, max_jitter)
%
% Find overlaps in seglist with iseg. Param overlap_indices is wrt seglist.
%
% seglist should be vectors of style:
%
%   [beg1 end1; beg2 end2; ... begN endN]
%
% Jitter mode (max_jitter<inf): Use jitter parameter to check overlaps
% Overlap mode (max_jitter==inf): Check for overlaps only
% 
% Warning: Will not return identicals with max_jitter=0! Use segment_findidenticals instead.
% 
% See also: segment_isoverlap, segment_countoverlap, segment_findequals, segment_findincluded
% 
% Copyright 2005-2006 Oliver Amft

% OAM REVISIT: Added >= instead of > at overlap checks, 20070424

overlap_indices = []; overlap_shares = [];

if isempty(seglist), return; end;

% segment_size() is slow
isize = iseg(2)-iseg(1)+1;
if (~isize), return; end;
if (isize == inf)
    warning('MATLAB:segment_findoverlap', 'Segment iseg has infinite size!');
end;


% Version 3: Parameter: max_jitter
%if (~exist('max_jitter','var')), max_jitter = inf; end;
if (nargin < 3), max_jitter = inf; end;  % faster?!

slsize = seglist(:,2)-seglist(:,1)+1; % segment_size() is slow
for j = 1:size(seglist,1)
    if (~slsize(j)), continue; end;
    if (slsize(j) == inf)
        warning('MATLAB:segment_findoverlap', 'Segment from seglist has infinite size!');
    end;

    ibeg = iseg(1); iend = iseg(2);
    jbeg = seglist(j,1); jend = seglist(j,2);

    % check if segments overlap at all
    if ((ibeg > jend) || (iend < jbeg)), continue; end;

    % skip jitter tests, simply return overlapping segments
    if (max_jitter == inf)
        overlap_shares = [overlap_shares; 0];
        overlap_indices = [overlap_indices; j];
        continue;
    end;

    % check segment begin
    beg_jitter = abs(ibeg-jbeg)/segment_size(iseg);
    if beg_jitter >= max_jitter
        continue;
    end;

    % check segment end
    end_jitter = abs(iend-jend)/segment_size(iseg);
    if end_jitter >= max_jitter
        continue;
    end;

    overlap_indices = [overlap_indices; j];
    overlap_shares = [overlap_shares; (1-max([beg_jitter end_jitter]))];
end;  % for j

return;




% Version 2: Parameter: minoverlap
if (~exist('minoverlap')), minoverlap = 0; end;

% upper bound on overlap (if iseg is included by jseg)
maxoverlap = 1 + (1-minoverlap); % ex.: minoverlap=0.75 => maxoverlap=1.25


overlap_indices = []; overlap_shares = [];
for j = 1:size(seglist,1)
    if (~segment_size(seglist(j,:))) continue; end;
    if (segment_size(seglist(j,:)) == inf)
        warning('Segment from seglist has infinite size!');
    end;

    ibeg = iseg(1); iend = iseg(2);
    jseg = seglist(j,:); jbeg = seglist(j,1); jend = seglist(j,2);

    % check if segments overlap at all
    if ((ibeg > jend) || (iend < jbeg)) continue; end;

    ov_range = sort([iseg jseg]);
    ov_size = ov_range(3) - ov_range(2);
    ov_share = ov_size / segment_size(iseg);

    % special case: correct overlap if jseg includes iseg
    if (jbeg < ibeg) && (jend > iend)
        ov_share = segment_size(jseg) / segment_size(iseg);
    end;

    % finally, decide if segment is within bounds
    if (ov_share >= minoverlap) && (ov_share <= maxoverlap)
        overlap_indices = [overlap_indices; j];
        overlap_shares = [overlap_shares; ov_share];
    end;
end; % for j

return;


% Version 1: Parameter: overlap
if (~exist('overlap')) overlap = 0; end;
ovlapseg = []; ovlapshare = [];

if (~segment_size(seg)) return; end;

for j=1:size(SegTS,1)
    if (~segment_size(SegTS(j,:))) continue; end;

    iseg = seg;
    ibeg = iseg(1); iend = iseg(2);
    jbeg = SegTS(j,1); jend = SegTS(j,2);

    % check if do not segments overlap
    if (ibeg > jend) || (iend < jbeg)
        continue;
    end;

    % segments do overlap
    % Base i: ------|IIIIIIIIII|-------
    % Case 1: ------|JJJJJJJJJJ|-------
    % Case 2: --|JJJJJJJJ|-------------
    % Case 3: ----------|JJJJJJJJ|-----
    % Case 4: -|JJ|-----OR--------|JJ|-
    % Case 5: --|JJJJJJJJJJJJJJJJJJJ|--
    % Case 6: ----------|JJ|-----------
    ov2 = ibeg-jbeg; ov3 = jend-iend;

    if isnan(ov3) ov3 = 0; end;
    switch ov3
        case Inf
            ov3 = 0;
            jend = iend; %jbeg + segment_size(iseg);
        case -Inf
            ov3 = 0;
            iend = jend; %ibeg + segment_size([jbeg jend]);
            iseg = [ibeg iend];
    end;


    if (ov2==0) && (ov3==0)   % Case 1
        ovlapseg = [ovlapseg; j]; % 100% overlap
        ovlapshare = [ovlapshare; 1];
        continue;
    end;

    if (ov2 >= 0) && (ov3 <= 0)   % Case 2
        if ((jend-ibeg+1)/segment_size(iseg) > ovbound)
            ovlapseg = [ovlapseg; j];
            ovlapshare = [ovlapshare; (jend-ibeg+1)/segment_size(iseg)];
        end;
        continue;
    end;
    if (ov2 <= 0) && (ov3 >= 0)   % Case 3
        if ((iend-jbeg+1)/segment_size(iseg) > ovbound)
            ovlapseg = [ovlapseg; j];
            ovlapshare = [ovlapshare; (iend-jbeg+1)/segment_size(iseg)];
        end;
        continue;
    end;

    if (ov2 > 0) && (ov3 > 0)   % Case 5
        if (segment_size(iseg)/segment_size([jbeg jend]) > ovbound)
            ovlapseg = [ovlapseg; j];
            ovlapshare = [ovlapshare; segment_size(iseg)/segment_size([jbeg jend])];
        end;
        continue;
    end;
    if (ov2 < 0) && (ov3 < 0)   % Case 6
        if (segment_size([jbeg jend])/segment_size(iseg) > ovbound)
            ovlapseg = [ovlapseg; j];
            ovlapshare = [ovlapshare; segment_size([jbeg jend])/segment_size(iseg)];
        end;
        continue;
    end;
end; %  for j=1:size(SegTS,1)
