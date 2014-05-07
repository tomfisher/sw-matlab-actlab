% main_spotfusion
%
% Fusion of similarity spotting runs (classes, similarity runs)
% Different similarity spotting runs are specified by SimSetID_List.
% Will consider bestthres only.
%
% This code does not require explicit symbol domain mapping as the event
% methods of similarity_train/*_dist do. Instead every method converts
% spotting results from prepresults individually.
%
% See also main_spotloadresults, main_spotsweep, (main_spotcombine)

% requires:
% Partlist; % default: Partlist = Repository.UseParts
SimSetID;   % used for saving results
% SimSetID_List;  % list of spotting results to include, default: use this SimSetID
% section_jitter;

VERSION = 'V013';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if (~exist('DoLoad', 'var')), DoLoad = true; end;   % load spotting result
if (~DoLoad), fprintf('\n%s: DoLoad=%s', mfilename, mat2str(DoLoad)); end;
if (~exist('DoSave', 'var')), DoSave = true; end;   % save result

if (~exist('FusionMethod','var')), FusionMethod = 'COMP'; end;
if (~exist('InSpotType','var')), InSpotType = 'SIMS'; end;
if (~exist('OutSpotType','var')), OutSpotType = 'SFUS'; end;  % operation mode: SFUS (flattened) or SFCV (CV sliced)
if (~exist('Partlist','var')), Partlist = Repository.UseParts; end;
if (~exist('UseBestThres','var')), UseBestThres = true; end; % 1: use best threshold, 0: use max threshold

if (~exist('LabelConfThres', 'var')), LabelConfThres = 0; end;
if (~exist('ReloadGT', 'var')), ReloadGT = false; end;
if (~exist('ConvertDistance', 'var')), ConvertDistance = strcmpi(InSpotType, 'SIMS'); end;
if (~exist('MergeMethod','var')), MergeMethod = 'FrontOfBest'; end;
fprintf('\n%s: InSpotType=%s, OutSpotType=%s.', mfilename, InSpotType, OutSpotType);

if (~exist('DoNorm', 'var')), DoNorm = false; end;   % normalise (CLASSIFY mode)
if (~exist('DoClip', 'var')), DoClip = false; end;   % clipping (CLASSIFY mode)
if (~exist('DoClipLimit', 'var')), DoClipLimit = 10; end;   % clipping bounds (CLASSIFY mode)

if (~exist('SpottingMethod','var')), SpottingMethod = 'bernoulli'; end;
if (~exist('SpottingMethod_Params','var')), SpottingMethod_Params = {}; end;
if ~exist('MVoteWindow','var'), MVoteWindow = 3; end;  % in sections
if (~exist('ThresholdMethod_Params','var')), ThresholdMethod_Params = { 'Model', 'unique1' }; end;
% for event counting methods (Bernoulli): 'Model', 'unique1'
% for event confidence methods (Bayes Gaussian): 'Model', 'polyxobs', 'Order', 2  % Res is set directly

if ~exist('ClassifierName', 'var'), ClassifierName = 'NBayes'; end;
if ~exist('ClassifierParams', 'var'), ClassifierParams = {}; end;
if (~exist('FSelMethod', 'var')), FSelMethod = 'LDA'; end;  % perform feature selection
if (~exist('FMatchStyle','var')), FMatchStyle = 'lazy'; end;   % style to enable features (lazy / exact)
if (~exist('FSelFeatureCount','var')), FSelFeatureCount = length(thisTargetClasses)-1; end;   % nr of features to select
if (~exist('FeatureString','var')),  FeatureString = {}; end;


if (~exist('SeqOperation', 'var')), SeqOperation = {'Lnone'}; end;   % sequence operation (SEQOP mode)


initmain_ExpandSimSetID; % provides SimSetID_List, DoDeleteSimSetID_List
fprintf('\n%s: SimSetID_List: %s...', mfilename, cell2str(SimSetID_List));

% number of parallel spotting streams
NrSpotters = length(SimSetID_List)*length(thisTargetClasses);

% pre-load trainslices, testslices
filename = spot_isfile(InSpotType, SimSetID_List{1}, thisTargetClasses(1));
if isempty(filename) || ~exist(filename,'file'), error('Could not find a spotting file.'); end;
[trainslices testslices] = loadin(filename, 'trainslices', 'testslices');

% -------------------------------------------------------------------------
% perform fusion
% -------------------------------------------------------------------------
clear testSL testSC testseglist;
clear testSegBest trainSegBest;
clear bestthres mythresholds;

fprintf('\n%s: Using fusion method %s...', mfilename, upper(FusionMethod));
switch upper(FusionMethod)
    %% COMP
    case 'COMP'  % segment merging
        if (DoLoad)
            if ~ConvertDistance, fprintf('\n%s: WARNING: ConvertDistance=%s', mfilename, mat2str(ConvertDistance)); end;
            [trainSLC testSLC trainSegGT testSegGT CVFolds ] = ...
                prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', UseBestThres, 'MergeSpotters', true, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
                'SpotType', InSpotType, 'ConvertDistance', ConvertDistance, 'ReloadGT', ReloadGT, 'verbose',2);
        end;

        testSegBest = cell(1,CVFolds); trainSegBest = cell(1,CVFolds);
        for cvi = 1:CVFolds
            if ~isempty(trainSLC{cvi}),  trainSegBest{cvi} = trainSLC{cvi};  end;

            fprintf('\n%s: CV%u: Merging sections: %u...', mfilename, cvi, size(testSLC{cvi},1));
            if isempty(testSLC{cvi})
                testSegBest{cvi} = [];
            else
                [testSegBest{cvi} this_testDist] = spot_segmentmerge( MergeMethod, testSLC{cvi}, testSLC{cvi}(:,6), 'BestConfidence', 'max', 'verbose', 0 );
                if ~isempty(testSegBest{cvi}), testSegBest{cvi}(:,6) = this_testDist; end;
                %[testSL testSC] = spot_segmentmerge( 'FrontOfBest', testSLC, testSLC(:,6), 'BestConfidence', 'max', 'verbose', 0, ...
                %	'lookbackn', inf, 'lookbackt', inf);
            end;
        end;


%% AGREE
    case 'AGREE'
        % OAM REVISIT: Supporting spotters vs. Disagreeing spotters - modes
        % in spot_segmentmerge? Not, because spot_segmentmerge does not consider class numbers
        [trainSLC testSLC trainseglist CVtestseglist CVFolds ] = ...
            prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
            'BestThresOnly', UseBestThres, 'MergeSpotters', false, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
            'SpotType', 'SIMS', 'ConvertDistance', ConvertDistance, 'verbose',2);

        % find sections from all spotters that do overlap with first spotters reporting
        testseglist = []; cv_testSL = [];
        for cvi = 1:CVFolds  % spotters would need to be merged before CVs are merged
            fprintf('\n%s: CV: %u...', mfilename, cvi);
            idx = true( 1, size(testSLC{1,cvi},1) );
            for d = 2:NrSpotters  % spotters are instances!
                idx = idx & segment_countoverlap(testSLC{1,cvi}, testSLC{d,cvi}, inf)>0;
                % TODO: check label, store largest section
            end; % for d

            cv_testSL = [ cv_testSL; testSLC{1,cvi}(idx,:) ];  % keep overlaps only

            testseglist = [testseglist; CVtestseglist{cvi}];
            prmetrics_printstruct(prmetrics_fromsegments(CVtestseglist{cvi}, cv_testSL, section_jitter));
        end; % for cvi

        % list cleanup
        % OAM REVISIT: Needed??
        prmetrics_printstruct(prmetrics_fromsegments(testseglist, cv_testSL, section_jitter));
        [testSL testSC] = spot_segmentmerge('FrontOfBest', cv_testSL, cv_testSL(:,6), 'BestConfidence', 'max', 'verbose', 0 );
        prmetrics_printstruct(prmetrics_fromsegments(testseglist, testSL, section_jitter));


        % LR
    case 'LR'  % logistic regression (event counting considering NULL class explicitly)
        % uses KPMstats (FullBNT) routines
        % positive class: event matches with GT, neg class: events that do not match GT
        if (DoLoad)
            [trainSLC testSLC CVtrainseglist CVtestseglist CVFolds ] = ...
                prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', UseBestThres, 'MergeSpotters', false, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
                'SpotType', 'SIMS', 'ConvertDistance', ConvertDistance, 'verbose',2);
        end;
        % Spotters are NOT merged here, so we get somthing like (Spotters=2, CVFolds=4): whos *SLC
        %   Name          Size             Bytes  Class    Attributes
        %   testSLC       2x4             164880  cell
        %   trainSLC      2x4             450000  cell

        testseglist = []; cv_testSL = []; cv_testSC = [];
        for cvi = 1:CVFolds
            fprintf('\n%s: CV: %u...', mfilename, cvi);

            testSegC = []; testDistC = [];
            for classnr = 1:length(thisTargetClasses)
                classlabels = segment_findlabelsforclass(CVtrainseglist{cvi}(CVtrainseglist{cvi}(:,6)>=LabelConfThres,:), thisTargetClasses(classnr));
                if isempty(classlabels)
                    fprintf('\n%s: Skip training for CV: %u, no training instances.', mfilename, cvi);
                else
                    % get the result from all detector for the class labels
                    ranktab1 = zeros(size(classlabels,1), NrSpotters); ranktab2 = zeros(size(classlabels,1), NrSpotters);
                    for d = 1:NrSpotters  % spotters are classes OR instances
                        idx = segment_countoverlap(classlabels, trainSLC{d,cvi}, section_jitter)>0;
                        ranktab1(idx,d) = d;  % good ones
                        idx = find(segment_countoverlap(trainSLC{d,cvi}, classlabels, section_jitter)==0, size(classlabels,1));
                        ranktab2(idx) = d;  % bad ones
                    end; % for d
                    % determine alpha, beta
                    [beta pr] = logist2([ones(size(ranktab1,1),1); zeros(size(ranktab2,1),1)], [ranktab1; ranktab2]);
                    % plot(pr);
                    %catch fprintf('\n%s: logist2 crashed at CV: %u, class: %u', mfilename, cvi, classnr); beta = [0; 0]; end;
                    % 				x = logistic(ranktab, repmat(1, size(classlabels,1),1) );
                    % 				B = mnrfit( ranktab, repmat(2, size(classlabels,1),1) );
                    % 				PHAT = mnrval(B, ranktab');
                    % 				logits = sum( [x(1) ranktab'.*x(2)], 2 );

                    % determine threshold (Ward2006, Diss)
                    prerr = logist2Apply(beta, ranktab1');   % plot(prerr)
                    %[dummy pt] = logist2(repmat(1, sum(erridx),1), ranktab1(erridx,:));
                    probth = mean(prerr)-std(prerr,[],2);
                end;

                % evaluate on testing data, requires: beta, probth

                % how to get to the segment rankings?
                % 				% 1. merge them, keeping the best as reference, 2. find associated spotter results
                % 				tmp_testSLC = []; for d = 1:NrSpotters, tmp_testSLC = [tmp_testSLC; testSLC{d,cvi}]; end;
                % 				testSL = spot_segmentmerge( 'FrontOfBest', tmp_testSLC, tmp_testSLC(:,6), 'BestConfidence', 'max', 'verbose', 0 );
                % 				ranktab = zeros(size(testSL,1), NrSpotters); %ranktab = repmat(eps, size(classlabels,1), NrSpotters);
                % 				for d = 1:NrSpotters  % spotters are classes OR instances
                % 					for i = 1:size(testSL,1)
                % 						idx = segment_findoverlap(testSL(i,:), testSLC{d,cvi}, section_jitter);
                % 						%if isempty(idx), continue; end; % leave out if nothing found
                % 						ranktab(i,d) = ~isempty(idx); %d;
                % 					end; % for i
                % 				end; % for d

                % alternate implementation ?!
                % find events from all spotters, keep information of source (spotter)
                tmp_testSLC = [];
                for d = 1:NrSpotters
                    tmp_testSLC = [tmp_testSLC; segment_createlist(testSLC{d,cvi}, 'classlist', d)];
                end;

                % determine overlaps, record scores in ranktab
                ranktab = zeros(size(tmp_testSLC,1), NrSpotters);
                for i = 1:size(tmp_testSLC,1)
                    idx = segment_findoverlap(tmp_testSLC(i,:), tmp_testSLC, section_jitter);
                    for k = 1:length(idx), ranktab(i,tmp_testSLC(idx,4)) = 1; end;
                end;

                % apply LR to ranktab, hitidx marks results
                pr = col(logist2Apply(beta, ranktab'));   % plot(pr)
                hitidx = pr > probth;   % sum(hitidx)
                tmp_testSLC(hitidx,4) = thisTargetClasses(classnr);    tmp_testSLC(hitidx,6) = 0;

                % add it to the list for all classes
                testSegC = [ testSegC; tmp_testSLC(hitidx,:) ];  testDistC = [ testDistC; pr(hitidx) ];  %testSC(hitidx,:)
            end; % for classnr

            % combine and rank the final result
            cv_testSL = [cv_testSL; testSegC]; cv_testSC = [cv_testSC; testDistC];
            testseglist = [testseglist; CVtestseglist{cvi}];
            prmetrics_printstruct(prmetrics_softalign(CVtestseglist{cvi}, cv_testSL, 'jitter', section_jitter, 'LabelConfThres', LabelConfThres));
        end; % for cvi

        % OAM REVISIT: Need for merging? Check overlapping result quality
        [testSL testSC] = spot_segmentmerge('FrontOfBest', cv_testSL, cv_testSC, 'BestConfidence', 'max', 'verbose', 0 );
        prmetrics_printstruct(prmetrics_softalign(testseglist, testSL, 'LabelConfThres', LabelConfThres));
        testSC = abs(1-testSC);  % strange: errors seem to occur in the worng order here?!


%% ECOUNT
    case 'ECOUNT'  % Event counting fusion without NULL class
        if (DoLoad)
            [trainSLC testSLC CVtrainseglist CVtestseglist CVFolds ] = ...
                prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', UseBestThres, 'MergeSpotters', false, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
                'SpotType', 'SIMS', 'ConvertDistance', ConvertDistance, 'verbose',2);
        end;
        % Spotters are NOT merged here, so we get somthing like (Spotters=2, CVFolds=4): whos *SLC
        %   Name          Size             Bytes  Class    Attributes
        %   testSLC       2x4             164880  cell
        %   trainSLC      2x4             450000  cell

        testseglist = [];  clear classmetrics;
        cv_testSL = []; cv_testSC = [];
        for cvi = 1:CVFolds
            fprintf('\n%s: CV: %u...', mfilename, cvi);

            testSegC = []; testDistC = [];
            for classnr = 1:length(thisTargetClasses)
                if cvi==1, classmetrics(classnr) = prmetrics_mkstruct(0,0,0); end;

                classlabels = segment_findlabelsforclass(CVtrainseglist{cvi}, thisTargetClasses(classnr));
                if isempty(classlabels)
                    fprintf('\n%s: Skip training for CV: %u, no training instances.', mfilename, cvi);
                else
                    % spotters are features, hence states are 2: 0=no event, 1=event occured
                    % Observations are positive examples only, each spotter
                    % corresponds to one column, each line to valid GT examples
                    fprintf('\n%s:   Training with %u observations from %u spotters...', mfilename, size(classlabels,1), NrSpotters);

                    % get the result from all detector for the class labels
                    Observations = zeros(size(classlabels,1), NrSpotters);   mtrainSL = [];  mtestSL = [];
                    for f = 1:NrSpotters  % spotters are classes OR instances
                        Observations(:,f) = segment_countoverlap(classlabels, trainSLC{f,cvi}, section_jitter)>0;
                        mtrainSL = [ mtrainSL; trainSLC{f,cvi} ];
                        mtestSL = [ mtestSL; testSLC{f,cvi} ];
                    end; % for f
                    % determine model from training set distances (no negative class here!)
                    simmodel = similarity_train(Observations, SpottingMethod, SpottingMethod_Params{:});

                    % determine threshold on training set (minimal spotidentify functionality)
                    mtrainSL = spot_segmentmerge('Combine', mtrainSL, mtrainSL(:,6), 'BestConfidence', 'max', 'verbose', 1 );
                    % trainSL: list of section bulks, where at least one spotter reported an event
                    Observations = zeros(size(mtrainSL,1), NrSpotters);
                    for f = 1:NrSpotters  % spotters are classes OR instances
                        Observations(:,f) = segment_countoverlap(mtrainSL, trainSLC{f,cvi}, -inf)>0; % report included ones
                    end; % for f
                    if min(sum(Observations,2))<1, error('Something wrong here.'); end;

                    secdist = similarity_dist(Observations, simmodel);
                    mythresholds = estimatethresholddensity(secdist, 'Model', 'unique1');
                    fprintf('\n%s:   Thresholds: %.2f...%.2f (mean:%.2f sd:%.2f), wait...', mfilename, ...
                        min(mythresholds), max(mythresholds), mean(mythresholds), std(mythresholds));
                    [this_trainSeg this_trainDist] = similarity_eval( mtrainSL, secdist, classlabels, ...
                        'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
                    fprintf('\n%s:   Computing performance metrics...', mfilename)
                    metrics_train = prmetrics_softalign(classlabels, this_trainSeg, 'jitter', section_jitter, 'LabelConfThres', 1);
                    bestthres = prmetrics_findoptimum(metrics_train, 0.7);
                    fprintf('\n%s:   Selected training threshold: %u:%.2f (%u):', mfilename, bestthres, mythresholds(bestthres), bestthres);
                    prmetrics_printstruct(metrics_train(bestthres));
                    %  prmetrics_plotpr('view', [], metrics_train);
                end;


                % TESTING
                classlabels = segment_findlabelsforclass(CVtestseglist{cvi}, thisTargetClasses(classnr));
                fprintf('\n%s:   Testing with %u observations...', mfilename, size(classlabels,1));

                % find & align event in test data
                mtestSL = spot_segmentmerge('Combine', mtestSL, mtestSL(:,6), 'BestConfidence', 'max', 'verbose', 0 );
                if isempty(mtestSL)
                    % skip if there are no events
                    fprintf('\n%s: No test events found. Relevant: %u', mfilename, size(classlabels,1));
                    classmetrics(classnr) = prmetrics_add(classmetrics(classnr), prmetrics_mkstruct(size(classlabels,1), 0, 0));
                    continue;
                end;

                Observations = zeros(size(mtestSL,1), NrSpotters);
                for f = 1:NrSpotters  % spotters are classes OR instances
                    Observations(:,f) = segment_countoverlap(mtestSL, testSLC{f,cvi}, -inf)>0; % report included ones
                end; % for f
                if min(sum(Observations,2))<1, error('Something wrong here.'); end;

                % apply recogniser
                secdist = similarity_dist(Observations, simmodel);
                [this_testSeg this_testDist] = similarity_eval( mtestSL, secdist, classlabels, ...
                    'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
                metrics_test = prmetrics_softalign(classlabels, this_testSeg, 'jitter', section_jitter, 'LabelConfThres', 1);
                % prmetrics_plotpr('view', [], metrics_test);
                fprintf('\n%s: CV%u: class %u test data evaluation, threshold %.2f (%u):', mfilename, ...
                    cvi, thisTargetClasses(classnr), mythresholds(bestthres), bestthres);
                prmetrics_printstruct(metrics_test(bestthres));
                this_testSeg{bestthres} = segment_createlist(this_testSeg{bestthres}, ...
                    'classlist', thisTargetClasses(classnr), 'conflist', this_testDist{bestthres});

                % add it to the list for all classes
                testSegC = [ testSegC; this_testSeg{bestthres} ];    testDistC = [ testDistC; this_testDist{bestthres} ];
                classmetrics(classnr) = prmetrics_add(classmetrics(classnr), metrics_test(bestthres));
            end; % for classnr

            % combine and rank the final result
            cv_testSL = [cv_testSL; testSegC]; cv_testSC = [cv_testSC; testDistC];
            testseglist = [testseglist; CVtestseglist{cvi}];
            %prmetrics_printstruct(prmetrics_softalign(CVtestseglist{cvi}, cv_testSL, 'jitter', inf));
        end; % for cvi
        fprintf('\n%s: *** Total performance:', mfilename);
        prmetrics_printstruct(classmetrics);

        % OAM REVISIT: Bullshit! CVs must be analysed individually OR deticated COMP step applied
        %[testSL testSC] = spot_segmentmerge('FrontOfBest', cv_testSL, cv_testSC, 'BestConfidence', 'min', 'verbose', 0 );
        %prmetrics_printstruct(prmetrics_softalign(testseglist, testSL, 'jitter', inf));
        testSL = cv_testSL; testSC = cv_testSC;


        % ECONF
    case 'ECONF'  % use event confidence, fusion without NULL class
        if (DoLoad)
            [trainSLC testSLC CVtrainseglist CVtestseglist CVFolds ] = ...
                prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', UseBestThres, 'MergeSpotters', false, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
                'SpotType', 'SIMS', 'ConvertDistance', ConvertDistance, 'verbose',2);
        end;

        testseglist = [];  clear classmetrics;
        cv_testSL = []; cv_testSC = [];
        for cvi = 1:CVFolds
            fprintf('\n%s: CV: %u...', mfilename, cvi);

            testSegC = []; testDistC = [];
            for classnr = 1:length(thisTargetClasses)
                if cvi==1, classmetrics(classnr) = prmetrics_mkstruct(0,0,0); end;

                classlabels = segment_findlabelsforclass(CVtrainseglist{cvi}, thisTargetClasses(classnr));
                if isempty(classlabels)
                    fprintf('\n%s: Skip training for CV: %u, no training instances.', mfilename, cvi);
                else
                    % spotters are features, hence states are 2: 0=no event, >0=event occured
                    % Observations are positive examples only, each spotter
                    % corresponds to one column, each line to valid GT examples
                    fprintf('\n%s:   Training with %u observations from %u spotters...', mfilename, size(classlabels,1), NrSpotters);

                    % get the result from all detector for the class labels
                    % OAM REVISIT: Shall the train model be determined from train bulks (s.b.)?
                    % NOT: In the current way an ideal train result, w/o 'bulking' pathologies is established.
                    Observations = zeros(size(classlabels,1), NrSpotters);   mtrainSL = [];  mtestSL = [];
                    for f = 1:NrSpotters  % spotters are classes OR instances
                        for seg = 1:size(classlabels,1)
                            idx =  segment_findoverlap(classlabels(seg,:), trainSLC{f,cvi}, section_jitter);
                            if isempty(idx), Observations(seg,f) = 0; continue; end;
                            Observations(seg,f) = mean(trainSLC{f,cvi}(idx, 6));
                        end;

                        mtrainSL = [ mtrainSL; trainSLC{f,cvi} ];
                        mtestSL = [ mtestSL; testSLC{f,cvi} ];
                    end; % for f
                    % determine model from training set distances (no negative class here!)
                    simmodel = similarity_train(Observations, SpottingMethod, SpottingMethod_Params{:});

                    % determine threshold on training set (minimal spotidentify functionality)
                    mtrainSL = spot_segmentmerge('Combine', mtrainSL, mtrainSL(:,6), 'BestConfidence', 'max', 'verbose', 1 );
                    % trainSL: list of section bulks, where at least one spotter reported an event
                    Observations = zeros(size(mtrainSL,1), NrSpotters);
                    for f = 1:NrSpotters  % spotters are classes OR instances
                        for seg = 1:size(mtrainSL,1)
                            idx =  segment_findincluded(mtrainSL(seg,:), trainSLC{f,cvi});  % report included ones
                            if isempty(idx), continue; end;
                            Observations(seg,f) = mean(trainSLC{f,cvi}(idx, 6));
                        end;
                    end; % for f
                    if min(sum(Observations,2))<=0, error('Something wrong here.'); end;

                    secdist = similarity_dist(Observations, simmodel);
                    mythresholds = estimatethresholddensity(secdist, ThresholdMethod_Params{:}, 'Res', round(size(Observations,1)/5));
                    fprintf('\n%s:   Thresholds: %u, %.2f...%.2f (mean:%.2f sd:%.2f), wait...', mfilename, ...
                        length(mythresholds), min(mythresholds), max(mythresholds), mean(mythresholds), std(mythresholds));
                    [this_trainSeg this_trainDist] = similarity_eval( mtrainSL, secdist, classlabels, ...
                        'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
                    fprintf('\n%s:   Computing performance metrics...', mfilename)
                    metrics_train = prmetrics_softalign(classlabels, this_trainSeg, 'jitter', section_jitter, 'LabelConfThres', 1);
                    bestthres = prmetrics_findoptimum(metrics_train, 0.7);
                    fprintf('\n%s:   Selected training threshold: %u:%.2f (%u):', mfilename, bestthres, mythresholds(bestthres), bestthres);
                    prmetrics_printstruct(metrics_train(bestthres));
                    %  prmetrics_plotpr('view', [], metrics_train);
                end;


                % TESTING
                classlabels = segment_findlabelsforclass(CVtestseglist{cvi}, thisTargetClasses(classnr));
                fprintf('\n%s:   Testing with %u observations...', mfilename, size(classlabels,1));

                % find & align event in test data
                mtestSL = spot_segmentmerge('Combine', mtestSL, mtestSL(:,6), 'BestConfidence', 'max', 'verbose', 0 );
                if isempty(mtestSL)
                    % skip if there are no events
                    fprintf('\n%s: No test events found. Relevant: %u', mfilename, size(classlabels,1));
                    classmetrics(classnr) = prmetrics_add(classmetrics(classnr), prmetrics_mkstruct(size(classlabels,1), 0, 0));
                    continue;
                end;

                Observations = zeros(size(mtestSL,1), NrSpotters);
                for f = 1:NrSpotters  % spotters are classes OR instances
                    for seg = 1:size(mtestSL,1)
                        idx =  segment_findincluded(mtestSL(seg,:), testSLC{f,cvi});  % report included ones
                        if isempty(idx), continue; end;
                        Observations(seg,f) = mean(testSLC{f,cvi}(idx, 6));
                    end;
                end; % for f
                if min(sum(Observations,2))<=0, error('Something wrong here.'); end;

                % apply recogniser
                secdist = similarity_dist(Observations, simmodel);
                [this_testSeg this_testDist] = similarity_eval( mtestSL, secdist, classlabels, ...
                    'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
                metrics_test = prmetrics_softalign(classlabels, this_testSeg, 'jitter', section_jitter, 'LabelConfThres', 1);
                % prmetrics_plotpr('view', [], metrics_test);
                fprintf('\n%s: CV%u: class %u test data evaluation, threshold %.2f (%u):', mfilename, ...
                    cvi, thisTargetClasses(classnr), mythresholds(bestthres), bestthres);
                prmetrics_printstruct(metrics_test(bestthres));
                this_testSeg{bestthres} = segment_createlist(this_testSeg{bestthres}, ...
                    'classlist', thisTargetClasses(classnr), 'conflist', this_testDist{bestthres});

                % add it to the list for all classes
                testSegC = [ testSegC; this_testSeg{bestthres} ];    testDistC = [ testDistC; this_testDist{bestthres} ];
                classmetrics(classnr) = prmetrics_add(classmetrics(classnr), metrics_test(bestthres));
            end; % for classnr

            % combine and rank the final result
            cv_testSL = [cv_testSL; testSegC]; cv_testSC = [cv_testSC; testDistC];
            testseglist = [testseglist; CVtestseglist{cvi}];
            %prmetrics_printstruct(prmetrics_softalign(CVtestseglist{cvi}, cv_testSL, 'jitter', inf));
        end; % for cvi
        fprintf('\n%s: *** Total performance:', mfilename);
        prmetrics_printstruct(classmetrics);

        % OAM REVISIT: Bullshit! CVs must be analysed individually OR deticated COMP step applied
        %[testSL testSC] = spot_segmentmerge('FrontOfBest', cv_testSL, cv_testSC, 'BestConfidence', 'min', 'verbose', 0 );
        %prmetrics_printstruct(prmetrics_softalign(testseglist, testSL, 'jitter', inf));
        testSL = cv_testSL; testSC = cv_testSC;


%% CLASSIFY
    case 'CLASSIFY'  % classify testSLC sections (assign new id)
        if (DoLoad)
            [trainSLC testSLC trainSegGT testSegGT CVFolds ] = ...
                prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', UseBestThres, 'MergeSpotters', true, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
                'SpotType', InSpotType, 'ConvertDistance', ConvertDistance, 'verbose',2);
        end;

        % load spotting feature data
        if (DoLoad)
            % probe available features
            filename = spot_findfeaturefile(Repository, Partlist(1), thisTargetClasses(1), fidx, Subject);
            SF_FeatureString_load = loadin(filename, 'FullFeatureString');
            %fprintf('\n%s:   Features available: %u ', mfilename, length(SF_FeatureString_load));
            [usedfeatures SF_FeatureString] = fb_findusedfeatures(SF_FeatureString_load, FeatureString, 'MatchStyle', FMatchStyle);
            fprintf(' used: %u.', length(SF_FeatureString));

            trainlabels = []; testlabels = [];			fmtrain = []; fmtest = [];
            for classnr = 1:length(thisTargetClasses)
                % dermine feature positions (individual features for each class)
                % However it is very unlikely that feature sets are different on the level of spot feature files!
                filename = spot_findfeaturefile(Repository, Partlist(1), thisTargetClasses(classnr), fidx, Subject);
                usedfeatures = fb_findusedfeatures(loadin(filename, 'FullFeatureString'), SF_FeatureString, 'MatchStyle', FMatchStyle, 'verbose', 0);

                % provides: 'SF_fmatrixsearch', 'SF_fmsectionlist', 'SF_fmatrixtrain', 'SF_searchwindow', 'SF_trainlabellist'
                main_spotloadfeatures;

                % extract features for train/test sections from search matrix
                classtrainlabels = segment_findlabelsforclass(classlabels2segments(trainSegGT), thisTargetClasses(classnr));
                classtrainlabels(segment_findidentical(classtrainlabels),:) = [];
                if ~segment_issorted(classtrainlabels), error('classtrainlabels not sorted!'); end;
                [sel idx iidx] = segment_findequals(SF_trainlabellist, classtrainlabels);
                if sum(sel)~=size(classtrainlabels,1), error('Could not find all sections for train.'); end;
                fmtrain = [ fmtrain; SF_fmatrixtrain(:,usedfeatures) ];
                trainlabels = [ trainlabels; classtrainlabels(iidx,:) ];

                classtestlabels = segment_findlabelsforclass(classlabels2segments(testSLC), thisTargetClasses(classnr));
                if ~segment_issorted(classtestlabels), error('classtestlabels not sorted!'); end;
                if ~isempty(segment_findidentical(classtestlabels)), error('\n%s: INFO: Found identical test sections!', mfilename); end;
                %[sel idx iidx] = segment_findequals(SF_fmsectionlist, classtestlabels);
                sel = segment_findequals(SF_fmsectionlist, classtestlabels);
                if sum(sel)~=size(classtestlabels,1), error('Could not find all sections for test.'); end;
                fmtest = [ fmtest; SF_fmatrixsearch(sel, usedfeatures) ];
                testlabels = [ testlabels;  classtestlabels ];  % SF_fmsectionlist(sel,:)   classtestlabels(iidx,:)

                clear SF_fmatrixtrain SF_fmatrixsearch;
            end; % for classnr
        end;  % if (DoLoad)



        testSegBest = cell(1,CVFolds); trainSegBest = cell(1,CVFolds);
        for cvi = 1:CVFolds
            fprintf('\n%s: CV%u: ', mfilename, cvi);
            if isempty(testSLC{cvi}), 	testSegBest{cvi} = [];  fprintf(' No spotting results to classify.'); continue; end;
            if isempty(trainSegGT{cvi}),  % most certainly single classes affected only
                %trainSegGT{cvi} = trainSegGT{cvi-1};
                error('\n%s:   No training objects found???', mfilename);
            end;

            fprintf(' Train: %u (tentatives: %u), Test: %u...', ...
                size(trainSegGT{cvi},1), sum(trainSegGT{cvi}(:,6)<LabelConfThres), size(testSLC{cvi},1));

            % determine non-skewed train objects partition
            this_trainlist = trainSegGT{cvi}(trainSegGT{cvi}(:,6)>=LabelConfThres,:);
            ntrainobjs = zeros(1, length(thisTargetClasses));
            for c = 1:length(thisTargetClasses), ntrainobjs(c) = sum(this_trainlist(:,4)==thisTargetClasses(c)); end;

            toolow = find(ntrainobjs(:)<max(ntrainobjs)*0.3);  % OAM REVISIT: This measure is weak
            for c = row(toolow)
                fprintf('\n%s:   *** Not enough training objects (%u) for class %u (%u)!', mfilename, ntrainobjs(c), c, thisTargetClasses(c));
                this_trainlist(this_trainlist(:,4)==thisTargetClasses(c),:) = [];  % delete objects for this class (if any)
                for i = cvi-1:-1:1  % search backwards to find a suitable replacement
                    replsegs = trainSegGT{i}(trainSegGT{i}(:,4)==thisTargetClasses(c),:);
                    replsegs(replsegs(:,6)<LabelConfThres,:) = [];
                    if size(replsegs,1)>=max(ntrainobjs)*0.3, break; end; % leave if replacement CV found
                end;
                if size(replsegs,1)==0, error('No solution found! This cannot be!!!'); end;
                if size(replsegs,1)<max(ntrainobjs)*0.3,
                    fprintf('\n%s: WARNING: Few objects for class %u: %u!', mfilename, c, size(replsegs,1));
                end;

                this_trainlist = segment_sort( [ this_trainlist; replsegs ] );
                ntrainobjs(c) = size(replsegs,1);
            end;

            for c = 1:length(thisTargetClasses)
                tmplist = segment_findlabelsforclass(this_trainlist, thisTargetClasses(c));
                this_trainlist(this_trainlist(:,4)==thisTargetClasses(c),:) = [];
                this_trainlist = segment_sort([ this_trainlist; tmplist(1:min(ntrainobjs),:) ]);
                % OAM REVISIT: Should use permutation
            end; % for c
            % WARNING: this_trainlist is resorted and does NOT coincide with trainlabels/fmtrain!

            % spotters may produce similar results - use all available info to determine train objects
            this_trainobjs = segment_findequals(trainlabels, this_trainlist, 'CheckCols', 1:2);
            this_testobjs = segment_findequals(testlabels, testSLC{cvi}, 'CheckCols', 1:2); % take all ;-)
            if sum(this_testobjs>0)~= size(testSLC{cvi},1), error('Test section cols not individual!'); end;

            [dummy ntrain] = countele(this_trainlist(:,4));  [dummy ntest] = countele(testSLC{cvi}(:,4));
            fprintf('\n%s:   Train: %s, Test: %s', mfilename, mat2str(ntrain), mat2str(ntest));

            % from main_isoclassify:

            % clipping, standardise
            [nfmtrain nfmtest] = clipnormstandardise( fmtrain(this_trainobjs,:), 	fmtest(this_testobjs,:), ...
                'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, 'verbose', 0);

            % fsel
            fweighting = fselEvalFeatures(FSelMethod, nfmtrain, trainlabels(this_trainobjs,4), 'NSelFeatures', FSelFeatureCount);
            [nfmtrain nfmtest Filtered_FeatureString] = fselPostApplyWeights(FSelMethod, fweighting, ...
                nfmtrain, nfmtest, SF_FeatureString);

            % classify
            fprintf('\n%s:   Features to classify: %u', mfilename, size(nfmtrain,2));
            fprintf('\n%s:   Run classifier %s (%s)...', mfilename, ClassifierName, cell2str(ClassifierParams));
            switch ClassifierName
                case {'NB', 'NBayes', 'NaiveBayes'}
                    [thispredicted thisscore] = naivebayes(nfmtrain, trainlabels(this_trainobjs,4), nfmtest);
                case {'NCC', 'NearestCenter', 'NearestCentroid'}
                    [thispredicted thisscore] = nearestcentroid(nfmtrain, trainlabels(this_trainobjs,4), nfmtest);
                otherwise
                    error('ClassifierName not supported');
            end;  % switch ClassifierName

            % classification uses train partition of spotting and adapts
            % that - this does not mean further steps should be restricted to this subset.
            trainSegBest{cvi} = trainlabels(this_trainobjs,:);
            %trainSegBest{cvi} = trainSLC{cvi};

            testSegBest{cvi} = testSLC{cvi};

            % just plug-in OR fuse ??
            testSegBest{cvi}(:,4) = thispredicted;

            for i = 1:length(thispredicted)
                testSegBest{cvi}(i,6) = thisscore(i, thisTargetClasses==thispredicted(i));
            end;
            % plot(thispredicted)
            % plot(thisscore)
        end;  % for cvi

        % 		trainSegGT  ??

%% SEQ, SEQIDOP
    case { 'SEQ', 'SEQIDOP' }  % sequence isolation and ID operation
        % will remove all events that:
        % - fall outside a valid sequence
        % - do not belong to a TargetClass
        if strcmp(InSpotType, 'SFUS'), error('Incompatible spotting file input, works with SIMS/SFCV only.'); end;
        if (ReloadGT), fprintf('\n%s: WARNING: ReloadGT=%s', mfilename, mat2str(ReloadGT)); end;

        [trainSegBest testSLC trainSegGT testSegGT CVFolds ] = ...
            prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
            'BestThresOnly', UseBestThres, 'MergeSpotters', true, 'MergeCV', false, 'MaxThresOnly', ~UseBestThres, ...
            'SpotType', InSpotType, 'ConvertDistance', ConvertDistance, 'ReloadGT', ReloadGT, 'verbose',2);

        % approaches:
        % 1. apply on COMP results => plain majority of most frequent class
        % 2. look at distribution of class on train set, apply on test set???
        % 3. use overall highest confidence to determine class

        % code similar to main_chewcorrelation

        % WARNING: Sequences must fit into CV fold bouds!
        testSegBest = cell(1,CVFolds);  cmetrics  = zeros(length(thisTargetClasses));
        for cvi = 1:CVFolds
            fprintf('\n%s: CV%u: sections: %u ', mfilename, cvi, size(testSLC{cvi},1));
            testSLC{cvi} = segment_sort(testSLC{cvi});

            % find all GT labels that are in CV fold (testSegGT stores TargetClasses only)
            % OAM REVISIT: This is a hack!
            filename = spot_isfile(InSpotType, SimSetID_List{1}, thisTargetClasses(1));
            testslices = loadin(filename, 'testslices');
            cv_labellist = labellist_load(segment_countoverlap(labellist_load, testslices{cvi}) > 0, :);

            % create sequence groups using sequence marks
            % all complete labels between seqlabels are extracted from chewseglist and filtered using findlabelids
            SeqList = cla_seqfinder(testSLC{cvi}, segment_findlabelsforclass(cv_labellist, Repository.SeqClasses) );
            % 			'findlabelids', Repository.ChewClasses);

            % remove unused sequences (unconsidered TargetClasses)  % unique(testSLC(:,4))
            unusedclasses = Repository.ChewClasses(~findn(Repository.ChewClasses, thisTargetClasses));
            rmseqs = ~isemptycell(cla_seqfinder(...
                segment_findlabelsforclass(cv_labellist, unusedclasses), ...
                segment_findlabelsforclass(cv_labellist, Repository.SeqClasses),  'verbose', 0 ));

            % remove sequences containing sync labels (sequences are created from last seq mark of
            % one PI to the first mark in the following PI)
            rmseqs = rmseqs | ~isemptycell(cla_seqfinder(...
                segment_findlabelsforclass(cv_labellist, Repository.SyncClasses), ...
                segment_findlabelsforclass(cv_labellist, Repository.SeqClasses),  'verbose', 0 ));

            % exclude Drink gestures (by definition, SeqClasses labels are in gesture label)
            % last seqlabel has no overlap with gesture, hence omit it
            tmp = segment_countoverlap(...
                segment_findlabelsforclass(cv_labellist, Repository.SeqClasses), ...
                segment_findlabelsforclass(cv_labellist, Repository.GestureDrinkClasses) ) > 0;
            rmseqs = rmseqs | tmp(1:end-1);

            %SeqListGTAll = cla_seqfinder(cv_labellist, segment_findlabelsforclass(cv_labellist, Repository.SeqClasses), 'verbose', 0);
            % s = segment_findlabelsforclass(cv_labellist, Repository.SeqClasses);
            % t = find(~rmseqs);  SeqList(t)

            if isempty(SeqList) || all(rmseqs)
                % SeqList = {} may occur if  no seq labels where found in the CV fold.
                fprintf('\n%s: No relevant sequences, skipping.', mfilename);
                testSegBest{cvi} = [];
                continue;
            end;

            % check
            if any(isemptycell(SeqList(~rmseqs))), error('Found non-filled sequences. No detection here?'); end;
            SeqList(rmseqs) = [];

            fprintf('\n%s: Events per seq: %s', mfilename, mat2str(cellfun('size', SeqList,1)));

            if strcmpi(FusionMethod, 'SEQIDOP')  %~isempty(SeqOperation) && ~isemptycell(SeqOperation)
                %seqids = cla_makesectionfeatures(SeqList, {'Lsec13L_Lconfvote'});   % Lidvote  Ldistvote
                %seqids = cla_makesectionfeatures(SeqList, {'Lconfvote'});   % Lidvote  Ldistvote
                seqids = cla_makesectionfeatures(SeqList, SeqOperation);   % Lidvote  Ldistvote

                % remove looser events from sequences
                for i = 1:length(SeqList)
                    SeqList{i}(SeqList{i}(:,4)~=seqids(i),:) = [];
                    %SeqList{i}(:,4) = seqids(i);
                end; % for i

                % count correct/false seq
                SeqListGT = cla_seqfinder(segment_findlabelsforclass(cv_labellist, thisTargetClasses), ...
                    segment_findlabelsforclass(cv_labellist, Repository.SeqClasses), 'verbose', 0);
                SeqListGT(rmseqs) = [];
                seqidsGT = cla_makesectionfeatures(SeqListGT, {'Lidvote'});

                % 		seqidsGT = zeros(1, length(SeqListGT));
                % 		for i = 1:length(SeqListGT),
                % 			if isempty(SeqListGT{i}), continue; end;
                % 			seqidsGT(i) = mean(SeqListGT{i}(:,4));
                % 		end;

                cmetrics = cmetrics + cmetrics_mkmatrix(seqidsGT, seqids, 'classids', thisTargetClasses);
            end;

            testSegBest{cvi} = segment_sort(classlabels2segments(SeqList));  % sure ????

        end; % for cvi

        fprintf('\n\n');
        if strcmpi(FusionMethod, 'SEQIDOP'),  disp(cmetrics); end;

        % 		% reset thisTargetClasses, iff applied on SFUS fusion (thisTargetClasses=1)
        % 		if strcmp(InSpotType, 'SFUS')
        % 			thisTargetClasses = unique(seqids);
        % 		end;


%% MERGE
    case 'MERGE'  % just merge spotters, do nothing else
        [trainSLC testSLC trainseglist testseglist CVFolds ] = ...
            prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
            'BestThresOnly', UseBestThres, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', ~UseBestThres, ...
            'SpotType', InSpotType, 'ConvertDistance', false, 'verbose',2);

        testSL = testSLC;   testSC = testSLC(:,6);



%% MVOTE
    case  'MVOTE'   % apply a sliding window to select class (majority vote), generates new sections
        % requires:
        %   MVoteWindow - sliding window size
        if strcmp(InSpotType, 'SFUS'), error('Incompatible spotting file input, works with SIMS/SFCV only.'); end;

        [trainSegBest testSLC trainSegGT testSegGT CVFolds ] = ...
            prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
            'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', false, 'MaxThresOnly', false, ...
            'SpotType', InSpotType, 'ConvertDistance', false, 'ReloadGT', false, 'verbose',2);


        testSegBest = cell(1,CVFolds);  cmetrics  = zeros(length(thisTargetClasses));
        for cvi = 1:CVFolds
            fprintf('\n%s: CV%u: sections: %u ', mfilename, cvi, size(testSLC{cvi},1));
            testSLC{cvi} = segment_sort(testSLC{cvi});

            %swlist = segment_createswlist(MVoteWindow, MVoteWindow, size(testSLC{cvi},1));
            swlist = segment_createswlist(MVoteWindow*mean(segment_size(testSLC{cvi})), MVoteWindow*mean(segment_size(testSLC{cvi})), testSLC{cvi}(end,2) );
            SeqList = cell(size(swlist,1),1);  progress = 0.1;  fprintf('\n%s: Wait...', mfilename);
            for i = 1:size(swlist,1)
                progress = print_progress(progress, i/size(swlist,1));
                %SeqList{i} = testSLC{cvi}(swlist(i,1):swlist(i,2),:);
                SeqList{i} = testSLC{cvi}(segment_findincluded(swlist(i,1:2),  testSLC{cvi}), :);
            end;
            fprintf('\n%s: Events per seq: %s', mfilename, mat2str(cellfun('size', SeqList,1)));

            seqids = cla_makesectionfeatures(SeqList, SeqOperation);   % Lidvote  Ldistvote

            % create new list
            for i = 1:length(SeqList)
                if isempty(SeqList{i}), continue; end;
                testSegBest{cvi}(i,:) = segment_createlist( [SeqList{i}(1,1), SeqList{i}(end,2)], 'classlist', seqids(i), 'conflist', mean(SeqList{i}(:,6)));
                %testSegBest{cvi}(i,:) = segment_createlist( swlist(i,1:2) , 'classlist', seqids(i), 'conflist', mean(SeqList{i}(:,6)));
            end; % for i
            % remove zero-entries that result from for-loop above
            testSegBest{cvi}(sum(testSegBest{cvi}, 2)==0, :) = [];

            fprintf('\n%s: Performance: ', mfilename);
            thismetric = cmetrics_mkstats(cmetrics_mkmatrixfromseg(testSegGT{cvi}, testSegBest{cvi}, ...
                'LabelConfThres', LabelConfThres, 'CountNullClass', false, 'ClassIDs', thisTargetClasses));

            cmetrics = cmetrics + thismetric.confusion;
        end; % for cvi

        fprintf('\n\n');
        disp(cmetrics_mkstats(cmetrics));
        metric_FUSION = cmetrics;
        trainSegMax = {};  testSegMax = {};
        




    case 'HIST'  % ??

    otherwise
        error('Fusion method %s not supported.', FusionMethod);
end;




%% CONCLUSION

% create data structs for SFUS mode
if ~exist('testSL','var')
    testSL = classlabels2segments(testSegBest);   testSC = testSL(:,6);
    testseglist = classlabels2segments(testSegGT);
end;

% statistics
fprintf('\n%s: Fusion spotting result, ignoring class labels (method %s):', mfilename, FusionMethod);
totalmetric_FUSION = prmetrics_softalign(testseglist, testSL, 'LabelConfThres', LabelConfThres, 'jitter', section_jitter);
prmetrics_printstruct(totalmetric_FUSION);

fprintf('\n%s: Segments coverage: GT labels:%.1f%%,  total data: %.1f%%', mfilename, ...
    sum(segment_size(testSL))/sum(segment_size(testseglist))*100, sum(segment_size(testSL))/testseglist(end,2));


fprintf('\n%s: Class-wise fusion result (method %s):', mfilename, FusionMethod);
clear metric_FUSION;
for class = 1:length(thisTargetClasses)
    metric_FUSION(class) = prmetrics_softalign( ...
        segment_findlabelsforclass(testseglist, thisTargetClasses(class)), ...
        segment_findlabelsforclass(testSL, thisTargetClasses(class)), 'LabelConfThres', LabelConfThres, 'jitter', section_jitter );
end;
prmetrics_printstruct(metric_FUSION);


% prepare for saving
switch upper(OutSpotType)
    case 'SFUS'
        % make report files compatible with other spotting output files, i.e. 'SIMS'
        testSegBest = testSL;   trainSegBest = {[]};
        testSegGT = testseglist;  trainSegGT = {[]};
        metrics = metric_FUSION;  CVFolds = 1;  bestthres = 0; mythresholds = []; trainslices = {}; testslices = {};
        filename = repos_makefilename(Repository, 'prefix', 'SFUS', 'indices', 1, 'suffix', SimSetID, 'subdir', 'SPOT');
    case 'SFCV'
        % needed for prepspotresults processing
        % 		for cvi = 1:CVFolds
        % 			trainSeg{cvi} = trainSeg(cvi); trainDist{cvi} = trainDist(cvi);
        % 			testSeg{cvi} = testSeg(cvi); testDist{cvi} = testDist(cvi);
        % 		end;
        metrics = metric_FUSION;  bestthres = ones(1, CVFolds);
        mythresholds = cell(1, CVFolds);  [mythresholds{1:CVFolds}] = deal(0);
        filename = repos_makefilename(Repository, 'prefix', 'SFCV', 'indices', thisTargetClasses(1), 'suffix', SimSetID, 'subdir', 'SPOT');
    otherwise
        error('FusionType ''%s'' not supported.', FusionType);
end;

trainSegMax = {}; testSegMax = {};

% save it
if (DoSave)
    SaveTime = clock;
    fprintf('\n%s: Save (%s) %s...', mfilename, OutSpotType, filename);
    save(filename, ...
        'trainSegBest', 'testSegBest', 'trainSegMax', 'testSegMax', ...
        'trainSegGT', 'testSegGT', ...
        'bestthres', 'mythresholds', ...
        'metrics', 'section_jitter', ...                                    % , 'classmetric_SIM', 'totalmetric_SIM'
        'trainslices', 'testslices', ...
        'thisTargetClasses',  'Partlist',  'CVFolds', 'DoNorm', ...
        'InSpotType', 'OutSpotType', ...
        'LabelConfThres', 'FusionMethod', 'MergeMethod', ...
        'SpottingMethod', 'SpottingMethod_Params', 'ThresholdMethod_Params', ...
        'ClassifierName', 'ClassifierParams', 'FSelMethod', 'FMatchStyle', 'FSelFeatureCount', 'FeatureString', ...
        'StartTime', 'SaveTime', 'VERSION');
    fprintf('done.');
end;


if (DoDeleteSimSetID_List)
    clear SimSetID_List DoDeleteSimSetID_List;
end;
fprintf('\n');

