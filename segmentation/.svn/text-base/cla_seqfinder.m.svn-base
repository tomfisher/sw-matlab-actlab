function SeqList = cla_seqfinder(labellist, seqmarklabels, varargin)
% function SeqList = cla_seqfinder(labellist, seqmarklabels, varargin)
%
% Determine labels that belong to a sequence (was: main_seqfinder)
SeqList = {};

[findlabelids, stoplabel, verbose] = process_options(varargin, 'findlabelids', [], 'stoplabel', [], 'verbose', 1);

if isempty(seqmarklabels),
	if (verbose), fprintf('\n%s: No seqlabels found, exiting.', mfilename);  end;
	return;
end;

stoplabel = segment_sort(stoplabel);
seqmarklabels = segment_sort(seqmarklabels);

% if there are stoplabels, these will be used to terminate last sequence,
% if not seqlabels is assumed to include a closing label already (last
% label will not be considered as sequence begin in this case).
if isempty(stoplabel), 
	nsequences = size(seqmarklabels,1)-1;
else
	nsequences = size(seqmarklabels,1);
end;

if (verbose), fprintf('  Sequences: %u', nsequences); end;
SeqList = cell(1, nsequences);

if isempty(labellist), 
	if (verbose), fprintf('\n%s: No labels found, SeqList will be empty.', mfilename);  end;
	return; 
end;

if (verbose), fprintf('\n%s: Labels: %u, Class IDs: %s', mfilename, size(labellist,1), mat2str(unique(labellist(:,4))) ); end;

% Find all labels that are btw begin of current and end of following gesture.
for seg = 1:nsequences
	
	% find labels that are btw seqmarklabels
    if (seg == nsequences) && ~isempty(stoplabel)
        % for last cycle: use stoplabel as end information
        stopmark = stoplabel(seqmarklabels(seg,2) < stoplabel(:,1),:);
        seqlabels = labellist(segment_findincluded([seqmarklabels(seg,1) stopmark(1,1)], labellist),:);
    else
        seqlabels = labellist(segment_findincluded([seqmarklabels(seg,1) seqmarklabels(seg+1,1)], labellist),:);  % seqmarklabels(seg+1,2)
    end;

	if ~isempty(findlabelids), 
		SeqList{seg} = segment_sort(segment_findlabelsforclass(seqlabels, findlabelids));
	else
		SeqList{seg} = segment_sort(seqlabels);
	end;
	
end; % for seg

% checks
if length(SeqList) ~= nsequences, error('Sequence count does not match.'); end;
