function [TR TE] = classgroupcv(IDList, GroupList, varargin)
% function [TR TE] = classgroupcv(IDList, GroupList, varargin)
%
% Create a CV partitioning using idlist as class associations.
% IDList - list of label ids (or observations in rows)
% GroupList  - group id; a group is not splitted.
% 
% Use const training obs size for all classes, NOT CVs.
% Number of CVs is equal to group count. 
%
% Optional parameters:
% TrainTestRatio - Training share for each CV, default=CVFolds-1
% ReturnIdx - Return indices instead of IDList contents, default=true
% ClassCol - column in IDList that provides class info, default=1
% 
% Copyright 2007 Oliver Amft

TR = {}; TE = {};

nIDs = size(IDList,1);
if (nIDs == 0)
	error('Wrong configuration.');
end;

[TrainTestRatio ReturnIdx ClassCol verbose] = process_options(varargin, ...
	'TrainTestRatio', 0, 'ReturnIdx', true, 'ClassCol', 1, 'verbose', 1);

ClassIDs = unique(IDList(:,ClassCol));

if (exist('GroupList','var')~=1) || isempty(GroupList), GroupList = 1:size(IDList,1); end;
if length(GroupList) ~= nIDs, error('Size of IDList and GroupList do not match.'); end;

GroupIDs = unique(GroupList);
CVFolds = length(GroupIDs);

if (TrainTestRatio == 0), TrainTestRatio = CVFolds-1; end;
if (TrainTestRatio ~= CVFolds-1), error('Setting for TrainTestRatio not supported.'); end;

if (verbose), fprintf('\n%s: nIDs=%u, nClasses=%u', mfilename, nIDs, length(ClassIDs)); end;

% % determine size of CV slices (for each class)
% cvslicesize = zeros(1, length(ClassIDs));
% for classnr = 1:length(ClassIDs)
% 	class = ClassIDs(classnr);
% 	classids = length(find(IDList(:,1)==class));
% 	cvslicesize(class) = floor(classids / CVFolds);
% end;
% mincvsize = min(cvslicesize);
% % if (verbose), fprintf(' Train=%u', mincvsize*TrainTestRatio); end;


classgroupsizes = zeros(length(ClassIDs), length(GroupIDs));
%minsizes = zeros(length(ClassIDs), 1);
for classnr = 1:length(ClassIDs)
	class = ClassIDs(classnr);

	% find labels for current class
	IDList_classidx = find(IDList(:,ClassCol)==class);
	if isempty(IDList_classidx), error('No observations for class %u', class); end;
	
	GroupList_class = GroupList(IDList_classidx);
	
	% find all groups for this class
    if any(unique(GroupList_class)~=GroupIDs), error('No observations for oner group in class %u', class); end;
    
    % find and save minimum group size of all groups in all classes
    for groupnr = 1:length(GroupIDs)
        classgroupsizes(classnr, groupnr) = length(find(GroupList_class == GroupIDs(groupnr)));        
    end; % for groupnr
    
    % find the smallest cv slice (worst case)
%     tmp = sort(classgroupsizes(classnr,:));
%     minsizes(classnr) = tmp(1:TrainTestRatio);
end; % for classnr	
% mincvsize = min(minsizes);



% create a list for CV that contains groups only
[cTR cTE] = classcv(ones(length(GroupIDs),1), 'CVFolds', CVFolds, 'ReturnIdx', true);


for classnr = 1:length(ClassIDs)
	class = ClassIDs(classnr);
	% create a list for CV that contains groups only 
	% all labels within one group are represeted as one entry
	% that will not be splitted
	IDList_classidx = find(IDList(:,ClassCol)==class);
	GroupList_class = GroupList(IDList_classidx);


	% translate from selectlist (group ids) to IDList entries
	% Depending on size of group, mapping will result in variable training
	% sizes. This is corrected here to the min. group size by random
	% sampling.
	%mincvsize = floor(sum(groupcounts_sorted)/CVFolds);
	for cvi = 1:CVFolds
		
		tmp_tr = []; tmp_te = [];
        trgroups = false(length(GroupIDs),1);
		for groupnr = 1:length(GroupIDs)
			group = GroupIDs(groupnr);

            trgroups(groupnr) = (any(cTR{cvi}{1}==groupnr));
			tmp_tr = [ tmp_tr; IDList_classidx( GroupList_class == (group * any(cTR{cvi}{1}==groupnr)) ) ];
			tmp_te = [ tmp_te; IDList_classidx( GroupList_class == (group * any(cTE{cvi}{1}==groupnr)) ) ];
		end; % for groupnr
		TR{cvi}{class} = tmp_tr;
		TE{cvi}{class} = tmp_te;

		% crop if too many observations, randomly select labels
        mincvsize = min( sum(classgroupsizes(:, trgroups),2) );
		if (size(TR{cvi}{class},1) > mincvsize)
			randsel = randperm(size(TR{cvi}{class},1));
			TR{cvi}{class}= TR{cvi}{class}(randsel(1:mincvsize),:);
		end;

		if (verbose>1)
			fprintf('\n%s: Class %u: CV slice %u, train: %u, test: %u (Grouped)', mfilename, class, cvi, ...
				length(TR{cvi}{class}), length(TE{cvi}{class}) );
		end;

		% translate into IDList elements OR return indices only
		if (ReturnIdx == false)
			TR{cvi}{class} = IDList(TR{cvi}{class},:);
			TE{cvi}{class} = IDList(TE{cvi}{class},:);
		end;
		
		TR{cvi} = col(TR{cvi}); TE{cvi} = col(TE{cvi}); 
	end; % for cvi

	if (verbose)
		fprintf('\n%s: Class %u: CV=1: Train=%u Test=%u,   CV=%u: Train=%u Test=%u', ...
			mfilename, class, length(TR{1}{class}), length(TE{1}{class}), cvi, length(TR{cvi}{class}), length(TE{cvi}{class}) ); 
	end;
end; % for class





% % determine size of CV slices (for each class)
% cvslicesize = zeros(1, length(ClassIDs));
% for class = ClassIDs
% 	IDList_classidx = find(IDList==class);
% 	nIDs_class = length(IDList_classidx);
% 	cvslicesize(class) = floor(nIDs_class / CVFolds);
% end;
% 
% if any(cvslicesize==0), error('No observations for class %u', find(cvslicesize==0)); end;
