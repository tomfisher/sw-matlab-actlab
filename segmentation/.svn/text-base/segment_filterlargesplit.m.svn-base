function dataslices = segment_filterlargesplit(slices, classseglist, MaxPartitionSkew)
% function dataslices = segment_filterlargesplit(slices, classseglist, MaxPartitionSkew)
% 
% Filter large splits from CV
% 
% Copyright 2009 Oliver Amft

dataslices = slices;

tsize = zeros(1, size(dataslices,1));

% count nr of sections in slices
for i = 1:size(dataslices,1), tsize(i) = sum(segment_findincluded(dataslices(i,:), classseglist)); end;

% sort section counts, largest first
[tsize_sorted, tidx] = sort(tsize, 'descend');

% check whether 1st and 2nd differ in size by more than MaxPartitionSkew
if tsize_sorted(1)*MaxPartitionSkew > tsize_sorted(2)
    warning('matlab:segment_filterlargesplit', 'MaxPartitionSkew triggered.')
    % adapt partition: split large slice at half of its sections
    tsegs = segment_getincluded(dataslices(tidx(1),:), classseglist, 'RemoveBase', false);
    newbound = tsegs(floor(size(tsegs,1)*0.5),2);

    if tidx(1) == size(dataslices,1) % determine if last slice
        dataslices(tidx(1), 1) = newbound+1; dataslices(tidx(1)-1, 2) = newbound;
    else
        dataslices(tidx(1), 2) = newbound; dataslices(tidx(1)+1, 1) = newbound+1;
    end;
end;
