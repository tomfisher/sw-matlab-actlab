function partnrs = repos_findpartfromclass(Repository, Partlist, classids)
% function partnrs = repos_findpartfromclass(Repository, Partlist, classids)
% 
% Find parts out of Partlist using class ID.
% 
% WARNING: This function uses methods from the segmentation toolbox!
% 
% See also:  repos_findpartfromlabels
% 
% Copyright 2008 Oliver Amft

[labellist partoffsets] = repos_getlabellist(Repository, Partlist);

partnrs = Partlist(repos_findpartfromlabels(segment_findlabelsforclass(labellist, classids), partoffsets));

