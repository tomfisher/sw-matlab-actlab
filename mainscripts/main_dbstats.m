% main_dbstats
%
% DB statisitcs

% requires:
% TargetClasses

initdata;

if ~exist('TargetClasses','var'), TargetClasses = Repository.TargetClasses; end;
if ~exist('Partlist','var'), Partlist = Repository.UseParts; end;
if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit labels below confidence thres during training

if ~exist('SubjectList','var'),   SubjectList = repos_getsubjects(Repository, Partlist);   end;

% initialise PIs from SubjectList, if this was set, otherwise this resolves to a nop 
Partlist = repos_getpartsforsubject(Repository, Partlist, SubjectList);


initmain;

fprintf('\n%s: PIs: %s ', mfilename, mat2str(Partlist));
fprintf('\n%s: Total data size: %.1fs (%.2fhours).', mfilename, ...
    roundf(partoffsets(end)/SampleRate,2), roundf(partoffsets(end)/SampleRate/3600,2));
fprintf('\n%s: Total labels: %u', mfilename, size(labellist,1));

% allSegLabels = segments2classlabels(length(thisTargetClasses), labellist);
% fprintf('\n%s: Labels per class: %s.', mfilename, mat2str(cellfun('size',allSegLabels,1)));
fprintf('\n');
fprintf('\n%s: Labels per class', mfilename);
sumtargetlabels = zeros(1, length(thisTargetClasses));
for class = 1:length(thisTargetClasses)
    fprintf('\n%s: Class %u (%s): %u/%u', mfilename, thisTargetClasses(class), Classlist{class}, ...
        sum(segment_getconf(segment_findlabelsforclass(labellist, thisTargetClasses(class)))>=LabelConfThres), ...
		sum(segment_getconf(segment_findlabelsforclass(labellist, thisTargetClasses(class)))<LabelConfThres) );
	
    sumtargetlabels(class) = size(segment_findlabelsforclass(labellist, thisTargetClasses(class)),1);
    
	for subject = 1:length(SubjectList)
		this_Partlist = repos_getpartsforsubject(Repository, Partlist, SubjectList{subject});
		subjectlabels = repos_getlabellist(Repository, this_Partlist);
		subjectlabels = segment_classfilter(MergeClassSpec, subjectlabels);
		fprintf('\n%s:     Subject %s: %u/%u', mfilename, SubjectList{subject}, ....
			sum(segment_getconf(segment_findlabelsforclass(subjectlabels, thisTargetClasses(class))>=LabelConfThres)), ...
			sum(segment_getconf(segment_findlabelsforclass(subjectlabels, thisTargetClasses(class))<LabelConfThres)) );
	end;
end;

fprintf('\n%s: Total labels: in thisTargetClasses: %u', mfilename, sum(sumtargetlabels));
fprintf('\n%s: Label durations', mfilename);
totals = 0;
for class = 1:length(thisTargetClasses)
	thisclasslist = segment_findlabelsforclass(labellist, thisTargetClasses(class));
    if isempty(thisclasslist), continue; end;
    
    fprintf('\n%s: Class %u (%15s): Mean: %.1fs, SD:%.1fs (non-tentative)', mfilename,  thisTargetClasses(class), Classlist{class}, ...
		roundf(mean(segment_size(thisclasslist(segment_getconf(thisclasslist)>=LabelConfThres,:))) / SampleRate,1), ...
		roundf(std(segment_size(thisclasslist(segment_getconf(thisclasslist)>=LabelConfThres,:))) / SampleRate,1));
	
	totals = totals + sum(segment_size(thisclasslist));
end;
fprintf('\n%s: Total event durations: %.1fs (%.2fmin, %.1f%%), including tentatives', mfilename, ...
	roundf(totals/SampleRate,1), roundf(totals/SampleRate/60,2), totals/partoffsets(end)*100);
fprintf('\n%s: NULL ratio: %.1f%%', mfilename, (partoffsets(end)-totals)/partoffsets(end)*100);



% WARNING: Does not consider TargetClasses!
fprintf('\n%s: Labels per subject (TargetClasses NOT considered).', mfilename);
for subject = 1:length(SubjectList)
    this_Partlist = repos_getpartsforsubject(Repository, Partlist, SubjectList{subject});
    subjectlabels = repos_getlabellist(Repository, this_Partlist);
    fprintf('\n%s: Subject: %s, Labels: %u', mfilename, SubjectList{subject}, size(subjectlabels,1));
end;

fprintf('\n');
