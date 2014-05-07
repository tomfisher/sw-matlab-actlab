% main_tb_gensubjecttext
% generate a text file of xsens sensor data readings from subjectwise data

% requires
% Subject
% fidx
% (TargetClasses)
% (SegMarks)
if (exist('SegMarks')~=1) SegMarks = inf; end;

SimSetID = [Subject fidx];
initmain;

fprintf('\n%s: Process data for subject %s...', mfilename, Subject);

partlist = segment_getpartsforsubject(Subject, Repository.Classlist, RepEntry, Repository.ActiveRange);
fprintf('\n%s: Indices: %s...', mfilename, mat2str(partlist));

% partoffsets = segment_getpartoffsets(Repository.RepEntries, partlist);
% allSegLabels = segment_getlabels(Repository.Classlist, Repository.RepEntries, partlist, partoffsets);

[XData, ClassAsStr, allSegLabels, partoffset] = prepdata(Repository, partlist);

fprintf('\n%s: Create XDataMat...', mfilename);

fields = {'Cal', 'Eul'}; sensors = {'RUA', 'CUB', 'RLA', 'LUA', 'LLA'};

XDataMat = []; XDataMatStr = {};
for fn = 1:max(size(fields)) % Cal, Rot...
    if isfield(XData, fields(fn))
        for s = 1:max(size(XData.(fields{fn}))) % Sensors
            if strcmp(sensors{s}, 'CUB') continue; end;
            
            elements = xsens_getstruct(xsens_finddatatype(XData.(fields{fn}){s}));
            for el = 1:max(size(elements))
                if strcmp(elements{el}, 'time') continue; end;
                if strcmp(elements{el}, 'temp') continue; end;
                
                XDataMat = [XDataMat XData.(fields{fn}){s}.(elements{el})];
                XDataMatStr = {XDataMatStr{:} [sensors{s} '_' elements{el}]};
            end;  % for el
        end; % for s
    end;
end; % for fn

% add labeling information
% hmmsim_filename = dbfilename(Repository.RepEntries, [], ['HMMSIM_' SimSetID], '', 'SIMCLF');
% load(hmmsim_filename, 'testGTLabels');
allSegLabels = allSegLabels(TargetClasses);
for class = 1:max(size(TargetClasses))
    if (SegMarks < size(allSegLabels{class},1))
        allSegLabels{class}(SegMarks+1:end,:) = [];
    end;
end;
fprintf('\n%s: Place seg marks for: %s', mfilename, mat2str(cellfun('size', allSegLabels,1)));

seglist = classlabels2segments(allSegLabels(TargetClasses));
XDataMat = [XDataMat col(segments2labeling(seglist, max(size(XDataMat,1))))];
XDataMatStr = {XDataMatStr{:} 'CLASS'};
    

fprintf('\n%s: Write XDataMat...', mfilename);
dlmwrite([Repository.Path 'swab' filesep 'featuresets' filesep 'XSens_Data' '_' Subject '.txt'], XDataMat);
% dlmwrite([Repository.Path 'XSens_Data' '_' Subject '.txt'], XDataMat);

% XDataMatStr
tbfeat_filename = [Repository.Path 'swab' filesep 'featuresets' filesep 'FeatureStr.txt'];
fid = fopen(tbfeat_filename, 'w');
for i = 1:max(size(XDataMatStr))
    fprintf(fid, '%u: %s\n', i-1, XDataMatStr{i});
end;
fclose(fid);

fprintf('\n%s: Done.\n', mfilename);
