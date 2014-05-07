% main_isoclassify
% 
% Perform isolated classification
% 
% Copyright 2008, 2011 Oliver Amft

% requires
Partlist;
fidx;
SimSetID;
TargetClasses;
FeatureString;
DSSet;

VERSION = '017';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if ~exist('CVFolds', 'var'), CVFolds = 10; end;
if ~exist('CVMethod', 'var'), CVMethod = 'intrasubject'; end;


if ~exist('ClassifierName', 'var')
    %ClassifierName = 'KNN'; ClassifierParams = {5}; 
    ClassifierName = 'NBayes'; ClassifierParams = {''};
    %ClassifierName = 'WEKA_IBk'; ClassifierParams = {'-K', '5'};
    %ClassifierName = 'WEKA_C45'; ClassifierParams = {};
    %ClassifierName = 'C45'; ClassifierParams = {0.25};
    %ClassifierName = 'GMM'; ClassifierParams = {[1 1]};
    %ClassifierName = 'NCC'; ClassifierParams = {''};
end;

if ~exist('DoLoad', 'var'), DoLoad = true; end;   % load/compute features
if ~exist('DoErrEval', 'var'), DoErrEval = false; end;   % save result
if ~exist('DoSave', 'var'), DoSave = true; end;   % save result
if ~exist('IgnoreFileVersion', 'var'), IgnoreFileVersion = false; end;   % ignore feature file version

if ~exist('FSelMethod', 'var'), FSelMethod = 'none'; end;  % perform feature selection
if ~exist('FMatchStyle','var'), FMatchStyle = 'lazy'; end;   % style to enable features (lazy / exact)
if ~exist('FSelFeatureCount','var'), FSelFeatureCount = length(thisTargetClasses)-1; end;   % nr of features to select
if ~exist('FeaturePathPriority', 'var'), FeaturePathPriority = 0; end;  % >0: restrict location for feature files

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit below confidence thres during training
if ~exist('PRLabelConfThres','var'), PRLabelConfThres = 0; end;   % omit below confidence thres during testing

if ~exist('DoNorm', 'var'), DoNorm = true; end;  % normalise features
if ~exist('DoClip','var'), DoClip = DoNorm; end;
if ~exist('DoClipLimit','var'), DoClipLimit = 10;  end; % limit: DoClipLimit*std(feature)


% initmain;    % should be run independently
% these parameters are needed:
% thisTargetClasses, MergeClassSpec, labellist, partoffsets
labellist;

% description of feature strings
% FeatureString - Features requested for inclusion in eval (manual selection) 
% fm_FeatureString_load - computed and expanded feature string BEFORE manual selection 
% fm_FeatureString - computed and expanded feature string AFTER manual selection
% FilteredFeatureString - Features AFTER automatic feature selection stage

% ------------------------------------------------------------------------
% 0. comination of features
% ------------------------------------------------------------------------
if (DoLoad)
    % Variables: fmatrix, seglist, fm_FeatureString
    fprintf('\n%s: Process features...', mfilename);
	
	% load precomputed features
    [fmatrix found fm_seglist fm_partoffsets fm_FeatureString] = fb_loadfeatures( ...
		Repository, Partlist, 'fidx', fidx, 'IgnoreFileVersion', IgnoreFileVersion, 'Subject', Subject, ...
		'StopOnNotFound', false, 'FeaturePathPriority', FeaturePathPriority);

	if (found)
        % Under ideal circumstances seglist and labellist coincide. We check this here by converting 
        % the list from feature files in the same way.
        
		% adapt seglist, fmatrix to MergeClassSpec class settings (remove labels only!)
		fprintf('\n%s:   Adapt seglist to MergeClassSpec...', mfilename);
		%[seglist thisTargetClasses removed] = segment_classfilter(MergeClassSpec, fm_seglist, 'ClassIDMode', 'keepid');
		[seglist thisTargetClasses removed] = segment_classfilter(MergeClassSpec, fm_seglist);
		fmatrix(removed, :) = []; % remove observations that are not in spec
		fprintf(' %u removed', sum(removed));
        
        % adapt seglist, fmatrix to labellist settings (remove labels only!)
		fprintf('\n%s:   Comparing seglist to labellist...', mfilename);
        lost = segment_findequals(seglist, labellist);          % OAM REVISIT: 'CheckCols', [1 2 6]  % check that confidence coincides
        if any(lost == 0), error('Label lists do not coincide'); end;
        fprintf('OK.');  %seglist = labellist;        
        
		% adapt features to FeatureString
        fm_FeatureString_load = fm_FeatureString;
		[usedfeatures fm_FeatureString] = fb_findusedfeatures(fm_FeatureString, FeatureString, 'MatchStyle', FMatchStyle);
		fmatrix(:,~usedfeatures) = []; % remove columns that are not requested
        fprintf('\n%s:   Selected %u of %u available features.', mfilename, length(fm_FeatureString), length(fm_FeatureString_load));
	else
		% compute features here
		seglist = labellist;
		[fmatrix fm_FeatureString] = fb_computefeatures(Repository, Partlist, ...
			FeatureString, DSSet, seglist, partoffsets, 'SaveFeatures', false);
	end;  % 	if (found)
end;  % if (DoLoad)


% check that label list and features match (crude)
if isempty(fmatrix), error('Feature matrix is empty.'); end;
if ( size(seglist,1) ~= size(fmatrix,1) ), 	error('Segment list and feature matrix do not match.'); end;
if ( length(fm_FeatureString) ~= size(fmatrix,2) ), error('Feature list and feature matrix do not match.'); end;
if ( ~all(findn(1:length(thisTargetClasses), unique(seglist(:,4)))) ), error('Some classes have no observations.');  end;
% % if ( ~all(findn(thisTargetClasses, unique(seglist(:,4)))) ), error('Some classes have no observations.');  end;

% % apply LabelConfThres
% fprintf('\n%s:   Adapt seglist to LabelConfThres (%u)...', mfilename, LabelConfThres);
% sellabels = seglist(:,6)>=LabelConfThres;
% fprintf(' %u of %u labels selected.', sum(sellabels), size(seglist,1));
% seglist = seglist(sellabels,:);


% ------------------------------------------------------------------------
% CV
% ------------------------------------------------------------------------


fprintf('\n%s: Performing CV, CVFolds = %u, CVMethod:%s...', mfilename, CVFolds, CVMethod);

% determine subject ID for each label (seglist)
% works only when all parts are loaded => partoffsets
subjectnames = repos_getsubjects(Repository, Partlist);
subjectidlist = zeros(size(seglist,1), 1);
for s = 1:length(subjectnames)
	[dummy subjectpartidx] = repos_getpartsforsubject(Repository, Partlist, subjectnames{s});
	for partno = 1:length(subjectpartidx)
		[dummy partlabelidx] = repos_findlabelsforpart(seglist, subjectpartidx(partno), partoffsets);
		subjectidlist(partlabelidx) = s;
	end;
end;
seglist(:,end+1) = subjectidlist; % append subjectidlist to seglist
fprintf('\n%s:   size(seglist)=%s', mfilename, mat2str(size(seglist)));


% determine all label indices
allIndices = cell(1, length(thisTargetClasses));
for class = 1:length(thisTargetClasses)
    %allIndices{class} = col(find(seglist(:,4) == thisTargetClasses(class)));
	%allIndices{class} = col(find(seglist(:,4) == class));
    allIndices{class} = col(find( (seglist(:,4) == class) & (seglist(:,6) >=LabelConfThres) ));
end;

% apply LabelConfThres
% Here we trick the CV preparation code: labels that should not go into the model estimation
% have been removed from the list. They are readded to the test lists after the CV setup is made.
sellabels = seglist(:,6)>=LabelConfThres;
fprintf('\n%s: Training: %u of %u labels selected.', mfilename, sum(sellabels), size(seglist,1));


switch lower(CVMethod)
	case 'intrasubject'
        [trainIndices, testIndices] = prepisocv(allIndices, CVFolds); % returns some used testlabels
		%[trainIndices, testIndices] = classgroupcv(seglist(:,4), [], 'CVFolds', CVFolds);
		
        %[trainIndices, testIndices] = classcv(seglist(:,4), 'CVFolds', CVFolds, 'ReturnIdx', true); % uneven test label distribution 
		
		
	case 'intersubject'
		% create list of labels (alternating for all subjects), select >1 obs
		% for testing from each subject (balancing training modus) -
		% otherwise CV may perform 'newsubject' mode

		for class = 1:length(thisTargetClasses)
			%[dummy, idx] = sortm(subjectidlist(allIndices{class}), 'alt');
			[dummy, idx] = sortm(subjectidlist(allIndices{class}), 'Mode', 'rand');
			allIndices{class} = allIndices{class}(idx,:);
		end;
		[trainIndices, testIndices] = prepisocv(allIndices, CVFolds);
		
		
	case 'newsubject'
		% select (subjects-1) for training, one for testing
		% seglist=list of all labels, subjectidlist=list of IDs for each label
		% use const training obs size for all classes, NOT CVs
		
        CVFolds = length(subjectnames);
        %[TR TE CVSliceSize] = classcv(ones(length(subjectnames),1), 'CVFolds', CVFolds);
        [trainIndices testIndices] = classgroupcv(seglist, subjectidlist, 'ClassCol', 4, 'ReturnIdx', true);
        
	case 'daysvalidation'
		% CV on eval days, e.g. train on 1 day, verify using 2nd day, etc.
		% Determine CV bound from PI recording date differences

        dnumarray = datevec(repos_getrecdate(Repository, Partlist));
        daynumlist = dnumarray(:,1)*1e4 + dnumarray(:,2)*1e2 + dnumarray(:,3);
        
        % If PIs are not sorted to match recording days beforehand they are treated as independent
        % This may be changed for the isolated analysis case here, as instances could be resorted.
		sessionlimit = partoffsets([true; diff(daynumlist) ~= 0]);
		% if there is no break in the sessions try
		if ~any(diff(daynumlist)~=0), error('Could not find appropriate session limits.'); end;

		% CV bounds are given by session limits of individual days
		dataslices = offsets2segments(sessionlimit); % [ 1 partoffsets(sessionlimit+1) partoffsets(end) ];
        dataslices = [ dataslices(:,1:2); dataslices(end,2)+1 partoffsets(end) ];

        % some self-checking
        if size(dataslices,1) ~= sum(diff(daynumlist)~=0)+1, error('Did some mistake in day-wise CV calculation'); end;
        
        % adapt CV accordingly
		CVFolds = size(dataslices,1);
		fprintf('\n%s: Changed CVFolds to %u (%s).', mfilename, CVFolds, CVMethod);

        datasliceidlist = zeros(size(seglist,1),1);
        for i = 1:size(dataslices,1),  datasliceidlist = datasliceidlist + segment_markincluded(dataslices(i,:), seglist)*i;   end;
        [trainIndices testIndices] = classgroupcv(seglist, datasliceidlist, 'ClassCol', 4, 'ReturnIdx', true);        
        
    case 'onetraintest'  % this is a hack!
        allIndices = cell(1, length(thisTargetClasses));
        for class = 1:length(thisTargetClasses)
            allIndices{class} = col(find(seglist(:,4) == class));
            trainIndices{1}{class} = col(find(  (seglist(:,4) == class) & (seglist(:,6) >= LabelConfThres) ));
            testIndices{1}{class} = col(find(  (seglist(:,4) == class) & (seglist(:,6) >= PRLabelConfThres) & (seglist(:,6) < LabelConfThres)));            
        end;
        % --- (mk) REVISIT: Normalise train obs----------------------------
        nObs = min(cellfun(@length, trainIndices{1}));
        trainIndices{1} = cellfun(@(x) x(1:nObs), trainIndices{1}, 'UniformOutput', false);
        trainIndices{1} = trainIndices{1}(:);
        testIndices{1} = testIndices{1}(:);
        % --- (mk) --------------------------------------------------------
        
	otherwise
		error('CVMethod %s not understood.', CVMethod);
end;



% % add back any test labels that had been removed due to LabelConfThres
% % OAM REVISIT: this also work-arounds the bug in the CV code, lost labels are readded here.
% if ~strcmpi(CVMethod, 'onetraintest')
%     for class = 1:length(thisTargetClasses)
%         for cviters = 1:CVFolds
%             % get labels that are no training instances but belong to class == all test instances
%             nottrain = col(~vec2onehot(trainIndices{cviters}{class}, size(seglist,1)))  & (seglist(:,4) == class);
%             % get labels that are not (yet) test instances but no trains in this class  == test instances to add
%             tmp = col(~vec2onehot( testIndices{cviters}{class}, size(seglist,1))) & nottrain;
%             % confirm that we really should add them and add eventually
%             tmp = tmp & (seglist(:,6) >= PRLabelConfThres);
%             testIndices{cviters}{class} = [ testIndices{cviters}{class};  find(tmp) ];
%             fprintf('\n added: %u', sum(tmp));
%         end;
%     end;
% end;

% verify CV splits
if ~strcmpi(CVMethod, 'onetraintest')
%     if (checkcv(seglist, trainIndices, testIndices) == false), error('Error in CV.'); end;
end;



prmetrics = []; prmetricslist = []; scmetrics = []; 
cmetrics = zeros(length(thisTargetClasses)); cmetricslist = cell(CVFolds,1);
predictedclass = []; trueclass = []; predictionscore = [];
allfweighting = zeros(size(fmatrix,2), 1); allfselect = zeros(size(fmatrix,2), 1);
fweighting = cell(1,CVFolds); fselect = cell(1,CVFolds);
alltestIndices = [];

for cviters = 1:CVFolds
    fprintf('\n%s: CV iteration: %u of %u', mfilename, cviters, CVFolds);
	
	fprintf('\n%s:   Total: %s', mfilename, ...
		mat2str(cellfun('size', segments2classlabels(length(unique(seglist(:,4))), seglist),1)));
	fprintf('\n%s:   Train: %s', mfilename, mat2str(cellfun('size', trainIndices{cviters},1)));
	fprintf('\n%s:   Test: %s', mfilename, mat2str(cellfun('size', testIndices{cviters},1)));
	
	trainlabels = seglist(cell2mat(trainIndices{cviters}),:);
	testlabels = seglist(cell2mat(testIndices{cviters}),:);

	
	
	% clip and standardise features: nfm_train (nfm_means nfm_stds)
	[nfm_train nfm_test] = clipnormstandardise( ...
		fmatrix(cell2mat(trainIndices{cviters}),:), 	fmatrix(cell2mat(testIndices{cviters}),:), ...
		'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, 'verbose', 0);
	


	% perform feature selection
	% output: ffm_train, ffm_test, allfweighting
	fstruct = fselEvalFeatures(FSelMethod, nfm_train, trainlabels(:,4), 'NSelFeatures', FSelFeatureCount);

	% apply weighting/selection
	[ffm_train ffm_test Filtered_FeatureString] = fselPostApplyWeights(fstruct, nfm_train, nfm_test, fm_FeatureString);
	
	allfweighting = allfweighting + sum(abs(fstruct.fweighting),2);
    allfselect = allfselect + fstruct.fselect;
	
	
    % eventually run classifier
    thisscore = zeros(size(ffm_test,1),1);
	fprintf('\n%s:   Features to classify: %u', mfilename, size(ffm_train,2));
    fprintf('\n%s:   Run classifier %s (%s)...', mfilename, ClassifierName, cell2str(ClassifierParams));
    switch ClassifierName
        case {'KNN', 'Nearest_Neighbor', 'IBk'}
            %thispredicted = Nearest_Neighbor(trainfmatrix(:,1:end-1)', trainfmatrix(:,end), testfmatrix(:,1:end-1)', ClassifierParams{end});
            %thispredicted = Nearest_Neighbor(fmatrix(:,1:end-1)', fmatrix(:,end), fmatrix(:,1:end-1)', ClassifierParams{end});
			%thispredicted = Nearest_Neighbor(ffm_train, trainlabels(:,4), ffm_test, ClassifierParams{end});
			thispredicted = knn([ffm_train, trainlabels(:,4)],  ffm_test', ClassifierParams{end});            
			% from Storck toolbox
        case {'C45', 'C4_5'}
            addpath('/home/oamft/lit/matlab/storck');
			thispredicted = C4_5(ffm_train, trainlabels(:,4), ffm_test, ClassifierParams{:});
            modifypath('Mode', 'rm', 'PathString', { 'storck' });
        case {'NB', 'NBayes', 'NaiveBayes'}
            [thispredicted thisscore] = naivebayes(ffm_train, trainlabels(:,4), ffm_test);
        case {'NCC', 'NearestCenter', 'NearestCentroid'}
             [thispredicted thisscore] = nearestcentroid(ffm_train, trainlabels(:,4), ffm_test);
        case 'GMM'
            thispredicted = EM(ffm_train', trainlabels(:,4), ffm_test', ClassifierParams{:});
        case { 'WEKA_IBk', 'WEKA_C45', 'WEKA_NaiveBayes'  }  % see WekaTrainClassifier
            if ~isWeka(1), error('JAVA or WEKA not loaded.'); end;
            arff_filename = WriteARFFHeader(Filtered_FeatureString, Classlist(thisTargetClasses));
            for class = thisTargetClasses
                WriteARFFData(ffm_train(trainlabels(:,4)==class,:), 'all', Classlist{class}, arff_filename);
            end;
            [wekaClassifier, wekaTrainInstances] = WekaTrainClassifier(arff_filename, fb_getelements(ClassifierName,2), ClassifierParams);
            [result, relevant, retrieved, recognised] = WekaTestFeatures(ffm_test, 'all', wekaClassifier, wekaTrainInstances, testlabels(:,4)');
            thispredicted = result.class+1;
        otherwise
            error('ClassifierName not supported');
    end;  %  switch ClassifierName
    

    % recognition performance
    thistrueclass = row(testlabels(:,4));
    clear relevant retrieved recognised;
    for class = 1:length(thisTargetClasses)
        relevant(class) = sum(thistrueclass == class);
        retrieved(class) = sum(thispredicted == class);
        recognised(class) = sum(row(thistrueclass == class).* row(thispredicted == class)); %length( find((thistrueclass == class).*(thispredicted == class)) );
    end;
    thisprmetrics = prmetrics_mkstruct(relevant, retrieved, recognised);
    prmetrics = prmetrics_add(prmetrics, thisprmetrics);
    prmetricslist = [prmetricslist thisprmetrics];

	% classification confusion
	cmetricslist{cviters} = cmetrics_mkmatrix(thistrueclass, thispredicted);
    cmetrics = cmetrics + cmetricslist{cviters};
    
	% two-class performance
    if (length(thisTargetClasses) == 2) && (~all(all(thisscore==0)))
        thisscmetrics = scmetrics_mkstruct(thisscore(:,1), thistrueclass);
        scmetrics = scmetrics_append(scmetrics, thisscmetrics);
    end;

	alltestIndices = [ alltestIndices row(cell2mat(testIndices{cviters})) ];
    trueclass = [trueclass thistrueclass];
    predictedclass = [predictedclass; col(thispredicted)];
    predictionscore = [predictionscore; thisscore(:,:)];
end; % for cviters



% print metrics
fprintf('\n\n');
% print only when displayable (low nr of total classes)
if (length(thisTargetClasses) < 15), disp(cmetrics); end;
fprintf('\n');
disp(cmetrics_mkstats(cmetrics));
% cmetrics_plotmap(cmetrics_hist2ratio(cmetrics))

% additional metrics for 2-class problems
if (length(thisTargetClasses) == 2) 
    prmetrics_classmetrics(prmetrics)
    disp(scmetrics);
end;
%scmetrics_plotroc('view', [], scmetrics);


% derive summarised feature weighting
if (~isempty(FSelMethod)) && (~strcmpi(FSelMethod, 'none'))
	[dummy featurerank] = sort(allfweighting, 'descend');
	%bestfeatures = featurerank(1:round(length(featurerank)*0.1)); 
    if length(featurerank)<FSelFeatureCount, bestfeatures = featurerank(1:length(featurerank));
    else bestfeatures = featurerank(1:FSelFeatureCount); end;
    if isempty(bestfeatures), bestfeatures = featurerank(1:length(featurerank)); end;
	fprintf('\n%s:   Using %s ranked %u features (best %u features):\n', mfilename, FSelMethod, ...
        length(fm_FeatureString), length(bestfeatures));
	disp(cellstr2vcat(fm_FeatureString(bestfeatures)));
	fprintf('\n');
else
	featurerank = []; bestfeatures = [];
end;


% evaluation of errors
if (DoErrEval)
	% compare original class IDs to group classification result => find classes
	% that do not fit their grouping
	gtseglist = labellist_load(segment_findequals(labellist_load, seglist),:);
	emetrics = emetrics_errormatrix(gtseglist(alltestIndices,4), predictedclass);

    % create simple association list from true classes to MergeClassSpec result
    realclass = unique(gtseglist(:,4));
    for class = 1:length(realclass)
        thisclass(class) = seglist(find(gtseglist(:,4) == realclass(class),1), 4); 
    end;
    
    for i = 1:size(emetrics.ematrix,1)
        fprintf('\n %-15s %2u %2u %-20s', mat2str(emetrics.ematrix(i,:)), thisclass(i), realclass(i), Repository.Classlist{realclass(i)});
    end;
else
	gtseglist = labellist_load(segment_findequals(labellist_load, seglist),:);
	emetrics = emetrics_finderrors(trueclass, predictedclass);
	% emetrics.gtclass5
end;



% SAVE
if (DoSave)
    SaveTime = clock;

    if exist('allsim_batchmode', 'var') && allsim_batchmode
       % batch mode incremental file numbering
        isoclass_filename = repos_makefilename(Repository, 'indices', allsim_batchcmd, 'prefix', 'CLASS', 'suffix', SimSetID, 'subdir', 'ISO');
    else
        isoclass_filename = repos_makefilename(Repository, 'prefix', 'CLASS', 'suffix', SimSetID, 'subdir', 'ISO');
    end;

    fprintf('\n%s:   Save %s...', mfilename, isoclass_filename);
    save(isoclass_filename, ...
        'ClassifierName', 'ClassifierParams', ...
		'featurerank', 'allfweighting', 'allfselect', 'predictedclass', 'trueclass', 'predictionscore', 'alltestIndices', 'gtseglist', ...
        'prmetrics', 'prmetricslist', 'scmetrics', 'cmetrics', 'cmetricslist', 'emetrics', ...
        'thisTargetClasses', 'Classlist', 'FeatureString', 'Filtered_FeatureString', 'fm_FeatureString', 'FSelFeatureCount', ...
        'seglist', 'MergeClassSpec', 'Partlist', 'DSSet', 'CVFolds', ...
        'trainIndices', 'testIndices', ...
        'StartTime', 'SaveTime');
    fprintf('done.\n');
end;
