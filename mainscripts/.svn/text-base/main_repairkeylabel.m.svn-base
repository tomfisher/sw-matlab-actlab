% main_repairkeylabel

% requires
% Partlist

initdata;

labeltext_trans = { ...
    'Movement', 'G-Movement', ...
    'S-SwallowFluid', 'S-Fluid', ...
    'S-SwallowChewed', 'S-Chewed', ...
    'S-SwallowSemi', 'S-Unspec', ...
    'C-Biskuit', 'C-Biscuit', ...
    'C-Riegel', 'C-Bar', ...
    };
labeltransfrom = 1:2:length(labeltext_trans);

for Partindex = Partlist
    allsystems = repos_getsystems(Repository, Partindex);
    if isempty(allsystems) continue; end;
    clear LabelStruct StartTime;
    
    fprintf('\n%s: Processing part %u...', mfilename, Partindex);
    filename = dbfilename(Repository, Partindex, 'Keylabel', [], 'LABEL');
    try
        load(filename, 'LabelStruct', 'StartTime');
        initlabels = labelstruct2segments(LabelStruct, Repository.Classlist, ...
            repos_getfield(Repository, Partindex, 'SFrq'));
        LabelStruct;
    catch
        fprintf('\n%s: *** Could not find keylabel file %s', mfilename, filename);
        continue;
    end;

%    % convert label texts
%     for idx = 1:length(LabelStruct)
%         label = strmatch(LabelStruct(idx).ClassAsStr, labeltext_trans(labeltransfrom), 'exact');
%         if isempty(label)
%             continue;
%         else
%             % need to translate
%             LabelStruct(idx).ClassAsStr = labeltext_trans{label*2};
%         end;
%     end; % for i
%     
%     fprintf('\n%s: Writing file %s...', mfilename, filename);
%     save(filename, 'LabelStruct', 'StartTime');
end; % for part

fprintf('\n%s: Done.\n', mfilename);
