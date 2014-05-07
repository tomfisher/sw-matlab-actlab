% main_spotevents
%
% Sppot sections using preprocessed segments (events).
% Processes all classes in parallel (using same features).

% requires
Partlist;
SimSetID;
FeatureString;
Spotters;


VERSION = 'V004';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if ~exist('CVFolds','var'), CVFolds = 10; end;
if ~exist('CVMethod', 'var'), CVMethod = UserMode; end;  % CVMethod = 'intrasubject';
if ~exist('ClassifyMode', 'var'), ClassifyMode = false; end;  % Classify or DataDescription

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit labels below confidence thres during training
if ~exist('PRLabelConfThres','var'), PRLabelConfThres = LabelConfThres; end;   % omit labels below confidence thres for metrics/testing
if ~exist('Greylist','var'), Greylist = []; end;   % omit labels during training

if ~exist('DoLoad', 'var'), DoLoad = true; end;   % load features
if ~exist('DoSave', 'var'), DoSave = true; end;   % save result
if ~exist('DebugMaxCVI', 'var'), DebugMaxCVI = inf; end;   % max CVFolds for debugging
if DebugMaxCVI<inf, fprintf('\n%s: *** CVFolds debugging configured, DebugMaxCVI=%u', mfilename, DebugMaxCVI); end;


% from initmain:
labellist_load;
% initmain has renumbered classes, this is not what we want for spotting
% computation. It would prevent class-specific runs (individual
% featuresets) and result saving/merging of multiple classes.
% if (~exist('ClassIDMode', 'var')), ClassIDMode = 'keepid'; end;
% fprintf('\n%s: ClassIDMode: %s.', mfilename, ClassIDMode);
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');
% if (length(thisTargetClasses)>1), DoLoad = true; end;

if ~exist('mintrainshare','var'),  mintrainshare = 0.1; end;

% guess segmentation config for each class
% initmain_segconfig;


if ~exist('SpottingMethod','var'), SpottingMethod = 'HIST'; end;
if ~exist('SpottingMethod_Params','var'), SpottingMethod_Params = {}; end;
if ~exist('SpottingMode','var'), SpottingMode = 'fixed'; end;
if ~exist('SpottingSearchWindow','var'), SpottingSearchWindow = []; end;  % in sec
if ~exist('SpottingSearchStep','var'), SpottingSearchStep = SpottingSearchWindow; end;  % in sec
fprintf('\n%s: Spotting method: %s, search mode: %s', mfilename, SpottingMethod, SpottingMode);
fprintf('\n%s: CVMethod: %s', mfilename, CVMethod);
if ~exist('SpottingOptimumPrecision','var'), SpottingOptimumPrecision = 0.2; end;

if ~exist('ThresholdMethod_Params','var')
    ThresholdMethod_Params = { 'Model', 'polyxobs', 'Order', 2.0, 'Res', 2e2, 'EndPt', 30 }; 
end;

if ~exist('PRPruneMethod_Params','var'), PRPruneMethod_Params = { 'Enable', 0 }; end;
if ~exist('UseSlice','var'), UseSlice = []; end;  % select a subset of PIs for inclusion (initmain_useslice)
if ~exist('CVSectionBounds','var'), CVSectionBounds = []; end;  % CV cutting bounds, empty=labels are used

SampleRate =  repos_getmarkersps(Repository, Partlist(1), 'singlesps', true);


% ------------------------------------------------------------------------
% Spotting for ALL classes in parallel
% ------------------------------------------------------------------------

if (DoLoad)
    clear DataStruct;
    for i = 1:length(Spotters)
        this_SimSetID = [ Subject, Spotters{i} ];

        [dummy testSLC] = prepallspotresults(Repository, [], {this_SimSetID}, ...
            'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false, ...
            'SpotType', 'SFCV', 'ConvertDistance', false, 'ReloadGT', false, 'verbose',2);

        DTable = regexprep(fb_featurestringprod( Spotters{i}, {'beg', 'end', 'size', 'class', 'count', 'conf'}), '_', '');
        DataStruct(i) =  fb_createdatastruct( ...
            Spotters{i}, testSLC, Repository, Partlist, DTable, FeatureString(i), ...
            SampleRate, SampleRate);
        %classnames = repos_getnamesforclass(Repository, unique(SegmentSet(i).seglist(:,4)));
    end;
    clear this_SimSetID;

    % section size conversion factors
    for  i = 1:length(Spotters)
        DataStruct(i).secsize = mean(segment_size(DataStruct(i).Data));
        if i==1, DataStruct(i).basesecsize = DataStruct(i).secsize; else DataStruct(i).basesecsize = DataStruct(1).secsize; end;

        %DataStruct(i).sections_oh = segments2labeling(DataStruct(i).Data(:,1:2));
        %DataStruct(i).totalsize = length(DataStruct(i).sections_oh);
    end;


    % OAM REVISIT: Move to initmain child script, providing UseSlice
    % select subset of slices
    if ~isempty(UseSlice)
        for  i = 1:length(Spotters)
            if isempty(DataStruct(i).Data), continue; end;

            DataStruct(i).Data = segment_getincluded(UseSlice,  DataStruct(i).Data);
            DataStruct(i).Partlist = Partlist;
        end;
    end;

    
    % % find longest segments list
    % maxlistsize = 0;
    % for  i = 1:length(Spotters)
    %     if isempty(DataStruct(i).Data), continue; end;
    %     if maxlistsize < size(DataStruct(i).Data,1), maxlistsize = size(DataStruct(i).Data,1); end
    % end;


    % segmentation points
    if strcmpi(SegConfig.Name, 'spotter')
        %     % merge seglist
        %     AllSegmentList = [];
        %     for  i = 1:length(Spotters)
        %         AllSegmentList = [ AllSegmentList;  DataStruct(i).Data ];
        %     end;
        %     AllSegmentList = segment_sort(AllSegmentList);

        aseglist = DataStruct(1).Data(:,1:2); %AllSegmentList(:,1:2);
        aseglist(segment_findidentical(segment_sort(aseglist)),:) = [];
    else
        aseglist = cla_getsegmentation(Repository, Partlist, 'SampleRate',  SampleRate, ...
            'SegType', SegConfig(1).Name, 'SegMode', SegConfig(1).Mode);
        aseglist(end,:) = [aseglist(end,1) partoffsets(end)]; % omit last (may exceed data size)
        if ~isempty(OmitPInrs)
            aseglist = segment_getincluded(UseSlice, aseglist);
        end;
    end;
    if ~isempty(SpottingSearchWindow)
        aseglist = segment_window(aseglist, round(SpottingSearchWindow*SampleRate/mean(segment_size(aseglist))), ...
            round(SpottingSearchStep*SampleRate/mean(diff(aseglist(:,1)))), 'none');
        aseglist = aseglist(:,1:2);
    end;



    % determine sliding window
    classlabellist = segment_findlabelsforclass(labellist, thisTargetClasses);
    tmp = segment_countoverlap(classlabellist(classlabellist(:,6)>=LabelConfThres,:), aseglist, -inf);
    switch lower(SpottingMode)
        case { 'fixed', 'maxtest' }
            obswindow = repmat(round(mean(tmp)) + (round(mean(tmp))==0), 1,2);
        case 'specified'
            tmp = round(SpottingSearchWindow*SampleRate/mean(segment_size(aseglist)));
            %                     %tmp = round(SpottingSearchWindow*SampleRate);
            obswindow = repmat(tmp+(tmp==0), 1,2);
        otherwise
            error('Spotting mode %s not supported.', lower(SpottingMode));
    end;
    fprintf('\n%s: Search mode: %s, obswindow: %s...', mfilename, lower(SpottingMode), mat2str(obswindow));


    % compute segment features
    tic; [fmmatrix fmsectionlist] = makefeatures_segment(aseglist, obswindow, @makefeatures_event, DataStruct, 1); toc;

else
    
    fprintf('\n%s: DoLoad=%s, skip loading', mfilename, mat2str(DoLoad));    

end;  % if (DoLoad)








% loop for each class
allclassmetrics = [];
for classnr = 1:length(thisTargetClasses)
    fprintf('\n%s: Processing class %u...', mfilename, thisTargetClasses(classnr));
    classlabellist = segment_findlabelsforclass(labellist, thisTargetClasses(classnr));

    % checks
    for i = 1:length(Spotters)
        if isempty(DataStruct(i).Data)
            fprintf('\n%s: WARNING: No sections found for spotter %u (%s)', mfilename, i, SegmentSet(i).name);
        end;
    end;
    if thisTargetClasses ~= row(unique(classlabellist(:,4))),  error('No observations found.'); end;
    if length(partoffsets) ~= length(Partlist)+1, error('Partlist and partoffsets do not match. Rerun initmain.'); end;
    repos_findlabelsforpart(classlabellist, 1:length(Partlist), partoffsets);  % this will raise an error if labels cross PIs




    % create cv splits
    %   CVSectionBounds may come from any initmain_* preprocessor script
    [trainslices, testslices, dotraining] = spot_createcvsplit(CVMethod, CVFolds, classlabellist, ...
        Repository, Partlist, 'mintrainshare', mintrainshare, 'LabelConfThres', LabelConfThres, ...
        'CVSectionBounds', CVSectionBounds);


    % information containers for each CV interation (CVFolds)
    allmetrics = [];
    bestthres = nan(1, CVFolds);    mythresholds = cell(1, CVFolds);
    testSegBest = cell(1,CVFolds); trainSegBest = cell(1,CVFolds);
    testSegMax = cell(1,CVFolds); trainSegMax = cell(1,CVFolds);
    trainSegGT = cell(1,CVFolds); testSegGT = cell(1,CVFolds);


    % begin CV
    for  cvi = 1:CVFolds
        % find labels within slices, omit tentatives only for training (below!)
        trainseglist = classlabellist(segment_countoverlap(classlabellist, trainslices{cvi}) > 0, :);
        testseglist = classlabellist(segment_countoverlap(classlabellist, testslices{cvi}) > 0, :);

        fprintf('\n%s: Classes: %s  CV: %u of %u  Total: %u, Train: %u (T:%u, omit:%u), Test: %u (T:%u, omit:%u)', mfilename, ...
            mat2str(thisTargetClasses), cvi, CVFolds, size(classlabellist,1), size(trainseglist,1), ...
            size(trainseglist(trainseglist(:,6)<1,:),1), size(trainseglist(trainseglist(:,6)<LabelConfThres,:),1), size(testseglist,1), ...
            size(trainseglist(testseglist(:,6)<1,:),1), size(testseglist(trainseglist(:,6)<PRLabelConfThres,:),1) );
        fprintf('\n%s: CV trainslices: %s, testslices: %s', mfilename, strcut(mat2str(trainslices{cvi})), mat2str(testslices{cvi}) );

        % verify that there are no overlaps btw train/test
        if any(segment_countoverlap(trainseglist, testseglist)>0)
            error('Detected overlap between training and testing labels, stop.');
        end;


        % ------------------------------------------------------------------------
        % Training
        % ------------------------------------------------------------------------

        if dotraining(cvi)
            % challenges
            % 1. makefeatures_segment creates sections wrt aseglist/segments => need to convert to get real labels
            % 2. Spotters have different results/nr of observations => makefeatures find no entries for some sections


            % determine index, required for acessing SF_fmatrixtrain
            lbtrainidx = (segment_countoverlap(fmsectionlist, trainseglist(trainseglist(:,6)>=LabelConfThres,:))==1);

            % join training segment slices when adjacent
            cont_trainslices = segment_distancejoin(trainslices{cvi},2);

            % find sections relevant for training step
            % process continuous training slices into one selection array
            fmtrainidx = [];
            for tslice = 1:size(cont_trainslices,1)
                fmtrainidx = [ fmtrainidx; segment_findincluded(cont_trainslices(tslice,:), fmsectionlist) ];
            end;


            % to be extended: perform feature extraction/selection
            lbtrain = fmmatrix(lbtrainidx, :);  % select by logical vector
            fmtrain = fmmatrix(fmtrainidx, :);  % select by indices


            % build spotter model
            fprintf('\n%s:   Model training %s for %u labels, sections: %u...', mfilename, ...
                upper(SpottingMethod), size(trainseglist(trainseglist(:,6)>=LabelConfThres,:),1),  sum(lbtrainidx));

            if strcmp(SpottingMethod, 'loadmodel')
                SpottingMethod_Params(end+1:end+2) = { 'filename', dbfilename(Repository, 'prefix', 'spotmodel' , ...
                    'indices', thisTargetClasses(1), 	'suffix', SimSetID, 'subdir', 'models') };
            end;

            spotmodel = similarity_train(lbtrain, SpottingMethod, SpottingMethod_Params{:});
            if isempty(spotmodel), error('spotmodel not available.'); end;


            % process continuous training slices
            fprintf('\n%s:   Process spotmodel, sections: %u, features: %u, obswindow: %s...', ...
                mfilename, size(fmtrain,1), size(fmtrain,2), mat2str(obswindow));

            secdist = similarity_dist( fmtrain, spotmodel );

            if ClassifyMode
                this_trainDist = similarity_dist( fmtest, spotmodel );
                [thisdist predictedclass] = min(this_trainDist, [], 2);
                this_trainSeg = segment_createlist(fmsectionlist, 'classlist', col(thisTargetClasses(predictedclass)), ...
                    'conflist', distance2confidence(thisdist, max(this_trainDist, [], 2)) );

            else % if ClassifyMode
                [Sidx Serr] = segment_findsimilar(trainseglist(trainseglist(:,6)>=LabelConfThres,:), fmsectionlist);
                if any(Serr > 0.5),
                    fprintf('\n%s: WARNING: Detected large alignment mismatch of labels and segmentation for train idx: %s', ...
                        mfilename, mat2str(Sidx(Serr>0.5)));
                end;
                this_mythresholds = estimatethresholddensity(secdist, ThresholdMethod_Params{:});
                fprintf('\n%s:     train dist:%.2f-%.2f (mean:%.2f sd:%.2f), wait...', mfilename, min(secdist), max(secdist), mean(secdist), std(secdist));
                [this_trainSeg this_trainDist] = similarity_eval( fmsectionlist, secdist, trainseglist, 'MergeMethod', 'None', ...
                    'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', this_mythresholds, 'LoopMode', 'pretend');
            end;  % if ClassifyMode

            fprintf('\n%s:     sections in relevants (%u): %s', mfilename, ...
                size(trainseglist,1), strcut(mat2str(segment_countoverlap(trainseglist, fmsectionlist))));

            % compute and prune metrics
            fprintf('\n%s:   Computing performance metrics...', mfilename);
            if ClassifyMode
                
            else % if ClassifyMode
                clear metrics_train;  progress = 0.1;
                for i = 1:length(this_trainSeg)
                    progress = print_progress(progress, i/length(this_trainSeg));
                    tmp = cmetrics_mkstats(cmetrics_mkmatrixfromseg(trainseglist, this_trainSeg{i}, ...
                        'LabelConfThres', PRLabelConfThres, 'CountNullClass', true, 'ConvertREF', true));
                    tmp = prmetrics_splitclass(tmp);
                    metrics_train(i) = tmp(2);   % just count real class, NULL class size is typically unknown
                end;
                fprintf(' %u, pruning: ', length(metrics_train));
                [metrics_train keeplist] = prmetrics_prunepr(metrics_train, 'verbose', 0, PRPruneMethod_Params{:});
                fprintf(' %u', length(metrics_train));

                mythresholds{cvi} = this_mythresholds(keeplist);
                bestthres(cvi) = prmetrics_findoptimum(metrics_train, SpottingOptimumPrecision);
                trainSegBest{cvi} = segment_createlist( this_trainSeg{keeplist(bestthres(cvi))}, ...
                    'classlist', thisTargetClasses(classnr), 'conflist', this_trainDist{keeplist(bestthres(cvi))} );
                trainSegMax{cvi} = segment_createlist( this_trainSeg{keeplist(end)}, ...
                    'classlist', thisTargetClasses(classnr), 'conflist',  this_trainDist{keeplist(end)} );

                fprintf('\n%s:   Selected threshold: %u:%.2f (pruned):', mfilename, bestthres(cvi), mythresholds{cvi}(bestthres(cvi)) );
                prmetrics_printstruct(metrics_train(bestthres(cvi)));
            end; % if ClassifyMode

        else
            % use settings from previous run
            bestthres(cvi) = bestthres(cvi-1);          mythresholds{cvi} = mythresholds{cvi-1};
        end; % if dotraining(cvi)

        %error('Breakpoint');


        % ------------------------------------------------------------------------
        % Testing
        % ------------------------------------------------------------------------

        % determine test data slice
        fprintf('\n%s:   Relevant test events: %u (T:%u), testslices: %s', mfilename, ...
            size(testseglist,1), size(testseglist(testseglist(:,6)<1,:),1), mat2str(testslices{cvi}));

        % adapt segmentation list (this will select the data accordingly)
        fmtestidx = segment_findincluded(testslices{cvi}, fmsectionlist);
        fmtest = fmmatrix(fmtestidx,:);  % reference by index

        fprintf('\n%s:      process similarity, method: %s, sections: %u...', mfilename, SpottingMethod, size(fmsectionlist,1));


        % compute similarity
        secdist = similarity_dist(fmtest, spotmodel);
        fprintf('\n%s:      test dist:%.2f-%.2f (mean:%.2f,sd:%.2f), wait...', mfilename, min(secdist), max(secdist), mean(secdist), std(secdist));

        % generate threshold-dependent result lists
        [this_testSeg this_testDist Thresholds] = similarity_eval( fmsectionlist, secdist, testseglist, ...
            'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds{cvi}, 'LoopMode', 'pretend');

        fprintf('\n%s:      sections in relevants: %s, features: %u', mfilename, ...
            strcut(mat2str(segment_countoverlap(testseglist, fmsectionlist(fmtestidx,:)))));


        fprintf('\n%s: *** Test data evaluation, threshold: %.2f (%u):', ...
            mfilename, mythresholds{cvi}(bestthres(cvi)), bestthres(cvi));
        tmp = prmetrics_splitclass(cmetrics_mkstats(cmetrics_mkmatrixfromseg(testseglist, this_testSeg{bestthres(cvi)}, ...
            'LabelConfThres', PRLabelConfThres, 'ConvertREF', true,  'ClassIDs', [0; 1])));
        thismetric = tmp(2);   % just count real class, NULL class size is typically unknown
        prmetrics_printstruct(thismetric);


        % store eval results in global cell array
        testSegBest{cvi} = segment_createlist( this_testSeg{bestthres(cvi)}, ...
            'classlist', thisTargetClasses(classnr), 'conflist',  this_testDist{bestthres(cvi)} );
        testSegMax{cvi} = segment_createlist( this_testSeg{end}, ...
            'classlist', thisTargetClasses(classnr), 'conflist',  this_testDist{end} );

        trainSegGT{cvi} = trainseglist; testSegGT{cvi} = testseglist;

        allmetrics = prmetrics_add(allmetrics, thismetric);

        if DebugMaxCVI <= cvi, error('Debug breakpoint reached.'); end;
    end; % for cvi

    % break if no train/test partition was found
    if isempty(allmetrics), break; end;

    fprintf('\n%s: *** Complete data evaluation:', mfilename);
    prmetrics_printstruct(allmetrics);


    if (DoSave)
        SaveTime = clock;
        metrics = allmetrics;

        filename = dbfilename(Repository, 'prefix', 'SFCV', 'indices', thisTargetClasses(classnr), 'suffix', SimSetID, 'subdir', 'SPOT');
        fprintf('\n%s: Save %s...', mfilename, filename);
        save(filename, ...
            'trainSegBest', 'trainSegMax', 'testSegBest', 'testSegMax', ...
            'trainSegGT', 'testSegGT', ...
            'bestthres', 'mythresholds', 'trainslices', 'testslices', 'UseSlice', ...
            'obswindow', 'spotmodel', 'dotraining', ...
            'metrics', 'section_jitter', ...
            'thisTargetClasses', 'MergeClassSpec', 'classlabellist', 'Partlist', ...
            'CVFolds', 'CVMethod', 'CVSectionBounds', 'partoffsets', 'SegConfig', 'mintrainshare', ...
            'SpottingMethod', 'SpottingMethod_Params', 'SpottingMode', 'SpottingSearchWindow', 'SpottingSearchStep', ...
            'SpottingOptimumPrecision', ...
            'LabelConfThres', 'PRLabelConfThres',  ...
            'ThresholdMethod_Params', ...
            'StartTime', 'SaveTime', 'VERSION');
        fprintf(' done.');
    end;

    allclassmetrics = [allclassmetrics allmetrics];
end; % for classnr
fprintf('\n\n');
