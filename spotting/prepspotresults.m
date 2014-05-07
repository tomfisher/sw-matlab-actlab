function [trainSLC testSLC trainseglist testseglist thisbestthres thisTargetClasses] = ...
	prepspotresults(Repository, SimSetID, class, cvslice, varargin)
% function [trainSLC testSLC trainseglist testseglist thisbestthres thisTargetClasses] = ...
% 	prepspotresults(Repository, SimSetID, class, cvslice, varargin)
% Extract spotting results from main_simspotting() or similar spotting
% result files
%
% trainSLC, testSLC: segment lists of the format: [beg end confidence]
% BestThresOnly: return section list for best result only
%
% WARNING: This method works for parallel spotters only. Hence it cannot be
% used to concatinate runs for multiple subjects.

% % function [trainSLC testSLC trainseglist testseglist ...
% % 	metrics_train metrics_test thisbestthres thisTargetClasses] = ...
% % 	prepspotresults(Repository, SimSetID, class, cvslice, varargin)


[config_BestThresOnly SpotType section_jitter ConvertDistance ReloadGT verbose] = process_options(varargin, ...
	'BestThresOnly', true, 'SpotType', 'SIMS', 'section_jitter', 0.5, ...
	'ConvertDistance', true, 'ReloadGT', false, 'verbose', 1);

if strcmpi(SpotType, 'SFCV'), ConvertDistance = false; end;


if (verbose), fprintf('\n%s: SimSetID: %s, class=%u, cvslice=%u.', mfilename, SimSetID, class, cvslice); end;

filename = dbfilename(Repository, 'prefix', SpotType, 'indices', class, 'suffix', SimSetID, 'subdir', 'SPOT');
if (exist(filename,'file')==0)
	fprintf('\n%s: *** File %s not found, skipping', mfilename, filename);
	return;
end;

clear testSeg testDist bestthres mythresholds CVFolds;
clear trainSeg trainDist metrics;
thisbestthres = NaN;
thisTargetClasses = NaN;

switch upper(SpotType)
	case { 'SCOMP', 'SFUS' }
		load(filename, 'testSeg', 'testDist', 'testSegGT', 'thisTargetClasses');
		trainSLC = testSegGT; testSLC = segment_createlist(testSeg, 'classlist', testSeg(:,4), 'conflist', testDist);
		trainseglist = []; testseglist = testSegGT;
		return;

	case { 'SIMS', 'SFCV' }
		load(filename, 'metrics', ...
			'trainSeg', 'trainDist', 'testSeg', 'testDist', ...
			'bestthres', 'mythresholds', 'CVFolds', ...
			'trainSegGT', 'testSegGT', 'thisTargetClasses', ...
			'SaveTime');

		try SaveTime; catch SaveTime = 0; end;
		if (verbose), fprintf('\n%s: File: %s, Date: %s',  mfilename, filename, datestr(SaveTime)); end;

		% if (~iscell(testSeg{1})) fprintf('\n%s: WARNING: No test lists found!', mfilename); end;
		% if (length(bestthres) < CVFolds) fprintf('\n%s: WARNING: bestthres not available for each slice!', mfilename); end;

		% if requested reconstruct GT from labelling directly, not from spot result files
		if (ReloadGT)
			% this is a hack for spottings that are derived for modified labelling sets 
			% however for following processing steps the full set is required
			load(filename, 'CVMethod', 'CVFolds', 'Partlist', 'MergeClassSpec', 'thisTargetClasses');
			mintrainshare = tryloadvar(filename, 'mintrainshare'); 
			if isempty('mintrainshare'),  mintrainshare = 0.1; end;  % backward compatibility hack
			labellist_load = cla_getseglist(Repository, Partlist);  % initlabels_load (initmain.m)
			[labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');
			classseglist = segment_findlabelsforclass(labellist, thisTargetClasses);  % main_spotidentify.m
			
			% check: typically this will work only if label properties differ 
			tmp = loadin(filename, 'classseglist');
			if any(any(tmp(:,1:2) ~= classseglist(:,1:2))), error('Seglists do not match.'); end;
			if any(thisTargetClasses ~= class), error('thisTargetClass does not match.'); end;
			
			[trainslices, testslices] = spot_createcvsplit(CVMethod, CVFolds, classseglist, ...
				Repository, Partlist, 'mintrainshare', mintrainshare);
			
			trainseglist = classseglist(segment_countoverlap(classseglist, trainslices{cvslice}) > 0, :);
			testseglist = classseglist(segment_countoverlap(classseglist, testslices{cvslice}) > 0, :);
			
			% checks
			if any(any(trainseglist(:,1:2) ~= trainSegGT{cvslice}(:,1:2))), error('trainlists do not match.'); end;
			if any(any(testseglist(:,1:2) ~= testSegGT{cvslice}(:,1:2))), error('testlists do not match.'); end;			
		else
			trainseglist = trainSegGT{cvslice};
			testseglist = testSegGT{cvslice};
		end;

		%thisbestthres = (bestthres(cvslice));
		thisbestthres = mythresholds{cvslice}(bestthres(cvslice));
	otherwise
		error('Spot type ''%s'' not supported.', upper(SpotType));
end;


% -------------------------------------------------------------------------
% Training slices
% -------------------------------------------------------------------------
nrthresholds = size(trainSeg{cvslice},2);
if (config_BestThresOnly)
	% return section list for best result only
	trainSLS = []; trainSCS = [];
	for tslice = 1:size(trainSeg{cvslice},1)
		trainSLS = [trainSLS; trainSeg{cvslice}{tslice,bestthres(cvslice)}];

		if (ConvertDistance)
			% OAM REVISIT: Convert distance to confidence!
			%trainSCS = [trainSCS; 1-(trainDist{cvslice}{tslice,bestthres(cvslice)}./mythresholds(bestthres(cvslice)))];
			%trainSCS = [trainSCS; (mythresholds(bestthres(cvslice))-trainDist{cvslice}{tslice,bestthres(cvslice)})./mythresholds(bestthres(cvslice))];
			trainSCS = [trainSCS; distance2confidence(trainDist{cvslice}{tslice,bestthres(cvslice)}, mythresholds{cvslice}(bestthres(cvslice)))];
		else
			trainSCS = [trainSCS; trainDist{cvslice}{tslice,bestthres(cvslice)}];
		end;
	end;

	trainSLC = segment_createlist(trainSLS, 'classlist', class, 'conflist', trainSCS);


else % if not config_BestThresOnly
	if (nrthresholds)
		clear trainSLS trainSCS;
		trainSLS{nrthresholds} = []; trainSCS{nrthresholds} = [];
	else
		% slice contains no sections
		trainSLS = []; trainSLC = [];
	end;

	for i = 1:nrthresholds
		for tslice = 1:size(trainSeg{cvslice},1)
			trainSLS{i} = [trainSLS{i}; trainSeg{cvslice}{tslice,i}];
			trainSCS{i} = [trainSCS{i}; trainDist{cvslice}{tslice,i}];
		end;
		
		if (ConvertDistance)
			trainSCS{i} = distance2confidence(trainSCS{i}, mythresholds{cvslice}(i));
		else
			%trainSCS{i} = trainSCS{i};
		end;
		trainSLC{i} = segment_createlist(trainSLS{i}, 'classlist', class, 'conflist', trainSCS{i});
	end;
end;



% -------------------------------------------------------------------------
% Testing slices
% -------------------------------------------------------------------------
nrthresholds = size(testSeg{cvslice},2);
if (config_BestThresOnly)
	testSLS = testSeg{cvslice}{bestthres(cvslice)};

	if (ConvertDistance)
		% OAM REVISIT: Convert distance to confidence!
		%testSCS = 1-(testDist{cvslice}{bestthres(cvslice)}./mythresholds(bestthres(cvslice)));
		%testSCS = (mythresholds(bestthres(cvslice))-testDist{cvslice}{bestthres(cvslice)})./mythresholds(bestthres(cvslice));
		testSCS = distance2confidence(testDist{cvslice}{bestthres(cvslice)}, mythresholds{cvslice}(bestthres(cvslice)));
	else
		testSCS = testDist{cvslice}{bestthres(cvslice)};
	end;
	testSLC = segment_createlist(testSLS, 'classlist', class, 'conflist', testSCS);
else
	testSLS = testSeg{cvslice};

	for i = 1:nrthresholds
		if (ConvertDistance)
			testSCS{i} = distance2confidence(testDist{cvslice}{i}, mythresholds{cvslice}(i));
		else
			testSCS{i} = testDist{cvslice}{i};
		end;
		testSLC{i} = segment_createlist(testSLS{i}, 'classlist', class, 'conflist', testSCS{i});
	end;

end;

if (verbose), fprintf('\n'); end;