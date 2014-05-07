% initmain_labellistClipping
%
% Clip labels by a given length [s] and mode string (e.g. to remove beginning samples of each label)
% 
% Availabe clipping modes are:
%   BEG    - Clipping at the beginning
%   END    - Clipping at the end
%   BEGEND - Clipping at the beginning and end
%
% Labels shorter than the clipping length are discarded.

% Requires:
% SampleRate
% labellist_load

if ~exist('ClippingLength', 'var') || isempty('ClippingLength'), error('Variable "ClippingLength" not set!'); end;
if ~exist('ClippingMode', 'var') || isempty('ClippingLength'), error('Variable "ClippingMode" not set!'); end;

% Select target classes
labellist_load = segment_findlabelsforclass(labellist_load, Repository.TargetClasses);

switch lower(ClippingMode)
    case { 'beg', 'begin' }
        labellist_load(:,1) = labellist_load(:,1) + ClippingLength*SampleRate;
    case { 'end' }
        labellist_load(:,2) = labellist_load(:,2) - ClippingLength*SampleRate;
    case { 'begend', 'beg-end', 'both' }
        labellist_load(:,1) = labellist_load(:,1) + ClippingLength*SampleRate;
        labellist_load(:,2) = labellist_load(:,2) - ClippingLength*SampleRate;
    otherwise
        ...
end;

% Update label length column
labellist_load(:,3) = labellist_load(:,2) - labellist_load(:,1) + 1;
labellist_load = labellist_load(labellist_load(:,3) > 0, :);

% Apply class merge specifications
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load);