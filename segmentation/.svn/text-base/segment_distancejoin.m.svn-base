function listout = segment_distancejoin(listin, distance, varargin)
% function listout = segment_distancejoin(listin, distance, varargin)
%
% Join segments when their distance is below the threshold "distance".
% If distance is zero, adjancent segments will be merged. Generally this 
% routine will merge overlapping segments since the distance between the 
% segments will be negative. Returned list is sorted along first column.
% 
% Optional parameters:
% distance: Gap threshold for merging segments, default = 0
% sortcolumn: Column to use for sorting list, default=1
% checklabel: Enable label checking before actual merge, default=true
%     (This works only if listin columns >= 4)
% 
% Following segment list is expected WHEN listin columns >= 3:
%     [START STOP LENGTH]  (LENGTH is in samples)
% in this case LENGTH will be adapted.
% 
% Following segment list is expected WHEN listin columns >= 5:
%     [START STOP LENGTH LABEL COUNT]  (LENGTH is in samples)
% in this case LENGTH and COUNT will be adapted.
% 
% Copyright 2006 Oliver Amft
% 
% bugfix: merged end not maximum value!, oam 2010-02-21

if ~exist('distance','var'), distance = 0; end;

[sortcolumn checklabel] = process_options(varargin, ...
	'sortcolumn', 1, 'checklabel', true);

islabelseglist = (size(listin,2) >= 4);

listout = [];

% OAM REVISIT: Who is using sortcolumn <> 1?
if sortcolumn ~= 1, error('sortcolumn is not 1.'); end;

listin = segment_sort(listin, sortcolumn);
% dists = listin(2:end,2)-listin(1:end-1,1);


idx = 1;
while (idx <= size(listin,1))
    listout = [listout; listin(idx,:)];
    
    while (idx < size(listin,1)) && ((listin(idx+1,1)-listout(end,2)) < distance)

        % merge segment
        if ( islabelseglist ) && ( checklabel )
            if listout(end,4) == listin(idx+1,4)
                listout(end,2) = max( listin(idx+1,2), listout(end,2) );
			else 
				% hit rejected, continue
                break;                
            end;

		else 
            %listout(end,:) = segment_createlist([listout(end,1) tmp_listin(idx+1,2)], 'template', tmp_listin(idx+1,:));
            listout(end,2) = max( listin(idx+1,2), listout(end,2) );
        end;
		
		idx = idx + 1;
    end;

    idx = idx + 1;
end;

% LENGTH field
if ( size(listout,2)>=3 ),  listout(:,3) = segment_size(listout); end;

% COUNT field
if ( size(listout,2)>=5 ),  listout(:,5) = 1:size(listout,1); end;
