% initmain_labellistLengthSelect
%
% Requires:
% MinClassLength
% SampleRate
% labellist_load

if ~exist('MinClassLength', 'var') || isempty('MinClassLength'), error('Variable "MinClassLength" not set!'); end;

% Select target classes
labellist_load = segment_findlabelsforclass(labellist_load, Repository.TargetClasses);
% Select labels according to value of MinClassLength
labellist_load = labellist_load(labellist_load(:,3) >= MinClassLength*SampleRate, :);
% Apply class merge specifications
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load);