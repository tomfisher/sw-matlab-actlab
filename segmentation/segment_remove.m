function newseg = segment_remove(segbase, segrm)
% function newseg = segment_remove(segbase, segrm)
%
% Remove segment bounds in segrm from segbase
% 
% WARNING: This code does NOT considers class labels. Hence it does not returns class 0 labels.
% WARNING: This code cannot cope with multiple sections in segbase.
% 
% Example:
%       segment_remove([1 20], [4 7; 12 16])
%       
%      1     3     3     1     1     1
%      8    11     4     1     2     1
%     17    20     4     1     3     1
% 
% Copyright 2009 Oliver Amft

if size(segbase,2)>4  && any(segbase(:,4)==0)
    warning('matlab:segment_remove', 'This code does NOT considers class labels. Hence it does not returns class 0 labels.');
end;

justsection = size(segbase,2)<3;

totalsize = max([segrm(1:2), segbase(1:2)]);
segbasebin = segments2labeling(segbase, totalsize);
for i = 1:size(segrm,1)
    if ~sum(segbasebin) || isempty(segbasebin), break; end;

    segbasebin = segbasebin & ~segments2labeling(segrm(i, 1:2), totalsize);
end;
newseg = labeling2segments(segbasebin, 0);
if justsection && ~isempty(newseg), newseg = newseg(:,1:2); end;
