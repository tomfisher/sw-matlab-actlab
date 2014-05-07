% main_spotclassify
%
% Process data and classify sections using preprocessed features. 
% Processes all classes in parallel (using same features). Does not permit varable length sections.

% requires
Partlist;
SimSetID;
FeatureString;


VERSION = 'V003';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if ~exist('CVFolds','var'), CVFolds = 10; end;
if ~exist('CVMethod', 'var'), CVMethod = UserMode; end;  % CVMethod = 'intrasubject';
if ~exist('FSelMethod', 'var'), FSelMethod = 'none'; end;  % perform feature selection
if ~exist('FSelFeatureCount','var'), FSelFeatureCount = 20; end;   % nr of features to select
if ~exist('FMatchStyle','var'), FMatchStyle = 'lazy'; end;   % style to enable features (lazy / exact)

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit labels below confidence thres during training
if ~exist('PRLabelConfThres','var'), PRLabelConfThres = LabelConfThres; end;   % omit labels below confidence thres for metrics/testing
if ~exist('Greylist','var'), Greylist = []; end;   % omit labels during training

if ~exist('DoNorm','var'), DoNorm = true; end;  % DoNorm = false;
if (~exist('DoClip','var')) || (~DoNorm), DoClip = DoNorm; end;
if ~exist('DoClipLimit','var'), DoClipLimit = 10;  end; % limit: DoClipLimit*std(feature)
fprintf('\n%s: Normalise: %s,  Clipping: %s, Limit: %.1f*SD', mfilename, mat2str(DoNorm), mat2str(DoClip), DoClipLimit);
if ~exist('DoLoad', 'var'), DoLoad = true; end;   % load features
if ~exist('DoSave', 'var'), DoSave = true; end;   % save result
if ~exist('DebugMaxCVI', 'var'), DebugMaxCVI = inf; end;   % max CVFolds for debugging
if DebugMaxCVI<inf, fprintf('\n%s: *** CVFolds debugging configured, DebugMaxCVI=%u', mfilename, DebugMaxCVI); end;
if ~exist('DoReplaceTrainSeg', 'var'), DoReplaceTrainSeg = false; end;   % replace training objects with best segmentation version

% from initmain:
labellist_load;
% initmain has renumbered classes, this is not what we want for spotting
% computation. It would prevent class-specific runs (individual
% featuresets) and result saving/merging of multiple classes.
% if (~exist('ClassIDMode', 'var')), ClassIDMode = 'keepid'; end;
% fprintf('\n%s: ClassIDMode: %s.', mfilename, ClassIDMode);
[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');
if (length(thisTargetClasses)>1), DoLoad = true; end;

if ~exist('mintrainshare','var'),  mintrainshare = 0.1; end;

% guess segmentation config for each class
% OAM REVISIT: could be reduced to one segmentation info
initmain_segconfig;

if ~exist('SpottingMethod','var'), SpottingMethod = 'NCC'; end;
if ~exist('SpottingMethod_Params','var'), SpottingMethod_Params = {}; end;
if ~exist('SpottingMode','var'), SpottingMode = 'fixed'; end;
if ~exist('SpottingSearchWindow','var'), SpottingSearchWindow = 0.3; end;  % in sec
fprintf('\n%s: Spotting method: %s (%s), search mode: %s', mfilename, ...
	SpottingMethod, cell2str(SpottingMethod_Params, ', '), SpottingMode);
fprintf('\n%s: CVMethod: %s', mfilename, CVMethod);

if ~exist('PRPruneMethod_Params','var'), PRPruneMethod_Params = { 'Enable', 0 }; end;

if ~exist('CVSectionBounds','var'), CVSectionBounds = []; end;  % CV cutting bounds, empty=labels are used

SampleRate =  repos_getmarkersps(Repository, Partlist(1), 'singlesps', true);


% ------------------------------------------------------------------------
% Spotting for ALL classes in parallel
% ------------------------------------------------------------------------

if (DoLoad)
	SF_fmatrixsearch = []; SF_fmsectionlist = []; SF_fmatrixtrain = []; SF_trainlabellist = [];
    CSF_fmatrixtrain = [];  CSF_trainlabellist = [];
end;
for classnr = 1:length(thisTargetClasses)
	fprintf('\n%s: Processing features for class %u...', mfilename, thisTargetClasses(classnr));

	% load search features (precomputed) and index list (main_spotfeatures.m)
    % overwritten by consequitive calls: 'SF_fmatrixsearch', 'SF_fmsectionlist', SF_FeatureString_load
    % copied to maintain for each class: 'SF_fmatrixtrain', 'SF_trainlabellist'
	if (DoLoad)
		main_spotloadfeatures;
	end;

    
    if (DoLoad)
        % OAM REVISIT: check compatible settings for each class
        
        % adapt seglist, fmatrix to MergeClassSpec class settings (remove labels only!)
        % 	fprintf('\n%s:   Adapt segmentation search list to MergeClassSpec...', mfilename);
        % 	[SF_fmsectionlist thisTargetClasses removed] = segment_classfilter(MergeClassSpec, SF_fmsectionlist);
        % 	SF_fmatrixsearch(removed, :) = []; % remove observations that are not in spec
        % 	fprintf(' %u removed', length(find(removed>0)));
        fprintf('\n%s:   Adapt train label list to MergeClassSpec...', mfilename);
        [SF_classlabellist dummy removed] = segment_classfilter(MergeClassSpec, SF_trainlabellist, 'ClassIDMode', 'keepid');
        SF_fmatrixtrain(removed, :) = []; % remove observations that are not in spec
        fprintf(' %u removed', length(find(removed>0)));


        % adapt features to FeatureString
        [usedfeatures SF_FeatureString] = fb_findusedfeatures(SF_FeatureString_load, FeatureString, 'MatchStyle', FMatchStyle);


        SF_fmatrixtrain(:,~usedfeatures) = []; % remove columns that are not requested
        SF_fmatrixsearch(:,~usedfeatures) = []; % remove columns that are not requested
        fprintf(' enabled: %u, match style: %s', sum(usedfeatures), FMatchStyle);

        % store for each class
        CSF_fmatrixtrain = [ CSF_fmatrixtrain; SF_fmatrixtrain ];
        CSF_trainlabellist = [ CSF_trainlabellist;  SF_classlabellist ];
    end; % if (DoLoad)
end; % for classnr
clear('SF_classlabellist', 'SF_trainlabellist', 'SF_fmatrixtrain');
clear('classlabellist');

% due to independent feature processing for each class, resorting required
[CSF_trainlabellist idx] = segment_sort(CSF_trainlabellist);
SF_fmatrixtrain = CSF_fmatrixtrain(idx, :);  clear('CSF_fmatrixtrain');

% find labels for target classes
classlabellist = segment_findlabelsforclass(labellist, thisTargetClasses);

% checks
if any(any(CSF_trainlabellist(:,1:4) ~= classlabellist(:,1:4))), error('Seglists do not match.'); end;
% find(segment_findequals(classlabellist, CSF_trainlabellist)~=1)
if ( size(classlabellist,1) ~= size(SF_fmatrixtrain,1) ), error('Train matrix and classlabellist do not match.'); end;
if ( (length(SF_FeatureString) ~= size(SF_fmatrixsearch,2))  ||  (length(SF_FeatureString) ~= size(SF_fmatrixtrain,2) ) )
    error('Feature list and feature matrix do not match.');
end;
if (thisTargetClasses ~= row(unique(classlabellist(:,4)))),  error('No observations found.'); end;
if (length(partoffsets) ~= length(Partlist)+1), error('Partlist and partoffsets do not match. Rerun initmain.'); end;
repos_findlabelsforpart(classlabellist, 1:length(Partlist), partoffsets);


% segmentation points, needed for CV slice adapted search bounds
aseglist = cla_getsegmentation(Repository, Partlist, 'SampleRate',  SampleRate, ...
    'SegType', SegConfig(1).Name, 'SegMode', SegConfig(1).Mode);
aseglist(end,:) = [aseglist(end,1) partoffsets(end)]; % omit last (may exceed data size)


% replace training objects with best matching segmentation version
if (DoReplaceTrainSeg)
    [Sidx Serr] = segment_findsimilar(classlabellist, SF_fmsectionlist);
    fprintf('\n%s: Adapt training data to optimal search object...', mfilename);
    fprintf(' distance errors >50%%: %u', sum(Serr>0.5));

    for i = 1:size(SF_fmatrixtrain,1)
        % Cannot check alignment errors here, since target resolution is unknown.
        SF_fmatrixtrain(i,:) = SF_fmatrixsearch(Sidx(i),:);
    end; % for i
end;

	

% create cv splits
%   CVSectionBounds may come from any initmain_* preprocessor script
[trainslices, testslices, dotraining] = spot_createcvsplit(CVMethod, CVFolds, classlabellist, ...
    Repository, Partlist, 'mintrainshare', mintrainshare, 'LabelConfThres', LabelConfThres, ...
    'CVSectionBounds', CVSectionBounds);
	

	
	
% information containers for each CV interation (CVFolds)
allmetrics = zeros(length(thisTargetClasses));   bestthres = nan(1, CVFolds);    mythresholds = cell(1, CVFolds);
testSegBest = cell(1,CVFolds); trainSegBest = cell(1,CVFolds);
testSegMax = cell(1,CVFolds); trainSegMax = cell(1,CVFolds);
trainSegGT = cell(1,CVFolds); testSegGT = cell(1,CVFolds);
fweighting = cell(1,CVFolds); fselect = cell(1,CVFolds);

% begin CV
for  cvi = 1:CVFolds
    % find labels within slices, omit tentatives only for training (below!)
    trainseglist = classlabellist(segment_countoverlap(classlabellist, trainslices{cvi}) > 0, :);
    testseglist = classlabellist(segment_countoverlap(classlabellist, testslices{cvi}) > 0, :);
    
    fprintf('\n%s: Classes: %s  CV: %u of %u  Total: %u, Train: %u (T:%u, omit:%u), Test: %u (T:%u, omit:%u)', mfilename, ...
        mat2str(thisTargetClasses), cvi, CVFolds, size(classlabellist,1), size(trainseglist,1), ...
        size(trainseglist(trainseglist(:,6)<1,:),1), size(trainseglist(trainseglist(:,6)<LabelConfThres,:),1), size(testseglist,1), ...
       size(trainseglist(testseglist(:,6)<1,:),1), size(testseglist(trainseglist(:,6)<PRLabelConfThres,:),1) );
    fprintf('\n%s: CV trainslices: %s, testslices: %s', mfilename, mat2str(trainslices{cvi}), mat2str(testslices{cvi}) );

    % verify that there are no overlaps btw train/test
    if any(segment_countoverlap(trainseglist, testseglist)>0)
        error('Detected overlap between training and testing labels, stop.');
    end;

    % ------------------------------------------------------------------------
    % Training
    % ------------------------------------------------------------------------

    if dotraining(cvi)
        % find search boundaries for THIS CV
        tmp = segment_countoverlap(trainseglist(trainseglist(:,6)>=LabelConfThres,:), aseglist, -inf);
        switch lower(SpottingMode)
            case { 'fixed', 'maxtest' }
                %obswindow = repmat(round(mean(tmp)),1,2);
                obswindow = repmat(round(mean(tmp)) + (round(mean(tmp))==0), 1,2);
            case 'specified'
                tmp = round(SpottingSearchWindow*SampleRate/mean(segment_size(aseglist)));
                obswindow = repmat(tmp+(tmp==0), 1,2);
            otherwise
                error('Spotting mode %s not supported.', lower(SpottingMode));
        end;
        fprintf('\n%s: Search mode: %s, obswindow: %s', mfilename, lower(SpottingMode), mat2str(obswindow));

        if isempty(segment_findincluded(SF_searchwindow, obswindow))
            fprintf('\n%s: Search window is too small.', mfilename);
            fprintf('\n%s: SF_searchwindow=%s, obswindow=%s.', mfilename, mat2str(SF_searchwindow), mat2str(obswindow));
            %obswindow = SF_searchwindow;
            error('here');
        end;


        % determine section list that fit in obswindow
        % these indices are used later to reference segments from SF_fmsectionlist
        % must be same for all classes
        fprintf('\n%s:   Select feature sections...', mfilename);
        fmobsidx = [];
        obswindow_diff = abs(SF_searchwindow - obswindow);
        searchwindow_size = segment_size(SF_searchwindow);
        for i = 1:size(SF_fmsectionlist,1)/searchwindow_size
            % for every search endpoint, find relevant indices according to obswindow
            fmobsidx = [ fmobsidx (1+searchwindow_size*(i-1)+obswindow_diff(1) : searchwindow_size*(i)-obswindow_diff(2)) ];
        end;
        fmobsidx(segment_size(SF_fmsectionlist(fmobsidx,:))==0) = []; % delete zero size segments (begin of search)
        fprintf(' %u from %u selected.', length(fmobsidx), size(SF_fmsectionlist,1));


        
        % determine index, required for acessing SF_fmatrixtrain
        trainidx = find(segment_countoverlap(classlabellist, trainseglist(trainseglist(:,6)>=LabelConfThres,:)) == 1);

        % join training segment slices when adjacent
        cont_trainslices = segment_distancejoin(trainslices{cvi},2);

        
        % find sections relevant for training step
        % process continuous training slices into one selection array
        fmtrainidx = [];
        for tslice = 1:size(cont_trainslices,1)
            fmtrainidx = [fmtrainidx; segment_findincluded(cont_trainslices(tslice,:), SF_fmsectionlist(fmobsidx,:))];
        end;
        fmsectionlist = SF_fmsectionlist(fmobsidx(fmtrainidx),:);

			
        % clip and standardise data
        [fmtrain fmtest fclips fmeans fstds] = clipnormstandardise( ...
            SF_fmatrixtrain(trainidx,:), 	SF_fmatrixsearch(fmobsidx(fmtrainidx),:), ...
            'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, 'verbose', 0);



        % feature selection
        % determine features, adapt fmtrain and provide indices to change fmtest later
        % class skew issue: we make another assumpition about the distribution of events,
        % however in reality this skew will be even worse, so keep it
        fprintf('\n%s:   FSelMethod: %s, select: %u from %u, excluded train sections: %u, run...', mfilename, ...
            upper(FSelMethod), FSelFeatureCount, length(SF_FeatureString) );

        % trainlabelids = [ones(size(fmtrain,1), 1); zeros(size(fmtest_fsel,1), 1)]; % class ids: 1, 0
        trainlabelids = classlabellist(trainidx,4);
        
        % run fsel
        [fweighting{cvi} fselect{cvi}] = fselEvalFeatures(FSelMethod, ...
            fmtrain, trainlabelids,  'NSelFeatures', FSelFeatureCount);


        % apply weighting/selection
        [fmtrain fmtest Filtered_FeatureString] = fselPostApplyWeights(FSelMethod, ...
            fweighting{cvi}, fmtrain, fmtest, SF_FeatureString);


        % build classifier model
        fprintf('\n%s:   Model training %s for %u (from %u) segments...', mfilename, ...
            upper(SpottingMethod), size(trainseglist(trainseglist(:,6)>=LabelConfThres,:),1),  size(trainseglist,1));

        if strcmp(SpottingMethod, 'loadmodel')
            SpottingMethod_Params(end+1:end+2) = { 'filename', dbfilename(Repository, 'prefix', 'spotmodel' , ...
                'indices', thisTargetClasses(1), 	'suffix', SimSetID, 'subdir', 'models') };
        end;

        spotmodel = similarity_train(fmtrain, SpottingMethod, SpottingMethod_Params{:}, 'trainlabels', trainlabelids);
        if isempty(spotmodel), error('spotmodel not available.'); end;


        % process continuous training slices
        fprintf('\n%s:   Process spotmodel, sections: %u, features: %u, obswindow: %s...', ...
            mfilename, size(fmsectionlist,1), size(fmtrain,2), mat2str(obswindow));

        this_trainDist = similarity_dist( fmtest, spotmodel );
        [thisdist predictedclass] = min(this_trainDist, [], 2);
        this_trainSeg = segment_createlist(fmsectionlist, 'classlist', col(thisTargetClasses(predictedclass)), ...
            'conflist', distance2confidence(thisdist, max(this_trainDist, [], 2)) );
        
        fprintf('\n%s:     sections in relevants (%u): %s', mfilename, ...
            size(trainseglist,1), strcut(mat2str(segment_countoverlap(trainseglist, fmsectionlist, section_jitter))));

        % compute and prune metrics
        fprintf('\n%s:   Computing performance metrics...', mfilename);
        metrics_train = cmetrics_mkstats(cmetrics_mkmatrixfromseg(trainseglist, this_trainSeg, ...
            'LabelConfThres', PRLabelConfThres, 'CountNullClass', false));
        fprintf('\n%s: Norm acc: %.3f%%,  per class: %s', mfilename, metrics_train.normacc*100, ...
            num2str(metrics_train.classacc*100, ' %.3f%%'));

        bestthres(cvi) = 1;   mythresholds{cvi}(bestthres(cvi)) = inf;
        
        trainSegBest{cvi} = this_trainSeg;
        trainSegMax{cvi} = this_trainSeg;

        
        fprintf('\n%s:   Selected threshold  %u (pruned):', mfilename, bestthres(cvi));
        prmetrics_printstruct(prmetrics_splitclass(metrics_train(bestthres(cvi))));

    else
        % use settings from previous run
        bestthres(cvi) = bestthres(cvi-1);         
        fweighting{cvi} = fweighting{cvi-1};     fselect{cvi} = fselect{cvi-1};
    end; % if dotraining(cvi)

    %error('Breakpoint');


    % ------------------------------------------------------------------------
    % Testing
    % ------------------------------------------------------------------------

    % determine test data slice
    fprintf('\n%s:   Relevant test events: %u (T:%u), testslices: %s', mfilename, ...
        size(testseglist,1), size(testseglist(testseglist(:,6)<1,:),1), mat2str(testslices{cvi}));

    % adapt segmentation list (this will select the data accordingly)
    fmtestidx = segment_findincluded(testslices{cvi}, SF_fmsectionlist(fmobsidx,:));
    fmsectionlist = SF_fmsectionlist(fmobsidx(fmtestidx),:);

    fprintf('\n%s:      process similarity, method: %s, sections: %u...', mfilename, SpottingMethod, size(fmsectionlist,1));

    [dummy fmtest] = clipnormstandardise( [], 	SF_fmatrixsearch(fmobsidx(fmtestidx),:), ...
        'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, ...
        'fclips', fclips, 'fmeans', fmeans, 'fstds', fstds,  'verbose', 0);


    % apply fsel
    fmtest = fselPostApplyWeights(FSelMethod, fweighting{cvi}, fmtest);

    
    % predict class
    this_testDist = similarity_dist( fmtest, spotmodel );
    [thisdist predictedclass] = min(this_testDist, [], 2);
    this_testSeg = segment_createlist(fmsectionlist, 'classlist', col(thisTargetClasses(predictedclass)), ...
        'conflist', distance2confidence(thisdist, max(this_testDist, [], 2)) );
    
    fprintf('\n%s:      sections in relevants: %s, features: %u', mfilename, ...
        strcut(mat2str(segment_countoverlap(testseglist, fmsectionlist))), size(fmtest,2));

    % determine result performances
    fprintf('\n%s: *** Test data evaluation (%u):', mfilename, bestthres(cvi));
    thismetric = cmetrics_mkstats(cmetrics_mkmatrixfromseg(testseglist, this_testSeg, ...
        'LabelConfThres', PRLabelConfThres, 'CountNullClass', false, 'ClassIDs', thisTargetClasses));
%     fprintf('\n%s: Norm acc: %.3f%%,  per class: %s', mfilename, thismetric.normacc*100, ...
%         num2str(thismetric.classacc*100, '   %.3f%%'));
    prmetrics_printstruct(prmetrics_splitclass(thismetric));



    % store eval results in global cell array
    testSegBest{cvi} = this_testSeg;
    testSegMax{cvi} = this_testSeg;
		
    allmetrics = allmetrics + thismetric.confusion;
    
    trainSegGT{cvi} = trainseglist; testSegGT{cvi} = testseglist;

    if DebugMaxCVI <= cvi, error('Debug breakpoint reached.'); end;
end; % for cvi

fprintf('\n%s: *** Complete data evaluation:', mfilename);
prmetrics_printstruct(prmetrics_splitclass(cmetrics_mkstats(allmetrics)));

fprintf('\n%s: Selected features in last CV, run: strvcat(Filtered_FeatureString)', mfilename);

if (DoSave)
    SaveTime = clock;
    metrics = allmetrics;

    filename = dbfilename(Repository, 'prefix', 'SFCV', 'indices', thisTargetClasses(1), 'suffix', SimSetID, 'subdir', 'SPOT');
    fprintf('\n%s: Save %s...', mfilename, filename);
    save(filename, ...
        'trainSegBest', 'trainSegMax', 'testSegBest', 'testSegMax', ...
        'trainSegGT', 'testSegGT', ...
        'bestthres', 'mythresholds', 'trainslices', 'testslices', ...
        'obswindow', 'spotmodel', 'dotraining', 'fweighting', 'fselect', ...
        'metrics', 'section_jitter', ...
        'thisTargetClasses', 'MergeClassSpec', 'classlabellist', 'Partlist', ...
        'SF_FeatureString', 'FSelFeatureCount', 'FSelMethod', 'FMatchStyle', ...
        'CVFolds', 'CVMethod', 'CVSectionBounds', 'partoffsets', 'DoNorm', 'DoClip', 'SegConfig', 'mintrainshare', ...
        'SpottingMethod', 'SpottingMethod_Params', 'SpottingMode', ...
        'LabelConfThres', 'PRLabelConfThres', 'PRPruneMethod_Params', 'DoReplaceTrainSeg', ...
        'StartTime', 'SaveTime', 'VERSION');
    fprintf(' done.');
end;

fprintf('\n\n');
