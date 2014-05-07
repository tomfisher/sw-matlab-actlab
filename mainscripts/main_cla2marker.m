% main_cla2marker
%
% Script to convert old CLA label file format (< version 1.2.0) to MARKER label file format (>= 1.2.0)
%
% requires:
%   Partlist
%
% Copyright 2008 Oliver Amft

% Changelog
% 20090319 - Replaced 'dbfilename' with 'repos_makefilename' (mk)

initdata;
StartTime = clock;

if ~exist('Partlist','var'), Partlist = Repository.UseParts; end;
if ~exist('YesDoWrite','var'), YesDoWrite = false; end;
fprintf('\n%s: YesDoWrite=%s', mfilename, mat2str(YesDoWrite));

for Partindex = Partlist
    allsystems = repos_getsystems(Repository, Partindex);
    if isemptycell(allsystems), continue; end;

    fprintf('\n%s: Process CLA file for part %u...', mfilename, Partindex);


    %filename = dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels');
    filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels');
    if ~exist(filename, 'file')
        fprintf('\n%s: File not found: %s, skipping', mfilename, filename);
        continue;
    end;

    lfile = load(filename);
    
    if ~isfield(lfile, 'datatypes')
        lfile.datatypes = repos_getsystems(Repository, Partindex);
        fprintf('\n%s: Field datatypes not found. Assuming Repository setting: %s', mfilename, cell2str(lfile.datatypes));
    end;

%     if length(cellstrmatch(lfile.datatypes, allsystems)) ~= length(allsystems)
%         error('Datatypes and allsystems do not coincide');
%     end;

    lfile.datatypes = allsystems;
    lfile.plottypes = lfile.datatypes;
%     lfile = rmfield(lfile, 'datatypes');

    lfile.alignshift = lfile.alignshift(1);
    lfile.alignsps = lfile.alignsps(1);
    lfile.markersps = lfile.markersps(1);
    lfile.partsize = lfile.partsize(1);
    
    
    lfile.SaveTime = clock;
    lfile.MARKER_VERSION='1.2.0 CLA2MARKER';

    % store it in CLA file
    % (mk) MODIFY
    %filename = dbfilename(Repository, 'indices', Partindex, 'prefix', 'MARKER', 'subdir', 'labels');
    filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKER', 'subdir', 'labels');
    if (YesDoWrite == true)
        fprintf('\n%s: Saving: %s...', mfilename, filename);

        save(filename, '-struct', 'lfile');
    else
        fprintf('\n%s: Simulate saving: %s...', mfilename, filename);
    end;
end;

fprintf('\n%s: Partlist: %s', mfilename, mat2str(Partlist));
if (YesDoWrite)
    fprintf('\n%s: Setting YesDoWrite to false.', mfilename);
    YesDoWrite = false;
else
    fprintf('\n%s: Simulated only, use YesDoWrite = true to write.', mfilename);
end;
fprintf('\n%s: Done.\n', mfilename);
