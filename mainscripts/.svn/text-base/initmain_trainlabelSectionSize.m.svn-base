% initmain_trainlabelSectionSize
% 
% Create sections of constant size from target (training) labels.
% 
% requires:
% SampleRate
% SectionSize [in sec]
% SectionStep [in sec]

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit below confidence thres during training
if ~exist('SectionStep', 'var'), SectionStep = SectionSize; end;

trainlabellist = segment_findlabelsforclass(labellist_load, Repository.TargetClasses);
trainlabellist(trainlabellist(:,6)<LabelConfThres,:) = [];

windowsize = SectionSize*SampleRate;
windowstep = SectionStep*SampleRate;

newtrainlist = [];
for i = 1:size(trainlabellist,1)
    newtrainlist = [ newtrainlist;  segment_createlist( ...
        segment_createswlist(windowsize, windowstep, segment_size(trainlabellist(i,:))) + trainlabellist(i,1)-1, ...
        'classlist', trainlabellist(i,4),  'conflist', trainlabellist(i,6) ) ];
end;

labellist_load(segment_findequals(labellist_load, trainlabellist, 'CheckCols', [1:4]),:) = [];

labellist_load = segment_sort([ labellist_load; newtrainlist ]);
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load);

fprintf('\n%s: Nr of labels: %u, merged: %u', mfilename, size(labellist_load,1), size(labellist,1));
clear windowsize windowstep trainlabellist newtrainlist;