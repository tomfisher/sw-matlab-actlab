% initmain_CVSectionBounds_Label
% 
% initmain post-processor: set CVSectionBounds to exclude labels
% 
% requires:
labellist_load;  % from initmain
CVBoundLabelSpec;

error('Code abandoned. Not working.');

if ~exist('CVFolds','var'), CVFolds = 10; end;
if ~exist('CVMinLabelSize','var'), CVMinLabelSize = 0; end;
if CVMinLabelSize>=inf, CVMinLabelSize = floor(partoffsets(end)/CVFolds); end;

% create initial split
rmlabels = segment_findlabelsforclass(labellist_load, CVBoundLabelSpec);
CVSectionBounds = segment_distancejoin([labellist(:,1:2); rmlabels(:,1:2)]);
dataslices = segment_createsplit(partoffsets(end), CVFolds, CVSectionBounds);


dataslices = [];
for i = 1:size(dataslices_init,1)
    tmp = segment_remove(dataslices_init(i,:), rmlabels);
    if ~isempty(tmp),  dataslices = [dataslices; tmp]; end;
end;

% remove any min size slices
dataslices = segment_sizeprune(dataslices, CVMinLabelSize);

CVSectionBounds = dataslices;


% % remove any overlaps with CVBoundLabelSpec
% rmlabels = segment_findlabelsforclass(labellist_load, CVBoundLabelSpec);
% dataslices = segment_remove(dataslices, rmlabels);
% 
% % remove any min size slices
% dataslices = segment_sizeprune(dataslices, CVMinLabelSize);
% 
% CVSectionBounds = dataslices;   