% ABANDONNED - - USE main_convertcla.m INSTEAD!
error('DO NOT USE');

% main_correctcla
%
% requires
% Partlist
% (DType)

initdata;
StartTime = clock;
if ~exist('Partlist','var'), Partlist = Repository.UseParts; end;

for Partindex = Partlist
    allsystems = repos_getsystems(Repository, Partindex);
    if isempty(allsystems), continue; end;
    
    fprintf('\n%s: Process CLA file for part %u...', mfilename, Partindex);

%     % load partsize from feature file
%     clear partsize;
%     filename = dbfilename(RepEntry, Partindex, 'Features_Part', [], 'FEATURES');
%     fprintf('\n%s: Loading: %s...', mfilename, filename);
%     load(filename, 'partsize');
%     partsize;
%     fprintf(' partsizes: %s', mat2str(partsize));

    MARKER_VERSION='0.3.2';
    alignshift = 0;
    alignsps = 0;
    markersps =  cla_getmarkersps(Repository, Partindex, 'singlesps', true);

    
    
    % store it in CLA file
    if ~exist('DType','var'), DType = ''; end;
    filename = dbfilename(Repository, Partindex, 'CLA', DType%, 'MARKERDATA', 'globalpath', Repository.Path);
    fprintf('\n%s: Saving: %s...', mfilename, filename);
    SaveTime = clock;
%     save(filename, '-append', 'SaveTime', 'MARKER_VERSION', ...
%         'alignshift', 'alignsps', 'markersps');
end;
fprintf('\n%s: Done.\n', mfilename);
