% main_genswabfromtoolbox
% read in toolbox swab segmentation
% convert it to swab files and write it to DATA/SWAB

% requires:
% Part
% SWABConfig

% initmain;
feature_list = {'phi', 'theta'};
position_list = {'LLA', 'RLA'};

fprintf('\n');

for feature = feature_list
    SWABConfig.feature = feature{:};
    SegIndex = Part;
    swab_filename = dbfilename(RepEntry, SegIndex, ['SWAB_' SWABConfig.feature], swabdb_ident(SWABConfig), 'SWAB');
    if exist(swab_filename) && (exist('forcewrite')~=1)
        fprintf('\nFile %s exist already and forcewrite not used, skipping!', swab_filename);
        fprintf('\n');
        continue;
    end;

    clear SegTS;
    for position = position_list
        fprintf('\n%s: run for part %s, feature: %s, position: %s...', ...
            mfilename, mat2str(Part), feature{:}, position{:});

        % SWAB segmentation
        SegTS.(cell2mat(position)) = dlmread([Repository.Path 'swab' filesep 'swab_toolbox_SS30RSLP0.1' filesep ...
            'Segments_Part' mat2str(Part) '_' position{:} '_' feature{:} '.txt']);
    end; % for position

    % compatibility isses...
    fprintf('\n%s: process compatibility information...', mfilename);
    allSegLabels = segment_getlabels(Repository.Classlist, RepEntry, SegIndex);
    fprintf('xsens_getsize()...');
    partoffsets = [0 xsens_getsize(Repository, RepEntry, SegIndex)];
    ClassAsStr = segment_getclass(Repository, SegIndex);

    for class = 1:max(size(allSegLabels))
        SegOV.LLA{class} = segment_countoverlap(allSegLabels{class}, SegTS.LLA);
        SegOV.RLA{class} = segment_countoverlap(allSegLabels{class}, SegTS.RLA);

        if isempty(SegOV.LLA{class}) || isempty(SegOV.RLA{class}) continue; end;

        fprintf('\n%s: Class: %s, position: LLA mean CM per GT segment: %.1f', ...
            mfilename, Repository.Classlist{class}, mean(SegOV.LLA{class}));
        fprintf('\n%s: Class: %s, position: RLA mean CM per GT segment: %.1f', ...
            mfilename, Repository.Classlist{class}, mean(SegOV.RLA{class}));
    end; % for class

    fprintf('\n%s: Saving to DB: %s...', mfilename, swab_filename);
    save(swab_filename, 'SWABConfig', ...
        'SegTS', 'SegOV', ... % 'allSegTS', 'testSegOV',
        'allSegLabels', ...
        'partoffsets', 'ClassAsStr', 'SegIndex'); % , 'XData'
    fprintf('Done.\n');

end; % for feature

fprintf('\n%s: Finished.');

