% main_labelsizehist
% 
% Determine histogram of label size (critical for size-adaptive spotting).
% Find largest labels and determine PI and position therein
% 
% Copyright 2008-2009 Oliver Amft

% requires:
Partlist;
MergeClassSpec;
% AcceptSizeRatio;
% LabelConfThres;

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit labels below confidence thres during training
fprintf('\n%s: LabelConfThres=%.1f', mfilename, LabelConfThres);

if ~exist('AcceptSizeRatio','var'), AcceptSizeRatio = 1.4; end;  % size acceptance limit
fprintf('\n%s: AcceptSizeRatio=%.1f', mfilename, AcceptSizeRatio);

clear labellist_load; initmain; labellist_load;  % from initmain
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');


% guess segmentation config for each class
% initdata; 
% if ~exist('SegConfig','var') || ~isfield(SegConfig, 'Name'), 
%     clear SegConfig;
%     SegConfig.Name = 'FIX8'; 
% end;  
% % initmain_segconfig_setup;
% fprintf('\n%s: SegConfig.Name=%s', mfilename, SegConfig.Name);
% initmain_segconfig; % enable if SegConfig exists


for classnr = 1:length(thisTargetClasses)
	classlabellist = segment_findlabelsforclass(labellist(labellist(:,6)>=LabelConfThres,:), thisTargetClasses(classnr));
	[h hbounds] = hist(segment_size(classlabellist));

	fprintf('\n%s: Size histogram for class   => %u: ''%s'' <=', mfilename, ...
        thisTargetClasses(classnr), Repository.Classlist{thisTargetClasses(classnr)});
	fprintf('\n%s: %s', mfilename, mat2str(h));
	
	%ubound = round(median(hbounds)*AcceptSizeRatio); lbound = round(median(hbounds)*(AcceptSizeRatio-1));
	ubound = round(mean(segment_size(classlabellist))*AcceptSizeRatio); lbound = round(mean(segment_size(classlabellist))/AcceptSizeRatio);
	ulist = segment_size(classlabellist)>ubound;  llist = segment_size(classlabellist)<lbound;
	fprintf('\n%s: Hist median: %u, accept bound: upper=%u (%u), lower=%u (%u)', mfilename, ...
		round(median(hbounds)), ubound, sum(ulist), lbound, sum(llist));
	
	if (sum(ulist) + sum(llist)) > 20
		fprintf('\n%s: WARNING: Bound exceedings to frequent (%u). Manual analysis needed.', mfilename, ...
            sum(ulist)+sum(llist));
		continue;
	end;
	
	% now identify the bad ones
	idxlist = [ find(ulist); find(llist) ];
	if ~isempty(idxlist), fprintf('\n%s: Bounds exceeding labels: ', mfilename); end;
	for i = row(idxlist)
		fprintf( '\n  %10u %10u %10u %2u %3u %1u', ...
			classlabellist(i,1), classlabellist(i,2), classlabellist(i,3), ...
			classlabellist(i,4), classlabellist(i,5), classlabellist(i,6) );
		
		fprintf('  size ratio: %2.1f%%', segment_size(classlabellist(i,:))/mean(segment_size(classlabellist))*100);
		
		PInr = repos_findpartfromlabels(classlabellist(i,:), partoffsets);
        Partindex = Partlist(PInr);
		fprintf('  - in PI: %u', Partindex);
        pilabellist = segment_sort(repos_getlabellist(Repository, Partindex));
		thislabel = repos_findlabelsforpart(classlabellist(i,:), PInr, partoffsets, 'remove');
		labelpos = find(segment_findequals(pilabellist, thislabel) == 1);
        matchpos = thislabel(1) / (partoffsets(PInr+1)-partoffsets(PInr)) * 100;
		fprintf(' pos: %3u  at %2.1f%% of file.', labelpos, matchpos );
	end;
	if ~isempty(idxlist), fprintf('\n'); end;
    
    
    if (0)  % enable if SegConfig exists
        thisSegConfig = SegConfig(classnr);
        fprintf('\n%s: Class %u: SegConfig.Name: %s, search depth:', mfilename, thisTargetClasses(classnr), lower(thisSegConfig.Name));
        aseglist = cla_getsegmentation(Repository, Partindex, 'SampleRate', SampleRate, ...
            'SegType', thisSegConfig.Name, 'SegMode', thisSegConfig.Mode);
        tmp = segment_countoverlap( classlabellist(classlabellist(:,6)>=LabelConfThres,:), aseglist, -inf );
        SF_searchwindow = [ (min(tmp)+(min(tmp)==0))  (max(tmp)+(max(tmp)==0)) ];
        fprintf(' %s', mat2str(SF_searchwindow));
    end;

    if (0)
        % find labels above size limit (e.g. 3)
        thislabel = classlabellist(tmp>3,:);
        for i = 1:size(thislabel,1)
            matchpos = find(segment_findequals(pilabellist, thislabel(i,:)) == 1);
            fprintf('\n pos: %3u  at %2.1f%% of file.', matchpos, matchpos/size(pilabellist,1)*100 );
        end;
    end;
    
end; % for classnr
fprintf('\n');