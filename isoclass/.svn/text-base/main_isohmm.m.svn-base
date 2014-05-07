% main_isohmm
%
% requires:
% FeatureString;
% SimSetID;
fprintf('\n%s: V009', mfilename);

if (~exist('CVFolds','var')), CVFolds = 5; end;
if (~exist('FeatureString','var')), error('FeatureString not found.'); end;

if (~exist('DSSet','var')), error('DSSet not found.'); end;

if (~exist('DoLoad', 'var')), DoLoad = true; end;   % load/compute features
if (~exist('DoNorm', 'var')), DoNorm = true; end;  % normalise features
if (~exist('FSelMethod', 'var')), FSelMethod = 'none'; end;  % perform feature selection
if (~exist('DoSave', 'var')), DoSave = true; end;   % save result

if (~exist('HMMConfigClassDefaults', 'var'))  % HMM class-specific configuration
	HMMConfigClassDefaults = {'States', 5, 'Mixtures', 1, 'Type', 'LR', 'CovType', 'diag', 'EMiterations', 30};
end;
if (~exist('HMMConfigDefaults', 'var')),  HMMConfigDefaults = {  }; end; % HMM global configuration
if (~exist('HMMTrainIters', 'var')), HMMTrainIters = 10; end;   % # of training trials


% expand HMMConfig.class struct
for i = 1:2:length(HMMConfigClassDefaults)
	if (~isfield(HMMConfig.class, HMMConfigClassDefaults{i})), 
		[HMMConfig.class(1:length(thisTargetClasses)).(HMMConfigClassDefaults{i})] = deal(HMMConfigClassDefaults{i+1});
	end;
	
	if length([HMMConfig.class(:).(HMMConfigClassDefaults{i})]) < length(thisTargetClasses)
		fprintf('\n%s: Expanding HMMConfig entry: %s, value: %s for all classes.', mfilename, ...
			HMMConfigClassDefaults{i}, mat2str(HMMConfig.class(1).(HMMConfigClassDefaults{i})));
		for class = 2:length(thisTargetClasses)
			HMMConfig.class(class).(HMMConfigClassDefaults{i}) = HMMConfig.class(1).(HMMConfigClassDefaults{i});
		end;
	end; % if
end; % for i
	
	
seglist = labellist;

% ------------------------------------------------------------------------
% 0. comination of features
% ------------------------------------------------------------------------
if (DoLoad)
	%classobs = repmat(0, 1, length(thisTargetClasses));
	FullFeatureString = {}; fmatrix = cell(size(seglist,1),1);  segcount = 0;
	for partnr = 1:length(Partlist)
		Partindex = Partlist(partnr);
		fprintf('\n%s: Process PI %u...', mfilename, Partindex);

		partseglist = repos_findlabelsforpart(seglist, partnr, partoffsets, 'remove');

		% Load only if relevant labels in part
		if isempty(partseglist)
			fprintf(' no relevant segments, skipping.');
			continue;
		end;

		
		% compute features anew
		fprintf('\n%s:   Create DataStruct...', mfilename);  % DSSet: swsize=%u, swstep=%u
		DataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet);


		% determine FullFeatureString
		if isempty(FullFeatureString)
			fprintf('\n%s:   Probe features names...', mfilename);
			FullFeatureString = {};
			for i = 1:length(DataStruct)
				testseg = segment_resample(partseglist(1,:), DataStruct(i).BaseRate, DataStruct(i).SampleRate);
				[dummy flist] = makefeatures(testseg, DataStruct(i));
				FullFeatureString = {FullFeatureString{:} flist{:}};
			end;
			fprintf(' %u features.', length(FullFeatureString));
		end;

		
		% adapt segmentation list to sampling rate of the data when potentially
		% used as a feature by makefeatures.
		%fprintf('\n%s:   Load segmentation for feature support...', mfilename);
		%SampleRate = cla_getmarkersps(Repository, Partindex, 'singlesps', true);
		%aseglist = segment_resample(aseglist, SampleRate, DataStruct.SampleRate);
		%DataStruct = fb_modifydatastruct(DataStruct, 'seglist', aseglist);

		% feature design: observation size X features
		% obs size may vary depending on segment!
		fprintf('\n%s:   Compute features, %u segments...', mfilename, size(partseglist,1));
		for f = 1:size(partseglist,1)
			fmatrix{segcount+f} = makefeatures_fusion(partseglist(f,:), DataStruct);
		end;
		segcount = segcount + size(partseglist,1);

		% 		% ugly!
		% 		for class = 1:length(thisTargetClasses)
		% 			partclassseglist = segment_findlabelsforclass(partseglist, class);
		% 			if isempty(partclassseglist), continue; end;
		% 			fprintf('\n%s:   Compute features for class %u, labels: %u...', mfilename, thisTargetClasses(class), size(partclassseglist,1));
		% 			for f = 1:size(partclassseglist,1)
		% 				fmatrix{class}{f+classobs(class)} = makefeatures_fusion(partclassseglist(f,:), DataStruct);
		% 			end;
		%
		% 			%allIndices{class} = [allIndices{class};  (classobs(class):classobs(class)+size(partclassseglist,1))'];
		% 			classobs(class) = classobs(class)+size(partclassseglist,1);
		% 		end; % for class

	end; % for Partindex
end;


% label indices for CV
allIndices = cell(1, length(thisTargetClasses));
for class = 1:length(thisTargetClasses)
	allIndices{class} = col(find(seglist(:,4) == class));
end;




% -------------------------------------------------------------------
% HMM configuration
% -------------------------------------------------------------------

clear HMMStruct;
HMMStruct.toolbox = 'FullBNT';
HMMStruct.trainiterations = HMMTrainIters;
HMMStruct.HMMtype = 'gaussian';

if (DoNorm),  fprintf('\n%s: snorm enabled.', mfilename); end;
HMMStruct.snorm_enable = DoNorm;

%HMMStruct.allfeaturestr = FeatureString;
HMMStruct.getFeatureProc = [];
%HMMStruct.data = DataStruct; % class information not included!

% replace class names
% '-' or similar not supported as Matlab field name, but may occur in Classlist
HMMClasslist = cell(1,length(thisTargetClasses));
for class = 1:length(thisTargetClasses)
	HMMClasslist{class} = ['Class' int2str(class)];
end;
HMMStruct.allclasstr = HMMClasslist;
for class = 1:length(thisTargetClasses)
	HMMStruct.eval.(HMMClasslist{class}).Name = HMMClasslist{class};
	HMMStruct.eval.(HMMClasslist{class}).Type = HMMConfig.class(class).Type;
	HMMStruct.eval.(HMMClasslist{class}).States = HMMConfig.class(class).States;
	HMMStruct.eval.(HMMClasslist{class}).Mixtures = HMMConfig.class(class).Mixtures;
	HMMStruct.eval.(HMMClasslist{class}).CovType = HMMConfig.class(class).CovType;
	HMMStruct.eval.(HMMClasslist{class}).EMiterations = HMMConfig.class(class).EMiterations;
end; % for class

HMMConfigFields = fieldnames(HMMConfig);
for i = 1:length(HMMConfigFields)
	if strcmp(HMMConfigFields{i}, 'class'), continue; end; % not class field

	HMMStruct.(HMMConfigFields{i}) = HMMConfig.(HMMConfigFields{i});
	%HMMStruct.adj_transmat = true;
end;

% ------------------------------------------------------------------------
% CV
% ------------------------------------------------------------------------

fprintf('\n%s: Performing CV, CVFolds = %u...', mfilename, CVFolds);
if (min(cellfun('size', allIndices,1)) == 0)
	fprintf('\n%s: No relevant sections found, allIndices: %s.', mfilename, mat2str(cellfun('size',allIndices,1)));
	error('Exiting.');
end;

prmetrics = []; scmetrics = []; RS = [];
for cviters = 1:CVFolds
	fprintf('\n%s: CV iteration: %u of %u', mfilename, cviters, CVFolds);

	[trainIndices, testIndices, RS] = createcv(allIndices, CVFolds, RS);
	fprintf('\n%s: Total: %s, Train: %s, Test: %s', mfilename, ...
		mat2str(cellfun('size',allIndices,1)), mat2str(cellfun('size',trainIndices,1)), mat2str(cellfun('size',testIndices,1)));

	% ugly!
	% trainflist, testflist must be column vectors (immitate seglist for HMM routines)
	% 	testflist = fmatrix(cell2mat(testIndices{:}))';
	%     trainflist = cell(length(thisTargetClasses),1);
	%     for class = 1:length(thisTargetClasses)
	%         testflist = [testflist(:);  fmatrix{class}(testIndices{class})'];
	%         testflist_idx = [testflist_idx;  repmat(class, size(testIndices{class},1), 1)];
	%         trainflist{class} = fmatrix(trainIndices{class})';
	%     end;

	testflist_idx = seglist(cell2mat(testIndices(:)), 4);
	HMMStruct.testseglist = fmatrix(cell2mat(testIndices(:)));
	for class = 1:length(thisTargetClasses)
		HMMStruct.eval.(HMMClasslist{class}).trainSegLabels = fmatrix(trainIndices{class});
	end; % for class


	% -------------------------------------------------------------------
	% HMM classification
	% -------------------------------------------------------------------

	% remove kmeans from voicebox
	%rmpath /home/oam/eth/lit/matlab/voicebox
	PathStruct = modifypath('Mode', 'suspend', 'PathString', {'voicebox', 'lit/matlab/netlab'});
	try 
		HMMStruct = hmm_evaluate(HMMStruct, testflist_idx);
	catch
		% restore path settings
		%addpath /home/oam/eth/lit/matlab/voicebox
		modifypath('Mode', 'restore', 'PathStruct', PathStruct);
		error('HMMs failed.');
	end;
	modifypath('Mode', 'restore', 'PathStruct', PathStruct);

	
	prmetrics = prmetrics_add(prmetrics, HMMStruct.stats);

	if (length(thisTargetClasses) == 2)
		thisscmetrics = scmetrics_mkstruct(HMMStruct.allproba(:,1), testflist_idx);
		scmetrics = scmetrics_append(scmetrics, thisscmetrics);
	end;
end; % for cviters

disp(prmetrics)
if (length(thisTargetClasses) == 2)
	prmetrics_classmetrics(prmetrics)
	disp(scmetrics)
end;
%scmetrics_plotroc('view', [], scmetrics);



% SAVE
if (DoSave)
	SaveTime = clock;
	HMMStruct.data = [];
	HMMStruct.testseglist = [];
	for class = 1:length(thisTargetClasses)
		HMMStruct.eval.(HMMClasslist{class}).trainSegLabels = [];
	end; % for class

	isohmm_filename = dbfilename(Repository, 'prefix', 'ISOHMM', 'suffix', SimSetID, 'subdir', 'ISO');
	fprintf('\n%s: Save %s...', mfilename, isohmm_filename);
	save(isohmm_filename, ...
		'HMMStruct', 'prmetrics', 'scmetrics', ...
		'thisTargetClasses', 'FeatureString', 'FullFeatureString', ...
		'allSegLabels', 'MergeClassSpec', 'Partlist', 'DSSet', 'CVFolds', 'StartTime', 'SaveTime');
	fprintf('done.');
end;

