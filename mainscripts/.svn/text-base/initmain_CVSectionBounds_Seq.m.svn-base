% initmain_CVSectionBounds_Seq
% 
% initmain post-processor: set CVSectionBounds to sequence boundaries
% 
% requires:
labellist_load;  % from initmain

% useful bounds: sequence labels, sync labels (help that PI bounds are seen as smaller sequences)
% labels may overlap with these bounding labels, the bound label start
% point determines the limit. main_spotidentify uses segment_countoverlap
% to determine the labels belonging to a CV slice. Any label that encloses
% the bound label start point will be a member of two CV sets!
%
% OAM REVISIT: in the case of nutrition/fusion gesture labels overlap with
% the sequence labels - this class of labels should be handled specially in
% main_spotfidentify
boundlabels = segment_sort(segment_findlabelsforclass(labellist_load, [Repository.SeqClasses Repository.SyncClasses]));

% OAM REVISIT: This will create sections spanning PI boundaries
CVSectionBounds = zeros(size(boundlabels,1)-1, 2);
for i = 1:size(boundlabels,1)-1
	CVSectionBounds(i,:) = [ boundlabels(i,1) boundlabels(i+1,1) ];
	% This is a hack!
	% OAM REVISIT: Do not set boundlabels(i+1,1) -1 as end point, since the
	% sequence labels are needed in both CV sets!
	% This results in a label copy - uncritical as long as these are not
	% part of target classes.
end;

clear i boundlabels;