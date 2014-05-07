% initmain_samplesegments
% 
% WARNING: segments2labeling cannot cope with overlapping labels in the segment list.
% Thus, MergeClassSpec is applied here to labellist_load. Some further routines use labellist_load
% 
% Copyright 2007 Oliver Amft

[labellist_load thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');

% convert labellist to samplewise seglist
labellist_backup = labellist_load;
labellist_load = labeling2samplesegments(segments2labeling(labellist_backup));


labellist_backup = labellist;
labellist = labeling2samplesegments(segments2labeling(labellist_backup));

clear labellist_backup;
