% main_spotidentify
%
% Search for similar sections using preprocessed features

% requires
Partlist;
SimSetID;
FeatureString;


VERSION = 'V114';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if ~exist('CVFolds','var'), CVFolds = 10; end;
if ~exist('CVMethod', 'var'), CVMethod = UserMode; end;  % CVMethod = 'intrasubject';
if ~exist('CVSectionBounds','var'), CVSectionBounds = []; end;  % CV cutting bounds, empty=labels are used
if ~exist('CVTrainLabelNum','var'), CVTrainLabelNum = []; end;  % Limit training labels per CV
if ~exist('SpecialPartoffsets', 'var'), SpecialPartoffsets = []; end;  % modify partoffsets for CV splitting

if ~exist('FSelMethod', 'var'), FSelMethod = 'none'; end;  % perform feature selection
if ~exist('FSelFeatureCount','var'), FSelFeatureCount = 20; end;   % nr of features to select
if ~exist('FSelMethodParams','var'), FSelMethodParams = {}; end; % additional parameters for fsel
if ~exist('FMatchStyle','var'), FMatchStyle = 'lazy'; end;   % style to enable features (lazy / exact)
if ~exist('DoExclTrainFSel','var'), DoExclTrainFSel = true; end;   % exclude train sections during fsel
if ~exist('DoExclNoise','var'), DoExclNoise = false; end;   % exclude all data except labels in rel classes
if ~exist('DoExclNoLabels','var'), DoExclNoLabels = 0; end;   % exclude larger areas without label (in sec.)
if ~exist('DoExclNoLabels_RelClasses','var'), DoExclNoLabels_RelClasses = []; end; % relevant labels for DoExclNoLabels, should include TargetClasses
if (DoExclNoise) && (DoExclNoLabels), 
	error('Params DoExclNoise and DoExclNoLabels enabled. This is certainly a misconfiguration.');
end;

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit labels below confidence thres during training
if ~exist('PRLabelConfThres','var'), PRLabelConfThres = LabelConfThres; end;   % omit labels below confidence thres for metrics/testing

if ~exist('Greylist','var'), Greylist = []; end;   % omit labels during training

if ~exist('DoNorm','var'), DoNorm = true; end;  % DoNorm = false;
if ~exist('DoClip','var') || (~DoNorm), DoClip = DoNorm; end;
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
initmain_segconfig;

if ~exist('SpottingMethod','var'), SpottingMethod = 'EuclidNorm'; end;
if ~exist('SpottingMethod_Params','var'), SpottingMethod_Params = {}; end;
if ~exist('SpottingMode','var'), SpottingMode = 'adaptive'; end;
if ~exist('SpottingSearchWindow','var'), SpottingSearchWindow = 0.3; end;  % in sec
if ~exist('SpottingEval_Params','var'), SpottingEval_Params = {'MergeMethod', 'FrontOfBest'}; end;
fprintf('\n%s: Spotting method: %s (%s), search mode: %s', mfilename, ...
	SpottingMethod, cell2str(SpottingMethod_Params, ', '), SpottingMode);
fprintf('\n%s: CVMethod: %s', mfilename, CVMethod);

%if ~exist('ThresholdMethod_Params','var'), ThresholdMethod_Params = { 'Model', 'polyxobs', 'Order', 2.0, 'Res', 3e3 }; end;
%if ~exist('ThresholdMethod_Params','var'), ThresholdMethod_Params = { 'Model', 'unique1' }; end;
% if ~exist('ThresholdMethod_Params','var'), ThresholdMethod_Params = { 'Model', 'uniexp' }; end;
if ~exist('ThresholdMethod_Params','var'), ThresholdMethod_Params = { 'Model', 'optprec' }; end;
if ~exist('ThresholdMethod_XObsLambda','var'), ThresholdMethod_XObsLambda = 0; end;

if ~exist('PRPruneMethod_Params','var'), PRPruneMethod_Params = { 'rmnan', 'idpoints', 'paretofront', 'bestp' }; end;
if ~exist('OptPrecisionThres','var'), OptPrecisionThres = 0.1; end;

SampleRate =  repos_getmarkersps(Repository, Partlist(1), 'singlesps', true);


% ------------------------------------------------------------------------
% Spotting for each class
% ------------------------------------------------------------------------

allclassmetrics = [];
if (DoLoad)
	SF_fmatrixsearch = []; SF_fmsectionlist = []; SF_fmatrixtrain = []; SF_searchwindow = []; SF_trainlabellist = [];
end;
for classnr = 1:length(thisTargetClasses)
	fprintf('\n%s: Processing class %u...', mfilename, thisTargetClasses(classnr));
	classseglist = segment_findlabelsforclass(labellist, thisTargetClasses(classnr));

	% load search features (precomputed) and index list (main_spotfeatures.m)
	if (DoLoad)
		main_spotloadfeatures;
	end;


	if (DoLoad)
		% adapt seglist, fmatrix to MergeClassSpec class settings (remove labels only!)
		% 	fprintf('\n%s:   Adapt segmentation search list to MergeClassSpec...', mfilename);
		% 	[SF_fmsectionlist thisTargetClasses removed] = segment_classfilter(MergeClassSpec, SF_fmsectionlist);
		% 	SF_fmatrixsearch(removed, :) = []; % remove observations that are not in spec
		% 	fprintf(' %u removed', length(find(removed>0)));
		fprintf('\n%s:   Adapt train label list to MergeClassSpec...', mfilename);
		[SF_classseglist dummy removed] = segment_classfilter(MergeClassSpec, SF_trainlabellist, 'ClassIDMode', 'keepid');
		SF_fmatrixtrain(removed, :) = []; % remove observations that are not in spec
		fprintf(' %u removed', length(find(removed>0)));


		% adapt features to FeatureString
		fprintf('\n%s:   Features available: %u ', mfilename, length(SF_FeatureString_load));
		[usedfeatures SF_FeatureString] = fb_findusedfeatures(SF_FeatureString_load, FeatureString, 'MatchStyle', FMatchStyle);
		

		SF_fmatrixtrain(:,~usedfeatures) = []; % remove columns that are not requested
		SF_fmatrixsearch(:,~usedfeatures) = []; % remove columns that are not requested
		fprintf(' enabled: %u, match style: %s', length(SF_FeatureString), FMatchStyle);
	end; % if (DoLoad)


	% checks
    if any(any(SF_classseglist(:,1:4) ~= classseglist(:,1:4))),
        fprintf('\n%s: Seglists do not match.', mfilename);
        tmp = find(any(SF_classseglist(:,1:4) ~= classseglist(:,1:4),2));
        fprintf('\n%s: Seglist indices: %s', mfilename, mat2str(tmp));
        fprintf('\n%s: Class: %s', mfilename, mat2str( classseglist(tmp,4) ));
        fprintf('\n%s: PIs: %s', mfilename, mat2str( Partlist(repos_findpartfromlabels(classseglist(tmp, :), partoffsets)) ));

        if length(tmp)<10
            fprintf('\n%s: classseglist:\n', mfilename);
            classseglist(tmp,:)
            fprintf('\n%s: SF_classseglist:\n', mfilename);
            SF_classseglist(tmp,:)
        end;
        error('Seglists do not match.');
    end;
    
	if ( size(classseglist,1) ~= size(SF_fmatrixtrain,1) ), error('Train matrix and classseglist do not match.'); end;
	if ( (length(SF_FeatureString) ~= size(SF_fmatrixsearch,2)) ...
			|| (length(SF_FeatureString) ~= size(SF_fmatrixtrain,2) ) )
		error('Feature list and feature matrix do not match.');
	end;
	if (thisTargetClasses(classnr) ~= row(unique(classseglist(:,4)))),  error('No observations found.'); end;
	if (length(partoffsets) ~= length(Partlist)+1), error('Partlist and partoffsets do not match. Rerun initmain.'); end;
%     repos_findlabelsforpart(classlabellist, 1:length(Partlist), partoffsets);

	% segmentation points, needed for CV slice adapted search bounds
	aseglist = cla_getsegmentation(Repository, Partlist, 'SampleRate',  SampleRate, ...
		'SegType', SegConfig(classnr).Name, 'SegMode', SegConfig(classnr).Mode);
	aseglist(end,:) = [aseglist(end,1) partoffsets(end)]; % omit last (may exceed data size)


	% replace training objects with best matching segmentation version
	if (DoReplaceTrainSeg)
		[Sidx Serr] = segment_findsimilar(classseglist, SF_fmsectionlist);
		fprintf('\n%s: Adapt training data to optimal search object...', mfilename);
		fprintf(' distance errors >50%%: %u', sum(Serr>0.5));

		for i = 1:size(SF_fmatrixtrain,1)
			% Cannot check alignment errors here, since target resolution is unknown.
			SF_fmatrixtrain(i,:) = SF_fmatrixsearch(Sidx(i),:);
		end; % for i
	end;

	

    % create cv splits
	%   CVSectionBounds may come from any initmain_* preprocessor script
	[trainslices, testslices, dotraining] = spot_createcvsplit(CVMethod, CVFolds, classseglist, ...
		Repository, Partlist, 'mintrainshare', mintrainshare, 'LabelConfThres', LabelConfThres, ...
		'CVSectionBounds', CVSectionBounds, 'partoffsets', SpecialPartoffsets);
	if length(trainslices) ~= length(testslices), error('Slice sizes differ, stop.'); end;
    CVFolds = length(trainslices);


    
	
	% information containers for each CV interation (CVFolds)
    allmetrics = [];   bestthres = nan(1, CVFolds); mythresholds = cell(1,CVFolds);  testSegDist = cell(1,CVFolds);
	testSegBest = cell(1,CVFolds); trainSegBest = cell(1,CVFolds); 
	testSegMax = cell(1,CVFolds); trainSegMax = cell(1,CVFolds);
	trainSegGT = cell(1,CVFolds); testSegGT = cell(1,CVFolds);
	fweighting = cell(1,CVFolds); fselect = cell(1,CVFolds);

	% begin CV
	for  cvi = 1:CVFolds
		% find labels within slices, omit tentatives only for training (below!)
		trainseglist = classseglist(segment_countoverlap(classseglist, trainslices{cvi}) > 0, :);
		testseglist = classseglist(segment_countoverlap(classseglist, testslices{cvi}) > 0, :);

        % limit training labels to specific amount (choose randomly, if needed)
        markedsegs = find(trainseglist(:,6)>=LabelConfThres);
        num_trainlabels = length(markedsegs);
        if ~isempty(CVTrainLabelNum) && ( num_trainlabels > CVTrainLabelNum )
            trainseglist(:, 6) = PRLabelConfThres;
            trainseglist(markedsegs(randsample(num_trainlabels, CVTrainLabelNum)), 6) = LabelConfThres;
            %trainseglist(randsample(num_trainlabels, num_trainlabels-CVTrainLabelNum), 6) = PRLabelConfThres;
        end;
        
		fprintf('\n%s: ClassNr: %u (%u)  CV: %u of %u  Total: %u, Train: %u (T:%u, omit:%u), Test: %u', mfilename, ...
			classnr, thisTargetClasses(classnr), cvi, CVFolds, size(classseglist,1), size(trainseglist,1), ...
			size(trainseglist(trainseglist(:,6)<1,:),1), size(trainseglist(trainseglist(:,6)<LabelConfThres,:),1), size(testseglist,1));
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
				case 'adaptive'  % test for min max bounds of current CV
					obswindow = round([min(tmp)+(min(tmp)==0) max(tmp)]);
					%                     obswindow = round([SF_searchwindow(1) max(tmp)]);
					%obswindow(1) = obswindow(1) + (obswindow(1)==1)*1;
				case 'gaussian'  % adaptive, but assume gaussian statistic
					s = 3;
					obswindow = [ round(mean(tmp)-s*std(tmp)) round(mean(tmp)+s*std(tmp)) ];
					obswindow = [ obswindow(1)+(obswindow(1)==0)  obswindow(2) ];
					if isempty(segment_findincluded(SF_searchwindow, obswindow))
						fprintf('\n%s: Gaussial search window too small ', mfilename);
						fprintf('SF_searchwindow=%s, obswindow=%s.', mat2str(SF_searchwindow), mat2str(obswindow));
						obswindow = SF_searchwindow;
					end;

				case 'fixed'  % spotting size not variable
					%obswindow = repmat(round(mean(tmp)),1,2);
					obswindow = repmat(round(mean(tmp)) + (round(mean(tmp))==0), 1,2);
                case 'specified'  % defined spotting size (one or two values), SpottingSearchWindow is in sec
                    tmp = round(SpottingSearchWindow*SampleRate/mean(segment_size(aseglist)));
                    if length(tmp)==1, obswindow = repmat(tmp+(tmp==0), 1,2);
                    else obswindow = [ tmp(1)+(tmp(1)==0) tmp(2) ]; end;

				case 'maxtest'  % test maximum (not considering CV)
					% WARNING: Using this mode is a validation error!

					%if ~isempty(testseglist)
					%tmp = [ tmp segment_countoverlap(testseglist(testseglist(:,6)>=LabelConfThres,:), aseglist, -inf) ];
					%end;
					%obswindow = round([min(tmp)+(min(tmp)==0) max(tmp)]);
					obswindow = SF_searchwindow;

				otherwise
					error('Spotting mode %s not supported.', lower(SpottingMode));
			end;
			fprintf('\n%s: Search mode: %s, obswindow: %s', mfilename, lower(SpottingMode), mat2str(obswindow));

			if isempty(segment_findincluded(SF_searchwindow, obswindow))
				%warning('searchwindow too small!');
				fprintf('\n%s: Search window is too small.', mfilename);
				fprintf('\n%s: SF_searchwindow=%s, obswindow=%s.', mfilename, mat2str(SF_searchwindow), mat2str(obswindow));
				%obswindow = SF_searchwindow;
				error('here');
			end;


			% determine section list that fit in obswindow
			% these indices are used later to reference segments from fmsectionlist
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


			% OAM REVISIT
			% Minimum search size should be checked here when FFT is used.
			% This is difficult since segmentation point/data dependent.
			%         if (obswindow(1)) < DataStruct(1).SampleRate
			%             fprintf('\n%s: Segmentation: %usa', mfilename, windowsize);
			%             fprintf('\n%s: WARNING: obswin lower bound below windowsize! Check for spectral features.', mfilename);
			%         end;


			% determine index, required for acessing SF_fmatrixtrain
			trainidx = find(segment_countoverlap(classseglist, trainseglist(trainseglist(:,6)>=LabelConfThres,:)) == 1);

% 			% join training segment slices when adjacent
% 			cont_trainslices = segment_distancejoin(trainslices{cvi},2);

			
			% find sections relevant for threshold estimation step
			% process continuous training slices into one selection array
			fmtrainidx = [];
			for tslice = 1:size(trainslices{cvi},1)
				fmtrainidx = [fmtrainidx; segment_findincluded(trainslices{cvi}(tslice,:), SF_fmsectionlist(fmobsidx,:))];
			end;
			fmsectionlist_ts = SF_fmsectionlist(fmobsidx(fmtrainidx),:);

			
			% build a exculde list to omit sections in feature selection
			excludesecs = false(1, size(fmsectionlist_ts,1));
			if (DoExclTrainFSel)	% exclude target objects
				%excludesecs = excludesecs & (segment_countoverlap(fmsectionlist_ts, classseglist, section_jitter)>0);
				excludesecs(segment_findsimilar(classseglist, fmsectionlist_ts)) = true;
				% special case: initmain_chewlabelseq, keep labels with conf<0 for competition
				excludesecs(segment_findsimilar(classseglist(classseglist(:,6)<0,:), fmsectionlist_ts)) = false;
			end;
			if (DoExclNoLabels)		% exclude long areas of no labels, DoExclNoLabels_RelClasses are relevant labels  
				if isempty(DoExclNoLabels_RelClasses)
					seggaps_rlabels = labellist_load;
				else
					seggaps_rlabels = segment_sort(segment_findlabelsforclass(labellist_load, DoExclNoLabels_RelClasses));
				end;
				seggaps = segment_findgaps(seggaps_rlabels, 'maxsize', partoffsets(end));
				seggaps = seggaps(segment_size(seggaps)>=SampleRate*DoExclNoLabels, :);
				%excludesecs = excludesecs | segment_countoverlap(fmsectionlist_ts, seggaps, inf)>0);
				for tmp = 1:size(seggaps,1)
					excludesecs(segment_findincluded(seggaps(tmp,:), fmsectionlist_ts)) = true;
				end;
			end;
			if (DoExclNoise)    % direct comparison of objects
				if isempty(DoExclNoLabels_RelClasses)
					segcmp_rlabels = labellist_load;
				else
					segcmp_rlabels = segment_sort(segment_findlabelsforclass(labellist_load, DoExclNoLabels_RelClasses));
					%%	DoExclNoLabels_RelClasses(DoExclNoLabels_RelClasses~=thisTargetClasses)));
					% Sections corresponding to the thisTargetClass have been excluded by DoExclTrainFSel above. 
					% Hence, those need not to be handled here:
					%                    T T T1 R R O O O
					% ExclTrain     1 1  1  0 0 0  0 0 
					% segcmp       1  1  1  1 1 0 0 0    <= hits for DoExclNoLabels_RelClasses  
					% ~segcmp     0  0 0  0 0 1 1  1   <= inverted hits for DoExclNoLabels_RelClasses  
					% ExclNoise    1 1  1  0 0 1  1  1   <= applied TRUE on inverted hits   
				end;
				Sidx = segment_findsimilar(segcmp_rlabels, fmsectionlist_ts);  % labels to keep
				excludesecs(~onesvector(Sidx, length(excludesecs))) = true;
			end;
			
			if sum(excludesecs)>=size(fmsectionlist_ts,1), error('Excluded all NULL data from feature selection.'); end;
			if sum(excludesecs)>size(fmsectionlist_ts,1)*0.9
				fprintf('\n%s: WARNING: Excluded more than 90%% of NULL data from feature selection.', mfilename);
			end;

			
			% clip and standardise data			
            if 0
                [fmtrain fmtest fclips fmeans fstds] = clipnormstandardise( ...
                    SF_fmatrixtrain(trainidx,:), 	SF_fmatrixsearch(fmobsidx(fmtrainidx),:), ...
                    'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, 'verbose', 0);
            else
                tmp = [ SF_fmatrixtrain(trainidx,:); 	SF_fmatrixsearch(fmobsidx(fmtrainidx),:) ];
                [tmp dummy fclips fmeans fstds] = clipnormstandardise( ...
                    tmp, tmp, ...
                    'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, 'verbose', 0);
                fmtrain = tmp(1:length(trainidx),:);  fmtest = tmp(length(trainidx)+1:end,:);
            end;
            
            % options for STLEARN feature conditioning
            % 1. derive a special version of standardised features; risk: does not suit the real data => no benefit
            % 2. use jointly std features (train + test); risk: spotting performance!
            % 3. use MWWZ as postprocessing to statistically reduce bases
            

			% feature selection
			% determine features, adapt fmtrain and provide indices to change fmtest later
			% class skew issue: we make another assumption about the event distribution,
			% however in reality this skew will be even worse, so keep it
			fprintf('\n%s:   FSelMethod: %s, select: %u from %u, excluded train sections: %u, run...', mfilename, ...
				upper(FSelMethod), FSelFeatureCount, length(SF_FeatureString), sum(excludesecs));
			fmtest_fsel = fmtest(~excludesecs,:);  % exclude secs from fsel NULL-class (as specified above)
			if size(fmtrain,1) > size(fmtest_fsel,1), error('More train objects than NULL data for feature selection.'); end;
			trainlabelids = [ones(size(fmtrain,1), 1); zeros(size(fmtest_fsel,1), 1)]; % class ids: 1, 0

			% run fsel
			fstruct = fselEvalFeatures(FSelMethod, [fmtrain; fmtest_fsel], trainlabelids,  'NSelFeatures', FSelFeatureCount, FSelMethodParams{:});
            fweighting{cvi} = fstruct.fweighting; fselect{cvi} = fstruct.fselect;
			clear fmtest_fsel;

			% apply weighting/selection
			[fmtrain fmtest Filtered_FeatureString] = fselPostApplyWeights(fstruct, fmtrain, fmtest, SF_FeatureString);


			% determine spotmodel
			fprintf('\n%s:   Similarity training %s for %u (from %u) segments...', mfilename, ...
				upper(SpottingMethod), size(trainseglist(trainseglist(:,6)>=LabelConfThres,:),1),  size(trainseglist,1));

			if strcmp(SpottingMethod, 'loadmodel')
				SpottingMethod_Params(end+1:end+2) = { 'filename', dbfilename(Repository, 'prefix', 'spotmodel' , ...
					'indices', thisTargetClasses(classnr), 	'suffix', SimSetID, 'subdir', 'SYM') };
			end;

			spotmodel = similarity_train(   fmtrain, SpottingMethod, SpottingMethod_Params{:});  % , 'trainlabels', trainlabelids
			if isempty(spotmodel), error('spotmodel not available.'); end;


			% process continuous training slices
			fprintf('\n%s:   Process similarity thres, sections: %u, features: %u, obswindow: %s...', ...
				mfilename, size(fmsectionlist_ts,1), size(fmtrain,2), mat2str(obswindow));

			secdist = similarity_dist(fmtest, spotmodel);
            % plot(secdist); ylim([0 20]);
			%mythresholds{cvi} = estimatethresholddensity(secdist, 'Model', 'polyzero', 'Order', 2);  % histecb(secdist,20);
			%mythresholds{cvi} = similarity_findthresholds(spotmodel, secdist, ...
			%XObs = round( (10+ThresholdMethod_XObsLambda)*size(trainseglist,1)*mean(segment_countoverlap(trainseglist(trainseglist(:,6)>=LabelConfThres,:), fmsectionlist_ts, 0.5)) );
            XObs = round( (1+ThresholdMethod_XObsLambda)*sum(trainseglist(:,6)>=LabelConfThres) );
			[Sidx Serr] = segment_findsimilar(trainseglist(trainseglist(:,6)>=LabelConfThres,:), fmsectionlist_ts);
			if any(Serr > 0.5),
				fprintf('\n%s: WARNING: Detected large alignment mismatch of labels and segmentation for train idx: %s', ...
					mfilename, mat2str(Sidx(Serr>0.5)));
			end;

			this_mythresholds = estimatethresholddensity(secdist, 'XObs', XObs, 'SetThresholds', secdist(Sidx), ...
                'OptPrecision', OptPrecisionThres, ThresholdMethod_Params{:});

			%error('Testing mode');

			fprintf('\n%s:     train dist:%.2f-%.2f (mean:%.2f sd:%.2f), wait...', mfilename, min(secdist), max(secdist), mean(secdist), std(secdist));
			[this_trainSeg this_trainDist] = similarity_eval( fmsectionlist_ts, secdist, trainseglist, ...
                'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', this_mythresholds, SpottingEval_Params{:});

			fprintf('\n%s:     sections in relevants (%u): %s', mfilename, ...
				size(trainseglist,1), mat2str(segment_countoverlap(trainseglist, fmsectionlist_ts, section_jitter)));

			% compute and prune metrics
			fprintf('\n%s:   Computing performance metrics...', mfilename);
			metrics_train = prmetrics_softalign(trainseglist, this_trainSeg, 'jitter', section_jitter, ...
				'LabelConfThres', PRLabelConfThres, 'Greylist', Greylist);
            % prmetrics_plotpr('view', [], metrics_train)
			shaddow_metrics = metrics_train;

			fprintf(' %u, pruning: ', length(metrics_train));
			%[metrics_train keeplist] = prmetrics_prunepr(metrics_train, 'verbose', 0, PRPruneMethod_Params{:}); 
            [metrics_train keeplist] = prmetrics_prprune(metrics_train, 'verbose', 0, PRPruneMethod_Params{:}); 
			fprintf(' %u', length(metrics_train));

			mythresholds{cvi} = this_mythresholds(keeplist);

			bestthres(cvi) = prmetrics_findoptimum(metrics_train, OptPrecisionThres);
            if bestthres(cvi) == length(metrics_train)
                warning('matlab:main_spotidentify', 'Used last threshold.');
            end;
            tmp = find(keeplist);
			trainSegBest{cvi} = segment_createlist( this_trainSeg{tmp(bestthres(cvi))}, ...
				'classlist', thisTargetClasses(classnr), 'conflist', this_trainDist{tmp(bestthres(cvi))} );
			% 			trainSegBest{cvi} = this_trainSeg{keeplist(bestthres(cvi))};   % trainDist{cvi} = this_trainDist(keeplist);
			% 			if ~isempty(trainSegBest{cvi}), trainSegBest{cvi}(:,6) = this_trainDist{keeplist(bestthres(cvi))}; end;
			trainSegMax{cvi} = segment_createlist( this_trainSeg{find(keeplist, 1, 'last')}, ...
				'classlist', thisTargetClasses(classnr), 'conflist',  this_trainDist{find(keeplist, 1, 'last')} );
			% 			trainSegMax{cvi} = this_trainSeg{keeplist(end)};
			% 			if ~isempty(trainSegMax{cvi}), trainSegMax{cvi}(:,6) = this_trainDist{keeplist(end)}; end;
			
			shaddow_bestthres = prmetrics_findoptimum(shaddow_metrics, OptPrecisionThres);

			fprintf('\n%s:   Selected threshold: %u:%.2f (pruned), %u:%.2f (unpruned):', mfilename, bestthres(cvi), mythresholds{cvi}(bestthres(cvi)), shaddow_bestthres, this_mythresholds(shaddow_bestthres));
			prmetrics_printstruct(metrics_train(bestthres(cvi)));
			prmetrics_printstruct(shaddow_metrics(shaddow_bestthres));

			%fprintf('\n%s:   Overlap check (jitter=inf, min prec: 0.2, 0.1):', mfilename);
			%shaddow_metrics = prmetrics_softalign(trainseglist, this_trainSeg, 'jitter', inf, 'LabelConfThres', PRLabelConfThres);
			%prmetrics_printstruct(shaddow_metrics(prmetrics_findoptimum(shaddow_metrics, 0.2)));
			%prmetrics_printstruct(shaddow_metrics(prmetrics_findoptimum(shaddow_metrics, OptPrecisionThres)));
			%fprintf('\n%s:   Max threshold:', mfilename);
			%prmetrics_printstruct(prmetrics_softalign(trainseglist, this_trainSeg{end}, 'jitter', section_jitter, 'LabelConfThres', PRLabelConfThres));

			% compute best recall point - in the area of training data only
			% normaly we must determine the distance threhold here
			% however we may try to estimate this directly from the similarity
			% training distances and omit the algorithm from
			% prmetrics_findoptimum()

			if (0)
				%save('test.mat', 'trainslices', 'tslice', 'seclist_ts', 'secdist', 'this_trainSeg', 'trainseglist', 'obswindow', 'searchwindow');
				%prmetrics_plot('view', [], metrics_train);
				%metrics_train = prmetrics_sort(metrics_train);
				prmetrics_plotpr('view', [], prmetrics_sort(metrics_train))
				figure; hold on;
				segment_plotmark(1:trainslices{cvi}(tslice,2), fmsectionlist_ts, 'similarity', secdist, 'width', 1, 'style', 'k-');
				segment_plotmark(1:trainslices{cvi}(tslice,2), this_trainSeg{end}, 'similarity', this_trainDist{end}, 'width', 1, 'style', 'g-');
				segment_plotmark(1:trainslices{cvi}(tslice,2), this_trainSeg{bestthres(cvi)}, 'similarity', this_trainDist{bestthres(cvi)}, 'width', 2, 'style', 'b-');
				segment_plotmark(1:trainslices{cvi}(tslice,2), trainseglist, 'fill', 'style', 'b');
				ylim([0 10]); xlim([1e4 4e4]);
				prmetrics_plotpr('view', [], prmetrics_softalign(trainseglist, this_trainSeg, 'jitter', section_jitter, 'LabelConfThres', PRLabelConfThres, 'Greylist', Greylist));

				fprintf('\n%s: Segments in sections: %s', mfilename, ...
					mat2str(segment_countoverlap(this_trainSeg{bestthres(cvi)}, aseglist)));
			end;


		else
			% use settings from previous run
			bestthres(cvi) = bestthres(cvi-1);          mythresholds{cvi} = mythresholds{cvi-1};
			fweighting{cvi} = fweighting{cvi-1};     fselect{cvi} = fselect{cvi-1};
		end; % if dotraining(cvi)

		%error('Breakpoint');


		% ------------------------------------------------------------------------
		% Testing
		% ------------------------------------------------------------------------

		% determine test data slice
		%testsegment = dataslices(find(segment_countoverlap(dataslices, testSegLabels) > 0),:);
		fprintf('\n%s:   Relevant test events: %u (T:%u), testslices: %s', mfilename, ...
			size(testseglist,1), size(testseglist(testseglist(:,6)<1,:),1), mat2str(testslices{cvi}));

		% adapt segmentation list (this will select the data accordingly)
		%fmtestidx = segment_findincluded(testslices{cvi}, SF_fmsectionlist(fmobsidx,:));
		%fmsectionlist_ts = SF_fmsectionlist(fmobsidx(fmtestidx),:);
        fmtestidx = [];
        for tslice = 1:size(testslices{cvi},1)
            fmtestidx = [fmtestidx; segment_findincluded(testslices{cvi}(tslice,:), SF_fmsectionlist(fmobsidx,:))];
        end;
        fmsectionlist_ts = SF_fmsectionlist(fmobsidx(fmtestidx),:);

		fprintf('\n%s:      process similarity, method: %s, sections: %u...', mfilename, SpottingMethod, size(fmsectionlist_ts,1));

		[dummy fmtest] = clipnormstandardise( [], 	SF_fmatrixsearch(fmobsidx(fmtestidx),:), ...
			'DoClip', DoClip, 'DoNorm', DoNorm, 'DoClipLimit', DoClipLimit, ...
			'fclips', fclips, 'fmeans', fmeans, 'fstds', fstds,  'verbose', 0);


        
		% apply fsel
		fmtest = fselPostApplyWeights(fstruct, fmtest);

		% compute similarity
		secdist = similarity_dist(fmtest, spotmodel);
		fprintf('\n%s:      test dist:%.2f-%.2f (mean:%.2f,sd:%.2f), wait...', mfilename, min(secdist), max(secdist), mean(secdist), std(secdist));

		% generate result list for best threshold and max threshold
		[this_testSeg this_testDist Thresholds] = similarity_eval( fmsectionlist_ts, secdist, testseglist, ...
			'BestConfidence', 'min', 'verbose', 1, 'LoopMode', 'pretend', ...
            'AnalyseRange', mythresholds{cvi}([ bestthres(cvi) end ]) );

		fprintf('\n%s:      sections in relevants: %s, features: %u', mfilename, ...
			mat2str(segment_countoverlap(testseglist, fmsectionlist_ts, section_jitter)), size(fmtest,2));

        
        % convert distances to posterior probabilities
        this_testConf = distance2posterior(this_testDist, ...
            [  col(mythresholds{cvi})  col(prmetrics_getfields(metrics_train, 'precision')) ] );
        
        
		fprintf('\n%s: *** Test data evaluation, threshold: %.2f (%u):', ...
			mfilename, mythresholds{cvi}(bestthres(cvi)), bestthres(cvi));
		thismetric = prmetrics_softalign(testseglist, this_testSeg{1}, 'jitter', section_jitter, ...
			'LabelConfThres', PRLabelConfThres, 'Greylist', Greylist);
		prmetrics_printstruct(thismetric);

		%if (classnr == 1) error; end;

		if (0)
			% prmetrics_plotpr('view', [], thismetric);
			prmetrics_plotpr('view', [], prmetrics_sort(metrics_train))
			figure; hold on;
			segment_plotmark(1:testslices{cvi}(end), fmsectionlist_ts, 'similarity', secdist, 'width', 1, 'style', 'k-');
			%segment_plotmark(1:testslices{cvi}(end), this_testSeg{end}, 'similarity', this_testDist{end}, 'width', 2, 'style', 'k-');
			segment_plotmark(1:testslices{cvi}(end), this_testSeg{1}, 'similarity', this_testDist{1}, 'width', 2, 'style', 'b-');
			segment_plotmark(1:testslices{cvi}(end), testseglist, 'fill', 'style', 'b');
			ylim([0 10]); xlim([1e4 4e4]);
			prmetrics_plotpr('view', [], prmetrics_softalign(testseglist, this_testSeg{1}, 'jitter', section_jitter, 'LabelConfThres', PRLabelConfThres, 'Greylist', Greylist));

			fprintf('\n%s: Segments in sections: %s', mfilename, ...
				mat2str(segment_countoverlap(this_trainSeg{bestthres(cvi)}, aseglist)));
		end;

		% store eval results in global cell array
		testSegBest{cvi} = segment_createlist( this_testSeg{1}, ...
			'classlist', thisTargetClasses(classnr), 'conflist',  this_testConf{1} ); 
		testSegMax{cvi} = segment_createlist( this_testSeg{end}, ...
			'classlist', thisTargetClasses(classnr), 'conflist',  this_testConf{end} );
		testSegDist{cvi} = this_testDist;
		
		trainSegGT{cvi} = trainseglist; testSegGT{cvi} = testseglist;

		allmetrics = prmetrics_add(allmetrics, thismetric);

		if DebugMaxCVI <= cvi, error('Debug breakpoint reached.'); end;
	end; % for cvi

	% break if no train/test partition was found
	if isempty(allmetrics), break; end;

	fprintf('\n%s: *** Complete data evaluation:', mfilename);
	prmetrics_printstruct(allmetrics);

	fprintf('\n%s: Selected features in last CV, run: strvcat(Filtered_FeatureString)', mfilename);

	if (DoSave)
		SaveTime = clock;
		metrics = allmetrics;


		filename = repos_makefilename(Repository, 'prefix', 'SIMS', 'indices', thisTargetClasses(classnr), 'suffix', SimSetID, 'subdir', 'SPOT');
		fprintf('\n%s: Save %s...', mfilename, filename);
		save(filename, ...
			'trainSegBest', 'trainSegMax', 'testSegBest', 'testSegMax', 'testSegDist', ...
			'trainSegGT', 'testSegGT', ...
			'mythresholds', 'bestthres', 'trainslices', 'testslices', ...
			'obswindow', 'spotmodel', 'dotraining', 'fweighting', 'fselect', ...
			'metrics', 'section_jitter', ...
			'thisTargetClasses', 'MergeClassSpec', 'classseglist', 'Partlist', ...
			'SF_FeatureString', 'FSelFeatureCount', 'FSelMethod', 'FMatchStyle', ...
			'DoExclTrainFSel', 'DoExclNoise', 'DoExclNoLabels', 'DoExclNoLabels_RelClasses', ...
			'CVFolds', 'CVMethod', 'CVSectionBounds', 'partoffsets', 'DoNorm', 'DoClip', 'SegConfig', 'mintrainshare', ...
			'SpottingMethod', 'SpottingMethod_Params', 'SpottingMode', ...
			'LabelConfThres', 'PRLabelConfThres', 'Greylist', 'PRPruneMethod_Params', 'DoReplaceTrainSeg', ...
			'ThresholdMethod_Params', 'ThresholdMethod_XObsLambda', ...
			'StartTime', 'SaveTime', 'VERSION');
		% 		'metrics_train',  'testSeg', 'testDist', 'trainSeg', 'trainDist', ...
		fprintf(' done.');
	end;

	allclassmetrics = [allclassmetrics allmetrics];
end; % for classnr


fprintf('\n\n');
