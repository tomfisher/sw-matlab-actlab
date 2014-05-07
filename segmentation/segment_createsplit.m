function seglist = segment_createsplit(DataSize, Splits, SegLabels)
% function seglist = segment_createsplit(DataSize, Splits, SegLabels)
% 
% Create splitted segments from DataSize, adapting splits to NOT intersect
% with SegLabels. This code is used for data CV and related purposes.
% 
% --------------------------------------------------------------------------------------------------------------------
% initial split:   |           |                         |                                 |
% SegLabels:     --  -------          -------------        ----------------
% Results:        |            >>|                    >>|                            |
%
% Problem case: shift bound NOT in direction of shortest distance!
% initial split:   |                                     |                            |
% SegLabels:   ------ ----------------------------------------------
% Results:        |        |<<                                                    |
% --------------------------------------------------------------------------------------------------------------------
% 
% Copyright 2006-2009 Oliver Amft

if Splits<1, error('Splits smaller than one not possible.'); end;

% CV with one split needs two data sections
if Splits == 1, Splits = 2; end;
SegLabels = segment_sort(SegLabels);

% OAM REVISIT: Bug detected, 2009/03/11
% seglist would be limited to sections (labels) in this case only!
% % if splits == SegLabels, then use it right away
% if Splits == size(SegLabels,1)
% %     seglist = SegLabels;
%     fprintf('\n%s: WARNING: CVSectionBounds implementation is a hack. Refine.', mfilename);
%     warning('matlab:segment_createsplit','CVSectionBounds implementation is a hack.');
% %     return;
% end;

% create an arbitrary segmentation list
segunits = floor(DataSize / Splits);
seglist = [];
for s = 1:Splits
    seglist = [seglist; [ (s-1)*segunits+1    s*segunits*(s<Splits) + DataSize*(s==Splits) ]];
end;

% adapt boundaries to segment labels
for s = 2:Splits
    % check that segment begins adjacent to previous one, this is important
    % after alignment corrections
    seglist(s,1) = seglist(s-1,2) + 1;
    
    % check for misalignment and correct previous segment end and start of current one.
    %ov = segment_isinbounds(SegLabels, seglist(s,1));
    ov = segment_findoverlap([seglist(s,1) seglist(s,1)], SegLabels);
    if (ov)
        % needs correction
		% OAM REVISIT: TODO: shift according to minimal correction needed
        seglist(s-1,2) = SegLabels(ov,2);
        seglist(s,1) = SegLabels(ov,2)+1;
    end;

    % correct segments sized below 1 
    ss = segment_size(seglist(s,:));
    if (ss <= 0)
        seglist(s,2) = seglist(s,2) + abs(ss) + 1; % make segment size 1
    end;

    % finally, check segments exceeding DataSize (current and next one)
    % this may create overlaps and jams in seglist, but keeps the number of
    % segments as specified by Splits
    if (seglist(s,2) > DataSize), seglist(s,2) = DataSize; end;
    if (seglist(s,1) > DataSize), seglist(s,1) = DataSize; end;
end;


% checking
% OAM REVISIT: Revise
for i = 1:size(seglist,1)
    if i>1
        haserr = seglist(i,1) ~= seglist(i-1,2)+1;
        if any(haserr); fprintf('\n%s: Seglist is not adjacent at pos %u.', mfilename, i); end;
    end;
    
	tmp = segment_isinbounds(seglist(i,1:2), SegLabels(:,1)) | segment_isinbounds(seglist(i,1:2), SegLabels(:,2));
    haserr = ( (seglist(i,1)>=SegLabels(tmp,1)) & (seglist(i,2)>=SegLabels(tmp,2)) ); 
    if any(haserr); 
        eel = find(tmp);
        fprintf('\n%s: Seglist has overlap errors at CV fold %u for given bound(s): %s.', mfilename, i, mat2str(eel(haserr))); 
    end;
    
%     if any(haserr), error('Errors in seglist detected, stop.'); end;
end;
