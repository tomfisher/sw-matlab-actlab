% initmain_makegreylist
% 
% initmain post-processor: create a greylist from the specified label ids
% 
% 
% requires:
labellist_load;  % from initmain

if ~exist('makegreylist_labelids','var')
	makegreylist_labelids = Repository.Classes(Repository.Classes~=thisTargetClasses);
	warning('initmain_makegreylist:makegreylist_labelids', 'Parameter ''makegreylist_labelids'' not specified.'); 
end;

% automatically exclude thisTargetClasses!
makegreylist_labelids(makegreylist_labelids==thisTargetClasses) = [];

fprintf('\n%s: Greylist settings: thisTargetClasses=%s, labels to use: %s...', mfilename, ...
	mat2str(thisTargetClasses), mat2str(makegreylist_labelids)); 

Greylist = segment_sort(segment_findlabelsforclass(labellist_load, makegreylist_labelids));
fprintf('\n%s: Total greylist size: %u, IDs: %s...', mfilename, size(Greylist,1), mat2str(unique(Greylist(:,4)))); 
