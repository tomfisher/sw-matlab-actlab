% main_tb_gensectiontext
% generate a text file of xsens sensor data readings for sections
% temp solution for HMM testing in CRN

% requires
% Subject
% fidx
% NoSections

SimSetID = [Subject fidx];
if (exist('NoSections')~=1) NoSections = 10; end;


initmain;
fprintf('\n%s: Process data for subject %s...', mfilename, Subject);
hmmsim_filename = dbfilename(Repository.RepEntries, [], ['HMMSIM_' SimSetID], '', 'SIMCLF');
load(hmmsim_filename, 'ClassAsStr', 'HMMConfig');

partlist = segment_getpartsforsubject(Subject, Repository.Classlist, RepEntry, Repository.ActiveRange);
fprintf('\n%s: Indices: %s...', mfilename, mat2str(partlist));

partoffsets = segment_getpartoffsets(Repository.RepEntries, partlist);
allSegLabels = segment_getlabels(Repository.Classlist, Repository.RepEntries, partlist, partoffsets);

% for extracting data
[XData, ClassAsStr, ro_allSegLabels] = ...
    preplabeldata(Repository, partlist, partoffsets, allSegLabels, SampleRate);

DataStruct.XData = XData;
DataStruct.RepEntry = RepEntry(partlist(1));
XDataMatStr = HMMConfig.allfeaturestr;

fprintf('\n%s: Launch classification...', mfilename);
classlist = matsel(classlabels2segments(ro_allSegLabels(TargetClasses)),':,4');
HMMConfig.testSegLabels = matsel(classlabels2segments(ro_allSegLabels(TargetClasses)),':,1:2');
HMMConfig.data = DataStruct;
HMMConfig = main_hmmtesting(HMMConfig, classlist, 1);

for class = TargetClasses
    for seg = 1:NoSections
        fprintf('\n%s: Create XDataMat for section %u (class %s)...', ...
            mfilename, seg, Repository.Classlist{class});

        XDataMat = xsens_getfeatures(XDataMatStr, ro_allSegLabels{class}(seg,:), DataStruct);
        XDataMat = standardize(XDataMat, HMMConfig.standard_mean, HMMConfig.standard_sigma);
        XDataMat = shiftnorm(XDataMat, HMMConfig.snorm_shift, HMMConfig.snorm_value);
        XDataMat = clipping(XDataMat, repmat((HMMConfig.featureclip>0), size(XDataMat,1), 1), 1);
        XDataMat = XDataMat';
        
        filename = [Repository.Path 'swab' filesep 'martin' filesep 'XSens_HMMF_' Subject '_Class' Repository.Classlist{class} '_Seg' mat2str(seg) '.txt'];
        dlmwrite(filename, XDataMat);
    end; % for seg
    

    % ---------------------------------------------------------------------

    tbll_filename = [Repository.Path 'swab' filesep 'martin' filesep 'logliks_' Subject '_Class' Repository.Classlist{class} '.txt'];
    fprintf('\n%s: Write loglik file %s...', mfilename, tbll_filename);

    filewrite('w s', tbll_filename, ...
        'Logliks for isolated sections', '', ...
        ['# file generated with ' mfilename ', at ' datestr(now)], '', ...
        ['# SimSetID: ' SimSetID]);
    filewrite('a pv', tbll_filename, ...
        'sections', NoSections, 'int');

    for i = 1:NoSections
        filewrite('a pv', tbll_filename, ...
            ['loglik__' num2str(i)], HMMConfig.hmm_loglik{class}(i,:), 'float');
    end; % for i
end; % for class


% ---------------------------------------------------------------------

tbstat_filename = [Repository.Path 'swab' filesep 'martin' filesep 'XSens_HMMF_' Subject 'Str.txt'];
% fid = fopen(tbstat_filename, 'w');
% for i = 1:max(size(XDataMatStr))
%     fprintf(fid, '%u: %s\n', i-1, XDataMatStr{i});
% end;
% fclose(fid);
delete(tbstat_filename);
for i = 1:max(size(XDataMatStr))
    filewrite('a pv', tbstat_filename, ...
        ['feature_' num2str(i)], XDataMatStr{i}, 'string');
end;

% ---------------------------------------------------------------------

filewrite('a pv', tbstat_filename, ...
    'confusion', HMMConfig.confusion, 'int', ...
    'falses', HMMConfig.stats.falses, 'int', ...
    'precision', HMMConfig.stats.precision, 'float', ...
    'recall', HMMConfig.stats.recall, 'float');

fprintf('\n%s: Done.\n', mfilename);
