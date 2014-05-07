% main_gentextsegdata
% generate a text file of segmentation parameter data

% requires:
% Part

% SegIndex = segment_getpartsforsubject(Subject, Repository.Classlist, RepEntry, Parts);

initmain;
position_list = {'LLA', 'RLA'};
feature_list = {'phi', 'theta'};

[XData, ClassAsStr, allSegLabels, partoffsets] = prepdata(XSens, XSeg, Part);

fprintf('\n');
for feature = feature_list
    for position = position_list
        fprintf('\n%s: run for part %s, feature: %s, position: %s...', ...
            mfilename, mat2str(Part), feature{:}, position{:});

        % segmentation feature
        swabsignal = XData.Eul{xsens_findassoc(XSeg(Part), position{:})}.(feature{:});
        dlmwrite([XSens.Path 'swab' filesep ...
            'Feature_Part' mat2str(Part) '_' position{:} '_' feature{:} '.txt'], swabsignal);

        % SWAB segmentation
        swabresult = segment_swab(swabsignal, SWABConfig.maxbuffer, SWABConfig.maxcost, SWABConfig.method, [], 2);
        dlmwrite([XSens.Path 'swab' filesep ...
            'Segments_Part' mat2str(Part) '_' position{:} '_' feature{:} '_' swabdb_ident(SWABConfig) '.txt'], swabresult);

    end; % for position
end; % for feature

fprintf('\n%s: Finished.');

