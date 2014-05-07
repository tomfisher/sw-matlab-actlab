% main_crnt_mergestreams
% 
% Merge datastreams that have been individually recorded.
% 
% required:
Partlist;           % parts to merge
% InStreamSystems;  % datastreams to merge
% MergedSystem;     % result datastream


initdata;
StartTime = clock;
fprintf('\n%s() start: %s\n', mfilename, datestr(now));

% sensor systems to merge
if ~exist('InStreamSystems', 'var'), 
    fprintf('\n%s: WARNING: No InStreamSystems set, using all systems from Partindex %u.', mfilename, Partlist(1));
    InStreamSystems =  repos_getsystems(Repository, Partlist(1));
    tmp = strmatch( 'CRNT_MERGED', InStreamSystems );
    if ~isempty( tmp ), InStreamSystems(tmp) = []; end;
end;
if ~exist('MergedSystem', 'var')
    if ~isempty( strmatch( 'CRNT_MERGED', repos_getsystems(Repository, Partlist(1)) ) )
        fprintf('\n%s: WARNING: MergedSystem not set, using CRNT_MERGED', mfilename);
        MergedSystem = 'CRNT_MERGED';
    else
        error('Cannot find MergedSystem parameter. Set this before launching.');
    end;
end;
    
    

if ~exist('OutFileType', 'var'), OutFileType = 'mat73';  end;  % output file type, log: ascii, mat: Matlab
if ~exist('DoSave', 'var'), DoSave = true;  end;  % save output file
if ~exist('IntPMethod', 'var'), IntPMethod = 'LastValue';  end;  % interpolation method

% path to database
if ~exist('GlobalPath', 'var'), 
    GlobalPath = Repository.Path;
else
    fprintf('\n%s: GlobalPath = ''%s''', mfilename, GlobalPath);
end;




for Partindex = Partlist
    if any(isemptycell(repos_getsystems(Repository, Partindex))), continue; end;
    allsystems = repos_getsystems(Repository, Partindex);
    if isempty(allsystems), continue; end;
    
    markersps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
    DTable = repos_getdtable(Repository, Partindex, InStreamSystems);

    fprintf('\n%s: Process data set %u, systems %s.', mfilename, Partindex, cell2str(InStreamSystems, ', '));
    
    InStreams = {};  MergedDTable = {};
    for sys = 1:length(InStreamSystems)
        % determine filename and load data
        sourcefile = repos_getfilename(Repository, Partindex, InStreamSystems(sys), 'GlobalPath', GlobalPath);
        fprintf('\n%s: Loading %s...', mfilename, sourcefile);
        [InStreams{sys}, DTable] = repos_prepdata(Repository, Partindex, InStreamSystems{sys}, 'alignment', false);

        % prepare DTable index of all column identifiers
        keepcols = true(1, length(DTable)); 
        keepcols(strmatch('CRNTtime', DTable)) = 0;
        MergedDTable = { MergedDTable{:}, DTable{keepcols} };
    end;
    
    % now merge datastreams
    MergedData = mergestreams(InStreams{:}, 'options', 'IntPMethod', IntPMethod, 'NewSampleDist', 1/markersps*1e6, 'verbose', 1);
    % mergestreams returns a new time axis as first column, declare this here
    MergedDTable = [ {'CRNTtime'}, MergedDTable ];
    % check that column numbers match
    if size(MergedData,2) ~= length(MergedDTable),  error('Number of features does not coincide.'); end;
    
    
    
    % save merged data as one file
    % here we consider the system denoted by MergedSystem
    destfile = repos_getfilename(Repository, Partindex, MergedSystem, 'GlobalPath', GlobalPath);

    fprintf('\n%s: Save dataset %s (PI: %u)...', mfilename, MergedSystem, Partindex);
    SaveTime = clock;
    if DoSave,
        switch lower(OutFileType)
            case 'log'
                save(destfile, '-ascii', '-double', '-tab',  'thisData' );
            case 'mat'
                DataSet = MergedData;  DTable = MergedDTable;   % save what repos_loaddata is expecting
                save(destfile, ...
                    'DataSet', 'markersps', 'DTable', 'InStreamSystems', 'IntPMethod', ...
                    'StartTime', 'SaveTime' );
            case 'mat73'    % save in -v7.3 format
                DataSet = MergedData;  DTable = MergedDTable;   % save what repos_loaddata is expecting
                save(destfile, '-v7.3', ...
                    'DataSet', 'markersps', 'DTable', 'InStreamSystems', 'IntPMethod', ...
                    'StartTime', 'SaveTime' );
            otherwise
                error('Output file type %s not recognised.', OutFileType);
        end;
    else
        fprintf('\n%s: File NOT saved, DoSave=%s', mfilename, mat2str(DoSave));
    end;
end; % for Partindex = Partlist

fprintf('Done.\n');
fprintf('\n%s: Finished. (CPU: %.0fs).\n', mfilename, etime(clock, StartTime));
fprintf('\n%s() run, end: %s\n\n', mfilename, datestr(now));
