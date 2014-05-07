function [MapClassSpec labellist] = segment_mergespec2mapspec(MergeClassSpec, labellist)
% function [MapClassSpec labellist] = segment_mergespec2mapspec(MergeClassSpec, labellist)
%
% Convert a MergeClassSpec to a MapClassSpec
%
% example:
% MergeClassSpec = {[41,45], 42, 43, 46, 58};  % rule set to merge class ids
% MapClassSpec = [41, 42, 43, 46, 58];  % rule set to reassign class ids
% 
% Parameter labellist is optional. If provided, labellist is converted by 
% replacing class labels are replaced with the new mapclass labels.
% 
% Copyright 2008 Oliver Amft

MapClassSpec = zeros(1, length(MergeClassSpec));
for class = 1:length(MergeClassSpec)
    if length(MergeClassSpec{class}) > 1
        MapClassSpec(class) = MergeClassSpec{class}(1);
    else
        MapClassSpec(class) = MergeClassSpec{class};
    end;
end;

if exist('labellist','var') && (~isempty(labellist)) && (~isempty(MapClassSpec))
    %     for class = 1:length(MapClassSpec)
    %         labellist(labellist(:,4)==class, 4) = MapClassSpec(class);
    %     end;

    % replace class label with mapclass label
    % this is not the same as segment_classfilter() which deletes classes!
    for class = 1:length(MergeClassSpec)
        for i = 1:size(labellist,1)
            if any(find(MergeClassSpec{class}==labellist(i,4))),  labellist(i, 4) = MapClassSpec(class); end;
        end;
    end;
end;
