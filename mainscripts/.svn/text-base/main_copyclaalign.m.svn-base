% main_copyclaalign.m
%
% Copy CLA alignment from CLA basefile to specific LabelGroup files
% affected variables:
% alignshift
% alignsps
%
% requires
Partlist;

if (exist('LabelGroup','var') ~=1) LabelGroup = '*'; end;

if (exist('YesDoWrite','var') ~=1) YesDoWrite = false; end;

for Partindex = Partlist
    fprintf('\n%s: Process CLA file for part %u...', mfilename, Partindex);

    % basefile 
    fnames = cla_getlabelgroupfiles( ...
        dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels'), ...
        'LabelGroup', '');
    basefile = fnames{end};

    % fetch LabelGroup files
    fnames = cla_getlabelgroupfiles( ...
        dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels'), ...
        'LabelGroup', '*');
    % remove basefile from list
    fnames(end) = [];
    
    if isempty(fnames)
        fprintf('\n%s: Nothing to do for part %u, skipping.', mfilename, Partindex);
    end;
    
    
    % load alignment from basefile
    load(basefile, 'alignshift', 'alignsps');
    
    SaveTime = clock;
    MARKER_VERSION='0.5.2 (WIP) copyclaalign';

    % store it in CLA file
    for fn = 1:length(fnames)
        fprintf('\n%s:     Processing file %s...', mfilename, fnames{fn});
        if (YesDoWrite == true)
            fprintf('\n%s: Saving: %s...', mfilename, filename);
            save(fname{fn}, '-append', ...
                'alignshift', 'alignsps', ...
                'SaveTime', 'MARKER_VERSION');
        else
            fprintf('\n%s: alignshift: %s, alignsps: %s', mfilename, mat2str(alignshift), mat2str(alignsps));
        end;
    end;
end; % for Partindex

if (YesDoWrite)
    fprintf('\n%s: Setting YesDoWrite to false.', mfilename);
    YesDoWrite = false;
else
    fprintf('\n%s: Simulated only, use YesDoWrite = true to write.', mfilename);
end;
fprintf('\n%s: Done.\n', mfilename);
