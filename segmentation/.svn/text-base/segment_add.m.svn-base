function newseglist = segment_add(seglist, addseg, mode)
% function newseglist = segment_add(seglist, addseg, mode)
% 
% Merge two segments supplied
%
% mode:         select where to add the size of addseg to seglist.
%               Option are: begin / end / bothends

% (c) 2004-2012 Oliver Amft

% TODO: check for classid in segment lists, if existing.

if (nargin < 3), mode = 'END'; end;

newseglist = zeros(size(seglist));
for i = 1:size(seglist,1)
    newseglist(i,:) = seglist(i,:);     % copy segment
    
    switch upper(mode)
        case 'BEGIN'
            newseglist(i,1) = seglist(i,1) - segment_size(addseg);
            if (newseglist(i,1) < 0), error('segment_add: BEGIN below zero.'); end;
            
        case 'END'
            newseglist(i,2) = seglist(i,2) + segment_size(addseg);

        case 'BOTHENDS'
            newseglist(i,1) = seglist(i,1) - segment_size(addseg);
            newseglist(i,2) = seglist(i,2) + segment_size(addseg);
    end;
end;

