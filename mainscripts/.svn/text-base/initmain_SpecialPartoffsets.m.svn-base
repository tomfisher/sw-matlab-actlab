% initmain_SpecialPartoffsets
% 
% initmain post-processor: set SpecialPartoffsets according to first label in CutLabelSpec
% 
% requires:
labellist_load;  % from initmain
CutLabelSpec;

cutlabels = segment_sort(segment_findlabelsforclass(labellist_load, CutLabelSpec),1);

SpecialPartoffsets = [0 cutlabels(1,1)-1];
