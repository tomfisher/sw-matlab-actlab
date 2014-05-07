function [newseglist slist] = segment_findgaps(seglist, varargin);
% function newseglist = segment_findgaps(seglist, varargin);
%
% Returns a segment list of gaps for seglist list (inversion)
% 
% Options:
%   Maxsize - end of last section returned, default: inf
%   IncludeBoundaries - true: include external bounds, e.g. [1 minseg-1; maxseg+1 Maxsize] 

newseglist = []; slist = [];

[Maxsize IncludeBoundaries] = process_options(varargin, ...
    'Maxsize', inf, 'IncludeBoundaries', true);

if isempty(seglist)
	if (Maxsize<inf),  newseglist = [1 maxsize]; end;
	return;
end;

for seg = 1:size(seglist,1)
    if (seglist(seg,1) > Maxsize), break; end;

    switch (seg)    % first (boundary)
        case 1
            if (seglist(seg,1) > 1) && (IncludeBoundaries)
                newseglist = [newseglist; [1 seglist(seg,1)-1]];
                slist = [slist 0];
            end;

        case size(seglist,1) % last (boundary)
            if seglist(seg-1,2)+1 < seglist(seg,1)-1
                newseglist = [newseglist; [seglist(seg-1,2)+1 seglist(seg,1)-1]];
                slist = [slist seg-1];
            end;

        otherwise
            if (seglist(seg-1,2)+1 < seglist(seg,1)-1)
                newseglist = [newseglist; [seglist(seg-1,2)+1 seglist(seg,1)-1]];
                slist = [slist seg-1];
            end;
    end; % switch (seg)
end; % for seg

if (seglist(end,2) < Maxsize) && (IncludeBoundaries)
    newseglist = [newseglist; [seglist(end,2)+1 Maxsize]];
    slist = [slist size(seglist)];
end;