function [seglistM, segconfM] = spot_segmentmerge(method, seglist, segconf, varargin)
% function [seglistM, segconfM] = spot_segmentmerge(method, seglist, segconf, varargin)
%
% Merge section lists acc. to overlap and classification confidence
% Result: Non-overlapping sections with corresponding confidence matrix
% Seglist needs to be sorted according to 2nd column (section end).
%
% requires:
% method          Selection method (see below)
% seglist         List of sections
% segconf         Measure of section fitness
%
% algorithm principle:
% 1. take a section and add it to the buffer, if
%    a: No other overlapping section exists in the buffer, that has smaller
%       distance.
%    b: This section has a smaller distance than already existing sections
%       in the buffer. Remove all overlapping sections from the buffer.
% 2. remove sections from the buffer, that exceed the history constraints.
%    (time: older than 40sec, section: more than 20 section in the buffer)
%
% Selection methods:
%   FrontOfBest      - Select section with highest confidence value
%   Reenforce       - Select section with highest confidence value and keep
%                     highest confidences of removed sections
%   RemoveLike      - Select section with highest confidence value and
%                     remove overlaps sections with similar confidences
%   Combine  - Merge all overlapping sections into one, keep highest
%                     confidence (and class)
%
%
% Optional parameters:
% lookbackt      Size of sliding buffer (Samples), default: 4000
% lookbackn      Size of sliding buffer (No of sections), default: 20
% checkEndPoints Optional section filter: keep best at individual endpoint
% BestConfidence Organisation of section fitness metric, default: 'minimum'
%
% Copyright 2006-2009 Oliver Amft
%
% 2007/12/05, oam
%   optimised sgroup = u_i(i-1)+1:u_i(i); in checkEndPoints (faster)
%   exchanged segment_findoverlap with segment_isoverlap (faster)
% 2008/01/15, oam
%   fixed bug in buffer release timeout strategy, set default lookbackn to 20
% 2009/02/21, oam
%   added mergeadjacent method


[verbose lookbackn lookbackt checkEndPoints BestConfidence merge_distance] = process_options(varargin, ...
    'verbose', 0, 'lookbackn', 20, 'lookbackt', 4000, 'checkEndPoints', true, 'BestConfidence', 'minimum', ...
    'merge_distance', 2);

switch lower(BestConfidence)
    case {'min', 'minimum'}
        BestConfidenceMin = 1;
    otherwise
        BestConfidenceMin = 0;
end;

%[seglist idx] = segment_sort(seglist(:,1:2),2); segconf = segconf(idx,:);
[seglist idx] = segment_sort(seglist,2); segconf = segconf(idx,:);



% Optional section filter: keep best at individual endpoint
[uniqueends u_i] = unique(seglist(:,2));
if (verbose>1)
    fprintf('\n%s: end points to check: %u (unique %u)... ', mfilename, size(seglist,1), length(uniqueends));
end;
tmp_seglist = zeros(length(uniqueends), size(seglist,2));
tmp_segconf = zeros(length(uniqueends), size(segconf,2));

% remove sections from same endpoint, except best one
if (checkEndPoints)
    %endpoint = 1;
    tmp_seglist(1,:) = seglist(u_i(1), :);  tmp_segconf(1,:) = segconf(u_i(1), :);
    for i = 2:length(uniqueends)
        %while (endpoint <= size(seglist,1))
        % keep best segment only (performance issue: keep this here)
        % sgroup: all sections with the same endpoint
        %sgroup = (seglist(:,2) == seglist(endpoint,2));
        %sgroup = (seglist(:,2) == uniqueends(i));
        sgroup = u_i(i-1)+1:u_i(i);
        %endpoint = endpoint + sum(sgroup);
        tmp1 = seglist(sgroup,:);
        tmp2 = segconf(sgroup,:);

        % Must keep ",[],2" to obtain row of min/max in list!
        if (BestConfidenceMin)
            [dummy, bestpt] = min(min(tmp2, [], 2));
        else
            [dummy, bestpt] = max(max(tmp2, [], 2));
        end;

        tmp_seglist(i,:) = tmp1(bestpt,:);
        tmp_segconf(i,:) = tmp2(bestpt,:);
    end;

    red_segconf = tmp_segconf;
    red_seglist = tmp_seglist;
else
    red_segconf = segconf;
    red_seglist = seglist;
end; % if (checkEndPoints)



% Main task: section merge
if (verbose>1)
    fprintf('\n%s: uniquify %u with %u segs and %u sa history... ', mfilename, size(red_seglist,1), lookbackn, lookbackt);
end;

progress = 0.1;
tmp_seglist = []; tmp_segconf = [];
seglistM = []; segconfM = [];
for seg = 1:size(red_seglist,1)
    if (verbose>0), progress = print_progress(progress, seg/size(red_seglist,1)); end;

    % check for overlaps with segments already in the list
    % ovlist = segment_isoverlap(red_seglist(seg, 1:2), tmp_seglist);
    % This inline variant saves creating a dummy result vector.
    ovlist = [];
    if ~isempty(red_seglist) && ~isempty(tmp_seglist)
        ovlist = ~( (red_seglist(seg, 1) > tmp_seglist(:,2)) | (red_seglist(seg, 2) < tmp_seglist(:,1)) );
    end;
    
    if isempty(ovlist), ovlist = 0; end;

    switch lower(method)
        case 'frontofbest'
            % - Find best section (highest confidence)
            % - Omit all previously selected overlapping sections
            %   (may miss "hidden" segments)

            if sum(ovlist)
                % there are already segments in the list
                %nov_ext = extProc(extProc(tmp_segconf(ovlist,:)));
                %testcand = nov_ext - extProc(red_segconf(seg,:));
                if (BestConfidenceMin)
                    nov_ext = min(min(tmp_segconf(ovlist,:)));
                    testcand = nov_ext - min(red_segconf(seg,:)); %extProc(red_segconf(seg,:));
                else
                    nov_ext = max(max(tmp_segconf(ovlist,:)));
                    testcand = nov_ext - max(red_segconf(seg,:));
                end;
                %nov_ext = min(min(tmp_segconf(ovlist,:), [],2));
                %testcand = nov_ext - min(red_segconf(seg,:)); %extProc(red_segconf(seg,:));

                if ((testcand>0) && (BestConfidenceMin==1)) || ((testcand<0) && (BestConfidenceMin==0))
                    % wipe out all hits, if new maximum found
                    tmp_seglist(ovlist,:) = []; tmp_segconf(ovlist,:) = [];

                    % add new element to list
                    tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
                    tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
                end;

            else % if (ovlist)
                % no such segment in the list (best one, for now)
                % add new element to list
                tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
                tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
            end; % if (ovlist)


        case { 'reenforcebest', 'reenforcesum' }
            % - Omit all previously selected overlapping sections
            % - BUT keep the highest confidence from all overlapping sections
            %   (may miss "hidden" segments)

            if sum(ovlist)
                % there are already segments in the list
                if (BestConfidenceMin)
                    nov_ext = min(min(tmp_segconf(ovlist,:)));
                    testcand = nov_ext - min(red_segconf(seg,:)); %extProc(red_segconf(seg,:));
                else
                    nov_ext = max(max(tmp_segconf(ovlist,:)));
                    testcand = nov_ext - max(red_segconf(seg,:));
                end;

                % keep confidence values
                tmpconf = tmp_segconf(ovlist,:);
                suppidx = ovlist(end);


                if ((testcand>0) && (BestConfidenceMin==1)) || ((testcand<0) && (BestConfidenceMin==0))
                    % wipe out all hits, if new maximum found
                    tmp_seglist(ovlist,:) = []; tmp_segconf(ovlist,:) = [];

                    % add new element to list, update confidence
                    tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
                    tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
                    suppidx = size(tmp_segconf,1);
                end;

                switch lower(method)
                    case 'reenforcebest'  % OAM REVISIT: Does this correspond to FrontOfBest ??
                        if BestConfidenceMin
                            tmp_segconf(ovlist,:) = min([red_segconf(seg,:); tmpconf]);
                        else
                            tmp_segconf(ovlist,:) = max([red_segconf(seg,:); tmpconf]);
                        end;
                    case 'reenforcesum'
                        tmp_segconf(suppidx,:) = sum([red_segconf(seg,:); tmpconf], 1);
                        % assume confidence if BestThres==max, set values to one that exceed it
                        % OAM REVISIT: This is a hack!
                        if (BestConfidenceMin==0), tmp_segconf(suppidx, tmp_segconf(suppidx,:)>1) = 1; end;
                    otherwise
                        error('\n%s: Reinforce-mode %s not supported.', mfilename, method);
                end;

            else % if (ovlist)
                % no such segment in the list (best one, for now)
                % add new element to list
                tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
                tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
            end; % if (ovlist)


        case 'combine'
            % - Combine all overlapping sections into one section
            % - keep the highest confidence from all overlapping sections

            if sum(ovlist)
                % there are already better sections in the list

                % keep best confidence value
                if (BestConfidenceMin)
                    newconf = min(min( [tmp_segconf(ovlist,:); red_segconf(seg,:) ] ));
                else
                    newconf = max(max( [tmp_segconf(ovlist,:); red_segconf(seg,:) ] ));
                end;

                % combine hits to new section
                newsection = zeros(1,2);
                newsection(1) = min( [tmp_seglist(ovlist,1); red_seglist(seg,1)] );
                newsection(2) = max( [tmp_seglist(ovlist,2); red_seglist(seg,2)] );
                %newsection = segment_createlist(newsection, 'classlist', red_seglist(seg,4), 'conflist', tmpconf);

                % wipe out all hits in buffer
                tmp_seglist(ovlist,:) = []; tmp_segconf(ovlist,:) = [];

                % add new element to list, update confidence
                tmp_seglist = [tmp_seglist; newsection];
                tmp_segconf = [tmp_segconf; newconf];

            else % if (ovlist)
                % no such segment in the list (best one, for now)
                % add new element to list
                tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
                tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
            end; % if (ovlist)


        case 'none'
            % Leave as is.  (Endpoint check/removal is made anyway.)
            tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
            tmp_seglist = [tmp_seglist; red_seglist(seg,:)];


        case 'supportold'
            % - Omit all previously selected overlapping sections
            % - BUT consider all keep the highest confidence from all overlapping sections
            %   (may miss "hidden" segments)

            if sum(ovlist)
                % there are already segments in the list
                if (BestConfidenceMin)
                    nov_ext = min(min(tmp_segconf(ovlist,:)));
                    testcand = nov_ext - min(red_segconf(seg,:)); %extProc(red_segconf(seg,:));
                else
                    nov_ext = max(max(tmp_segconf(ovlist,:)));
                    testcand = nov_ext - max(red_segconf(seg,:));
                end;

                if ((testcand>0) && (BestConfidenceMin==1)) || ((testcand<0) && (BestConfidenceMin==0))
                    % keep highest confidence values; may be a single line only
                    if BestConfidenceMin
                        tmpconf = min(tmp_segconf(ovlist,:), [], 1);
                    else
                        tmpconf = max(tmp_segconf(ovlist,:), [], 1);
                    end;

                    % wipe out all hits, if new maximum found
                    tmp_seglist(ovlist,:) = []; tmp_segconf(ovlist,:) = [];

                    % add new element to list, update confidence
                    if BestConfidenceMin
                        tmp_segconf = [tmp_segconf; min([red_segconf(seg,:); tmpconf])];
                    else
                        tmp_segconf = [tmp_segconf; max([red_segconf(seg,:); tmpconf])];
                    end;
                    tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
                end;

            else % if (ovlist)
                % no such segment in the list (best one, for now)
                % add new element to list
                tmp_segconf = [tmp_segconf; red_segconf(seg,:)];
                tmp_seglist = [tmp_seglist; red_seglist(seg,:)];
            end; % if (ovlist)



        case 'mergeadjacent'
            % merge sections that are close to each other, merge overlapping ones
            % keep highest confidence

            if sum(ovlist), mergelist = ovlist; else mergelist = length(tmp_segconf); end;
            if (length(mergelist)==1)  && (mergelist==0)
                % add first element to list
                tmp_segconf = red_segconf(seg,:);
                tmp_seglist = red_seglist(seg,:);
            else
                % there are already section(s) in the list, merge is applicable
                tmplist = [tmp_seglist(mergelist,:);  red_seglist(seg,:)];
                newsection = segment_distancejoin( tmplist, merge_distance, 'checklabel', false);
                is_merged = size(tmplist,1)-size(newsection,1);

                if is_merged
                    % keep best confidence value
                    if (BestConfidenceMin)
                        newconf = min(min( [tmp_segconf(mergelist,:); red_segconf(mergelist,:) ] ));
                    else
                        newconf = max(max( [tmp_segconf(mergelist,:); red_segconf(mergelist,:) ] ));
                    end;
                else
                    newconf = [tmp_segconf(mergelist,:);  red_segconf(seg,:)];
                end;

                % wipe out all hits in buffer
                tmp_seglist(mergelist,:) = []; tmp_segconf(mergelist,:) = [];

                % add new element to list, update confidence
                tmp_seglist = [tmp_seglist; newsection];
                tmp_segconf = [tmp_segconf; newconf];
            end;  % if any(mergelist==0)

        otherwise
            error('\n%s: Method %s not understood.', mfilename, method);
    end; % switch method


    % check&remove old segments (this will simulate an online behaviour)
    % rationale: sections in tmp_seglist need to grew so old that they
    % exceed the time bound specified in lookbackt. Current time is red_seglist(seg,2).

    %oldsegs = find((tmp_seglist(end,1)-red_seglist(seg,2)) > lookbackt); %tmp_seglist(:,2)
    %oldsegs = find((red_seglist(seg,2) - tmp_seglist(:,2)) > lookbackt);
    oldsegs = (red_seglist(seg,2) - tmp_seglist(:,2)) > lookbackt;
    seglistM = [seglistM; tmp_seglist(oldsegs,:)]; segconfM = [segconfM; tmp_segconf(oldsegs,:)];
    tmp_seglist(oldsegs,:) = []; tmp_segconf(oldsegs,:) = [];

    %     oldsegs = [lookbackn:size(gsl_nov,1)];
    oldsegs = 1:size(tmp_seglist,1) - lookbackn;
    seglistM = [seglistM; tmp_seglist(oldsegs,:)]; segconfM = [segconfM; tmp_segconf(oldsegs,:)];
    tmp_seglist(oldsegs,:) = []; tmp_segconf(oldsegs,:) = [];
end; % for seg

seglistM = [seglistM; tmp_seglist];
segconfM = [segconfM; tmp_segconf];


% required for method 'OverlapingRanks' and full segments list is supplied
if (size(seglistM,2) >= 4) && (size(segconfM,2) > 1)
    [dummy seglistM(:,4)] = max(segconfM, [], 2);
end;

if (verbose>1), fprintf(' done'); end;
