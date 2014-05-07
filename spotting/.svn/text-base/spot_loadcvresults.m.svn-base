function [trainSLC testSLC trainseglist testseglist thisbestthres thisTargetClasses] = ...
	spot_loadcvresults(Repository, SimSetID, spotclass, cvslice, varargin)
% function [trainSLC testSLC trainseglist testseglist thisbestthres thisTargetClasses] = ...
% 	spot_loadcvresults(Repository, SimSetID, spotclass, cvslice, varargin)
% 
% Extract spotting results from spotting files.
%
% WARNING: This method works for parallel spotters only. Hence it does not
%                       concatinate runs for multiple subjects. 
% 
% See also: spot_convertfiles, spot_converthresarrays, prepallspotresults
%
% was: prepspotresults
% 
% Copyright 2008 Oliver Amft

[ReturnBestThres SpotType section_jitter ConvertDistance ReloadGT ReturnDistance verbose] = process_options(varargin, ...
	'ReturnBestThres', true, 'SpotType', 'SIMS', 'section_jitter', 0.5, ...
	'ConvertDistance', true, 'ReloadGT', false, 'ReturnDistance', false, 'verbose', 1);

if strcmpi(SpotType, 'SFCV'), ConvertDistance = false; end;


if (verbose), fprintf('\n%s: SimSetID: %s, spotclass=%u, cvslice=%u.', mfilename, SimSetID, spotclass, cvslice); end;

% filename = dbfilename(Repository, 'prefix', SpotType, 'indices', spotclass, 'suffix', SimSetID, 'subdir', 'SPOT');
filename = spot_isfile(SpotType, SimSetID, spotclass);
if iscell(filename) || (exist(filename,'file')==0)
	fprintf('\n%s: *** Spot file not found for SpotType=%s, SimSetID=%s, class=%u, skipping', mfilename, ...
        SpotType, SimSetID, spotclass);  
	return;
end;


% determine if old spot file format
ts = lsmatfile(filename, 'trainSeg');
if ~isempty(ts)
	if (verbose), fprintf('\n%s: WARNING: Using compatibility mode for old spotting files.', mfilename); end;
	SpotType = [ SpotType 'OLD' ]; 
end;
	
% process the different formats
switch upper(SpotType)
	case { 'SCOMPOLD', 'SFUSOLD' }
		spotfile = load(filename, 'testSeg', 'testDist', 'testSegGT', 'thisTargetClasses');
		trainSLC = spotfile.testSegGT; 
		testSLC = segment_createlist(spotfile.testSeg, 'classlist', spotfile.testSeg(:,4), 'conflist', spotfile.testDist);
		trainseglist = []; testseglist = spotfile.testSegGT;
		thisTargetClasses = spotfile.thisTargetClasses;
		thisbestthres = 0;
		return;

	case 'SFUS'    % does not contain a CV
		spotfile = load(filename, 'testSegBest', 'testSegGT', 'thisTargetClasses');
		trainSLC = spotfile.testSegGT; 
		testSLC = spotfile.testSegBest;
		trainseglist = []; testseglist = spotfile.testSegGT;
		thisTargetClasses = spotfile.thisTargetClasses;
		thisbestthres = 0;
		return;
		
		
	case { 'SIMSOLD', 'SFCVOLD' }
		spotfile = load(filename, 'metrics', ...
			'trainSeg', 'trainDist', 'testSeg', 'testDist', ...
			'bestthres', 'mythresholds', 'CVFolds', ...
			'trainSegGT', 'testSegGT', 'thisTargetClasses', ...
			'SaveTime');

		if ~isfield(spotfile, 'SaveTime'), spotfile.SaveTime = 0; end;
		if (verbose), fprintf('\n%s: File: %s, Date: %s',  mfilename, filename, datestr(spotfile.SaveTime)); end;

		% if (~iscell(testSeg{1})) fprintf('\n%s: WARNING: No test lists found!', mfilename); end;
		% if (length(bestthres) < CVFolds) fprintf('\n%s: WARNING: bestthres not available for each slice!', mfilename); end;
		trainseglist = spotfile.trainSegGT{cvslice};
		testseglist = spotfile.testSegGT{cvslice};

		thisTargetClasses = spotfile.thisTargetClasses;
		
		% convert OLD to NEW format
		[trainSegBest trainSegMax testSegBest testSegMax] = spot_converthresarrays(...
			spotfile.trainSeg, spotfile.trainDist, spotfile.testSeg, spotfile.testDist, spotfile.bestthres, spotfile.CVFolds);


		
	case { 'SIMS', 'SFCV' }  % new format with CV
		spotfile = load(filename, 'metrics', ...
			'trainSegBest', 'testSegBest', 	'trainSegMax', 'testSegMax', ...
            'testSegDist', ...
			'bestthres', 'mythresholds', 'CVFolds', ...
			'trainSegGT', 'testSegGT', 'thisTargetClasses', ...
			'SaveTime');

		if (verbose), fprintf('\n%s: File: %s, Date: %s',  mfilename, filename, datestr(spotfile.SaveTime)); end;

		trainseglist = spotfile.trainSegGT{cvslice};
		testseglist = spotfile.testSegGT{cvslice};

		thisTargetClasses = spotfile.thisTargetClasses;
		
		trainSegBest =  spotfile.trainSegBest;   testSegBest =  spotfile.testSegBest;  
		trainSegMax =  spotfile.trainSegMax;   testSegMax =  spotfile.testSegMax;  		

	otherwise
		error('Spot type ''%s'' not supported.', upper(SpotType));
end;



% if requested reconstruct GT from labelling directly, not from spot result files
% provides alternate trainseglist, testseglist
if (ReloadGT)
	% this is a hack for spottings that are derived for modified labelling sets
	% however for following processing steps the full set is required
	spotfile = catstruct( spotfile, load(filename,  'CVMethod', 'Partlist', 'MergeClassSpec') );

	labellist_load = repos_getlabellist(Repository, spotfile.Partlist);  % initlabels_load (initmain.m)
	[labellist thisTargetClasses] = segment_classfilter(spotfile.MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');
	classseglist = segment_findlabelsforclass(labellist, spotfile.thisTargetClasses);  % main_spotidentify.m

	% check: typically this will work only if label properties differ
	spotfile = catstruct( spotfile, load(filename, 'classseglist') );
	if any(any(spotfile.classseglist(:,1:2) ~= classseglist(:,1:2))), error('Seglists do not match.'); end;
	if any(spotfile.thisTargetClasses ~= spotclass), error('thisTargetClass does not match.'); end;

% 	CVSectionBounds = tryloadvar(filename, 'CVSectionBounds');
% 	if isempty(CVSectionBounds)   % backward compatibility hack
% 		%CVSectionBounds = sandbox('initmain_CVSectionBounds_Seq', ...
% 		%	'in', {'labellist_load', labellist_load}, 'out', {'CVSectionBounds'}); 
% 		initmain_CVSectionBounds_Seq;
% 	end; 
% 	spotfile = catstruct( spotfile, load(filename,  'LabelConfThres', 'mintrainshare') );
% 	[trainslices, testslices] = spot_createcvsplit(spotfile.CVMethod, spotfile.CVFolds, classseglist, ...
% 		Repository, spotfile.Partlist, 'mintrainshare', spotfile.mintrainshare, 'LabelConfThres', spotfile.LabelConfThres, ...
% 		'CVSectionBounds', CVSectionBounds);

    spotfile = catstruct( spotfile, load(filename,  'trainslices', 'testslices') );
	trainseglist = classseglist(segment_countoverlap(classseglist, spotfile.trainslices{cvslice}) > 0, :);
	testseglist = classseglist(segment_countoverlap(classseglist, spotfile.testslices{cvslice}) > 0, :);

	% checks
	if any(any(trainseglist(:,1:2) ~= spotfile.trainSegGT{cvslice}(:,1:2))), error('trainlists do not match.'); end;
	if any(any(testseglist(:,1:2) ~= spotfile.testSegGT{cvslice}(:,1:2))), error('testlists do not match.'); end;
end;

		
		
% create trainSLC, testSLC
if (ReturnBestThres)
	% return section list for best result only
	trainSLC = trainSegBest{cvslice};
    testSLC = testSegBest{cvslice};
    if ReturnDistance
        if ~isempty(trainSegBest), testSLC(:,6) = spotfile.testSegDist{cvslice}{1}; end;
    end;
    
	thisbestthres = spotfile.mythresholds{cvslice}(spotfile.bestthres(cvslice));

    if (length(spotfile.mythresholds{cvslice}) == spotfile.bestthres(cvslice)) && (length(spotfile.mythresholds{cvslice})>1)
        fprintf('\n%s: WARNING: bestthres == max threshold (%u) in %s, class %u.',  mfilename, ...
            spotfile.bestthres(cvslice), SimSetID, spotclass);
    end;
else % if not ReturnBestThres
	if isempty(trainSegMax)
		fprintf('\n%s: WARNING: trainSegMax is empty. Max threshold not available, using best instead.', mfilename);
		trainSLC = trainSegBest{cvslice};
		testSLC = testSegBest{cvslice};

		thisbestthres = spotfile.mythresholds{cvslice}(spotfile.bestthres(cvslice));
	else
		trainSLC = trainSegMax{cvslice};
		testSLC = testSegMax{cvslice};

		thisbestthres = spotfile.mythresholds{cvslice}(end);
	end;
    if ReturnDistance
        if ~isempty(trainSegBest), testSLC(:,6) = spotfile.testSegDist{cvslice}{end}; end;
    end;
end;



% Convert distance to confidence
if (ConvertDistance)
%     if ~ReturnBestThres, fprintf('\n%s: WARNING: Max threshold and convert distance requested - not useful!', mfilename); end;
    
    % check if exceeding (0,1) range
%     if (~isempty(trainSLC)) && all(isbetween(trainSLC(:,6), [0 1])) && (~isempty(testSLC)) && all(isbetween(testSLC(:,6), [0 1]))
%         fprintf('\n%s: WARNING: Spotting result seems to be a confidence list already.', mfilename);
%     end;
    
%     if ~isempty(trainSLC), trainSLC(:,6) = distance2confidence(trainSLC(:,6), thisbestthres); end;
%     if ~isempty(testSLC), testSLC(:,6) = distance2confidence(testSLC(:,6), thisbestthres); end;
    fprintf('\n%s: WARNING: Converting distance to confidence is disabled.', mfilename);
end;


% correct class label, SIMS from main_spotidentify may not have a class numbering
if ~isempty(trainSLC) && any(trainSLC(:,4)==0), trainSLC = segment_createlist(trainSLC, 'classlist', spotclass); end;
if ~isempty(testSLC) && any(testSLC(:,4)==0),  testSLC = segment_createlist(testSLC, 'classlist', spotclass); end;


if (verbose), fprintf('\n'); end;