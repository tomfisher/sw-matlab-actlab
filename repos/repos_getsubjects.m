function SubjectList = repos_getsubjects(Repository, Partlist)
% function SubjectList = repos_getsubjects(Repository, Partlist)
%
% Retrieve subject names from Partlist
% 
% Copyright 2007 Oliver Amft

% changelog
% mk, 2oo7o31o: 
%   * bugfix: assert row vector for Partlist
%   * changed sort(unique(SubjectList)) to unique(SubjectList) since unique
%   already returns a sorted array in ascending order
 
 
SubjectList = {};
Partlist = Partlist(:)';

for part = Partlist
    %if (~test('DataSeg(Index)')) | (isempty(DataSeg(Index).Subject)) continue; end;

    subject = repos_getfield(Repository, part, 'Subject');
    if isempty(subject), continue; end;
    
    SubjectList = {SubjectList{:} subject};
end;

SubjectList = unique(SubjectList);
