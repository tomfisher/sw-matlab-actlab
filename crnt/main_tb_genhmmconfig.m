% main_tb_genhmmconfig
% extract HMM configuration, convert it into binary toolbox format

% requires
% Subject
% fidx
SimSetID = [Subject fidx];
initmain;

hmmsim_filename = dbfilename(Repository.RepEntries, [], ['HMMSIM_' SimSetID], '', 'SIMCLF');
if ~exist(hmmsim_filename)
    fprintf('\n%s: File %s does not exists.', mfilename, hmmsim_filename);
    fprintf('\n');
    error;
end;
load(hmmsim_filename, 'partlist', 'ClassAsStr', 'HMMConfig');

tbhmm_filename = [Repository.Path 'swab' filesep 'martin' filesep 'hmmparams_' SimSetID '.conf'];
fprintf('\n%s: Write %s...', mfilename, tbhmm_filename);

% number of models
filewrite('w b', tbhmm_filename, max(size(ClassAsStr)), 'int32');

% write model config
for class = 1:max(size(ClassAsStr))
    classtr = ClassAsStr{class};
    % write order:
    % number of states
    % number of features
    % initial state distribution (TRANSPOSE VECTOR!)
    % state transition matrix (TRANSPOSE MATRIX!)
    % covariance matrices (TRANSPOSE MATRICES!)
    % mean vectors (TRANSPOSE MATRIX!)

    filewrite('a b', tbhmm_filename, ...
        HMMConfig.eval.(classtr).States, 'int32', ...
        max(size(HMMConfig.allfeaturestr)), 'int32', ...
        HMMConfig.eval.(classtr).trainedmodel.prior', 'float32', ...
        HMMConfig.eval.(classtr).trainedmodel.transmat', 'float32');

    for state = 1:HMMConfig.eval.(classtr).States
        filewrite('a b', tbhmm_filename, ...
            HMMConfig.eval.(classtr).trainedmodel.sigma(:,:,state)', 'float32');
    end; % for state

    filewrite('a b', tbhmm_filename, ...
        HMMConfig.eval.(classtr).trainedmodel.mu, 'float32');
end; % for class

% ---------------------------------------------------------------------

tbstd_filename = [Repository.Path 'swab' filesep 'martin' filesep 'stdparams_' SimSetID];
fprintf('\n%s: Write %s...', mfilename, tbstd_filename);

filewrite('w s', tbstd_filename, ...
    'Standardisation & normalisation parameters', '', ...
    ['# file generated with ' mfilename ', at ' datestr(now)], '', ...
    ['# SimSetID: ' SimSetID]);
filewrite('a pv', tbstd_filename, ...
    'features', max(size(HMMConfig.standard_mean)), 'int');

for f = 1:max(size(HMMConfig.standard_mean))
    filewrite('a pv', tbstd_filename, ...
        ['mean_' num2str(f)], HMMConfig.standard_mean(f)', 'float32', ...
        ['sigma_' num2str(f)], HMMConfig.standard_sigma(f)', 'float32');
    
    filewrite('a pv', tbstd_filename, ...
        ['shift_' num2str(f)], HMMConfig.snorm_shift(f)', 'float32', ...
        ['norm_' num2str(f)], HMMConfig.snorm_value(f)', 'float32');
end; % for f

tbfeat_filename = [Repository.Path 'swab' filesep 'featuresets' filesep 'FeatureStr.txt'];
fid = fopen(tbfeat_filename, 'r'); dummy = textscan(fid, '%s %s'); fclose(fid); XDataMatStr = dummy{2};

for f = 1:max(size(HMMConfig.allfeaturestr))
    channel = strmatch(upper(HMMConfig.allfeaturestr{f}), upper(XDataMatStr))-1;
    if isempty(channel)
        fprintf('\n%s: No match found for feature: %s', mfilename, HMMConfig.allfeaturestr{f});
        continue;
    end;

    filewrite('a s', tbstd_filename, ['# ' HMMConfig.allfeaturestr{f}]);
    filewrite('a pv', tbstd_filename, ...
        ['feature_' num2str(f)], num2str(channel), 'string');
end; % for f

fprintf('\n%s: Done.\n', mfilename);
