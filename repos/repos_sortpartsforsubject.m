function [partlist subjects] = repos_sortpartsforsubject(Repository, Partlist)
% function [partlist subjects] = repos_sortpartsforsubject(Repository, Partlist)
%
% Sort partlist according to subjects. Partlist will contain all parts
% supplied, however ordered according to subjects

partlist = []; 
if isempty(Partlist) return; end;

subjects = repos_getsubjects(Repository, Partlist);
Partlist = sort(Partlist);

for s = 1:length(subjects)
    for part = Partlist
        if (strcmp(subjects{s}, repos_getsubjects(Repository, part)))
            partlist = [partlist part];
        end;
    end;
end;
