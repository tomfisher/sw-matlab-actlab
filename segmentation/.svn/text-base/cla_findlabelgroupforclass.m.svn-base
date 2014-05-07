function LGList = cla_findlabelgroupforclass(Repository, classids)
% function LGList = cla_findlabelgroupforclass(Repository, classids)
%
% Find LabelGroups from class number
LGList = {};

if (~test('Repository.LabelGroups')) return; end;


lbgroups = Repository.LabelGroups;
for i = 1:length(lbgroups)
    if isempty(cmpvectors(Repository.(lbgroups{i}), classids)) continue; end;
    
    % found a hit
    LGList = {LGList{:} lbgroups{i}};
end;