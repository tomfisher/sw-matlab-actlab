% main_tb_gensubjectdata
%
% Export a text file from subjectwise data
% Export path is: Repository.Path/CRNTOOLBOX

% requires
% (Partlist)
Subject;
SimSetID; % to create several files (e.g. different features)
% (TargetClasses)
% (FeatureString)
% (DSSet)
% (Delimiter)
% (LimitSegments)

initdata;

if (exist('Partlist', 'var') ~=1)
    Partlist = repos_getpartsforsubject(Repository, Repository.UseParts, Subject);
end;

if (exist('FeatureString', 'var') ~=1)
    FeatureString = {
        'RLAaccx_value', 'RLAaccy_value', 'RLAaccz_value', ...
        'RLAgyrx_value', 'RLAgyry_value', 'RLAgyrz_value', ...
        'RLAmagx_value', 'RLAmagy_value', 'RLAmagz_value', ...
        };
else
    if (~strfind(FeatureString{1}, '_value'))
        fprintf('\n%s: Expanding FeatureString...', mfilename);
        oldFeatureString = FeatureString;
        for f = 1:length(FeatureString)
            FeatureString{f} = [ FeatureString{f} '_value' ];
        end;
    end;
end;

if (exist('DSSet', 'var') ~=1)
    DSSet.EMG.SampleRate = 128;
    DSSet.WAV.SampleRate = 4096;
    DSSet.XSENS.SampleRate = 100;
end;
if (exist('Delimiter','var') ~=1) Delimiter = ','; end;
if (exist('LimitSegments','var') ~=1) LimitSegments = []; end;

initmain;


fprintf('\n%s: Process data for subject %s...', mfilename, Subject);
fprintf('\n%s: Indices: %s', mfilename, mat2str(Partlist));

% create data struct
DataStruct = makedatastruct(Repository, Partlist, FeatureString, DSSet);
SampleRate = cla_getmarkersps(Repository, Partlist(1), 'singlesps', true);


% create a file for each data stream
for stream = 1:length(DataStruct)
    fprintf('\n%s: Create feature matrix ...', mfilename);
    datasize = fb_getdatasize(DataStruct, 'SampleRate', SampleRate); %size(DataStruct.data,1);

    % create feature matrix
    thisfeatures = makefeatures([1 datasize], DataStruct, 'swmode', 'cont');

    % add labeling information
    seglist = segment_resample(allseglist, SampleRate, DataStruct(stream).SampleRate);
    labels = col(segments2labeling(seglist, datasize));
    thisfeatures = [thisfeatures labels];

    % remove data again
    extractlist = [];
    if isempty(LimitSegments)
        extractlist = [];
    else
        for (class = thisTargetClasses)
            classseglist = segment_findlabelsforclass(seglist, class);
            extractlist = [extractlist; classseglist(LimitSegments+1:end,:)];
        end;
    end;
    extractlist = find(segments2labeling(extractlist, datasize) > 0);
    thisfeatures(extractlist, :) = [];
    newseglist = labeling2segments(thisfeatures(:,end));
    
    % correct variables
    seglist = newseglist;
    datasize = size(thisfeatures,1);
    

    % compose feature string list
    %thisfeatures_str = [fb_getsources(FeatureString), {'CLASS'}];
    thisfeatures_str = [FeatureString, {'CLASS'}];

    % create data file
    filename = dbfilename(Repository, 'prefix', DataStruct(stream).Name,  'suffix', SimSetID, ...
        'subdir', 'CRNTOOLBOX', 'globalpath', Repository.Path, 'extension', 'data.txt');
    fprintf('\n%s: Write featues file: %s...', mfilename, filename);
    dlmwrite(filename, thisfeatures, Delimiter);

    % create info file
    filename = dbfilename(Repository, 'prefix', DataStruct(stream).Name,  'suffix', SimSetID, ...
        'subdir', 'CRNTOOLBOX', 'globalpath', Repository.Path, 'extension', 'info.txt');
    fprintf('\n%s: Write information file: %s...', mfilename, filename);
    filewrite('c s', filename, ...
        '# Data dump information file', ...
        ['# File generated with ' mfilename ', at ' datestr(now)], ...
        '# Oliver Amft, oam@ife.ee.ethz.ch', '');
    filewrite('a pv', filename, ...
        'SimSetID', SimSetID, 'string', ...
        'TargetClasses', mat2str(thisTargetClasses), 'string', ...
        'Partlist', mat2str(Partlist), 'string', ...
        'Classlist', cell2str(Classlist, ', '), 'string', ...
        'Datasize', datasize, 'int', ...
        'SampleRate', DataStruct(stream).SampleRate, 'int', ...
        'TotalLabels', size(seglist,1), 'int', ...
        'ClassLabels', mat2str(cellfun('size', segments2classlabels(length(Classlist), seglist),1)), 'string', ...
        'Delimiter', ['''' Delimiter ''''], 'string' );

    tmpstr = sprintf('%u: %s', 0, thisfeatures_str{1});
    for i = 2:length(thisfeatures_str)
        tmpstr = [ tmpstr sprintf('\n%u: %s', i-1, thisfeatures_str{i}) ];
    end;
    filewrite('a s', filename, ...
        '# Feature reference (number=column in data file):', tmpstr, ...
        '# End of feature reference');

    if isempty(seglist)
        tmpstr = '';
    else
        tmpstr = sprintf('%s', num2str(seglist(1,:)));
        for i = 2:size(seglist,1)
            tmpstr = [ tmpstr sprintf('\n%s', num2str(seglist(i,:))) ];
        end;
        filewrite('a s', filename, '', ...
            '# Label list: begin end length (in samples), class, id, tentative', tmpstr, ...
            '# End of label list');
    end;
end; % for stream

fprintf('\n%s: Done.\n', mfilename);
