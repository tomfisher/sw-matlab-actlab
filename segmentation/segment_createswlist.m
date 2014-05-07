function seglist = segment_createswlist(windowsize, stepsize, datasize)
% function seglist = segment_createswlist(windowsize, stepsize, datasize)
%
% Create sliding window list
% 
% Copyright 2006 Oliver Amft


seglist = [(1:stepsize:datasize-windowsize+1); (0+windowsize:stepsize:datasize)]';

seglist = segment_createlist(seglist);