function segsize = segment_size(seg)
% function segsize = segment_size(seg)
% 
% Return segment size in points
% 
% Copyright 2004 Oliver Amft

if isempty(seg), segsize = 0; return; end;

segsize = seg(:,2)-seg(:,1)+1;


