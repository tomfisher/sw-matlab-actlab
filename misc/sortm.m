function [sortedlist sortidx] = sortm(inlist, varargin)
% function [sortedlist sortidx] = sortm(inlist, varargin)
% 
% Alternative sort methods
% 
% OAM REVISIT: mode='alternate' not fully functioning!

[Mode] = process_options(varargin, 'Mode', 'alternate');

[nrows ncols] = size(inlist);

switch lower(Mode)
	case {'alternate', 'alt'}
		if (ncols>1), error('Parameter inlist must be one column.'); end;
		% inlist:    1 1 1 1 1 1 2 2 2 2 4 4 4 5 5 5 5 5 5 5 5
		% inlistid: 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
		% idcountd: 1: 6, 2: 4, 4: 3, 5: 8
		% newlist: 1 2 4 5 1 2 4 5 1 2 4 5 1 2 5 1 5 1 5 5 5
		allids = unique(inlist);

		% find id counts for all different ones
		idcounts = zeros(length(allids),1); idpos = zeros(length(allids),1);
		for ids = 1:length(allids)
			idcounts(ids) = length(find(inlist == allids(ids)));
			idpos(ids) = find(inlist == allids(ids),1);
		end;
		
		sortidx = zeros(length(inlist),1);

		for ids = 1:length(allids)
			for i = ids:length(allids):length(inlist)
				idcounts(ids) = idcounts(ids) -1;
				if (idcounts(ids) < 0), break; end;
				
				sortidx(i) = idpos(ids)+idcounts(ids);
			end;
		end;
		
		sortidx(sortidx == 0) = [];
		sortedlist = inlist(sortidx,:);

% 		idx = 1;
% 		for i = 1:length(inlist)
% 			while (idcounts(idx) <= 0), idx = idx + 1; end;
% 			
% 			sortidx(i) = idx;
% 			idx = idx + 1;
% 		end;
			
	case {'randperm', 'rand'}
		% OAM REVISIT: Has inlist always 1..length(inlist) values?
		if (ncols>1), error('Parameter inlist must be one column.'); end;
		sortidx = randperm(length(inlist));
		sortedlist = inlist(sortidx,:);
		
	case 'hierarchy'  % performs row sequentially, default sort dir
		[dummy sortidx] = sort(inlist(:,1), 'descend');
		inlist = inlist(sortidx(:,1),:);
		for col = 2:ncols
			checked = zeros(nrows,1);
			while ~all(checked)
				tosort = (inlist(find(checked==0,1),col-1) == inlist(:, col-1));
				%if sum(tosort)==1, checked = checked | tosort; continue; end;
				[dummy tmpidx] = sort(inlist(tosort, col), 'ascend'); ftosort = find(tosort);
				inlist(tosort,:) = inlist(ftosort(tmpidx),:);
				sortidx(tosort) = ftosort(tmpidx);
				checked = checked | tosort;
			end;
		end;
		sortedlist = inlist;
end;

