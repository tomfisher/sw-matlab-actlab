% initmain_FilterLabels
% 
% requires:
FilterLabelSpec;
% FilterLabelSpecMode;
if ~exist('FilterLabelSpecMode', 'var'), FilterLabelSpecMode = 'exclude'; end;

fprintf('\n%s: Processing FilterLabelSpec=%s at mode: %s...', ...
    mfilename, mat2str(FilterLabelSpec), FilterLabelSpecMode);

totallabelmarks = 0;  labelmarks = false(size(labellist_load,1),1);
for i = 1:length(FilterLabelSpec)
    % Select filterlabels
    filterlabels = segment_findlabelsforclass(labellist_load, FilterLabelSpec(i));
    labelmarks = labelmarks | segment_markincluded(filterlabels, labellist_load);
end;
totallabelmarks = totallabelmarks + sum(labelmarks);

if strcmpi(FilterLabelSpecMode, 'exclude')
    labellist_load(labelmarks, :) = [];
    fprintf(' removed %u labels, left: %u', totallabelmarks, size(labellist_load,1));
else
    % include these ones
    fprintf(' included %u labels, removed: %u', totallabelmarks, size(labellist_load,1));        
    labellist_load = labellist_load(labelmarks, :);
end;
    

% Apply class merge specifications
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load);

clear filterlabels totallabelmarks labelmarks i;