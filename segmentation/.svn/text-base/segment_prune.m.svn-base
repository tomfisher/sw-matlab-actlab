function seglist = segment_prune(oldlist, varargin)
% function seglist = segment_prune(oldlist, varargin)
% 
% Return pruned segments
% 
% Pruning functions are:
%   check_isseg
%   check_overlap
%   check_minsize
% 
% Copyright 2006 Oliver Amft

[check_isseg check_overlap check_minsize param_overlap] = process_options(varargin, ...
    'check_isseg', true, 'check_overlap', false, 'check_minsize', 0, ...
    'param_overlap', inf);

oldlist = segment_sort(oldlist);

seglist = [];
for seg = 1:size(oldlist,1)
    good = true;
    
    % real segment
    %if (check_isseg) good = good && segment_isseg(oldlist(seg,:)); end;
    if ~segment_isseg(oldlist(seg,:)), continue; end;
    
    % overlap
    if (check_overlap)
        good = good && isempty(segment_findoverlap(oldlist(seg,:), seglist, param_overlap)); 
    end;
    
    % minsize
    if (check_minsize)
        good = good && (segment_size(oldlist(seg,:)) > check_minsize);
    end;

    if good
        seglist = [seglist; oldlist(seg,:)];
    end;
end; % for seg

seglist = segment_sort(seglist);