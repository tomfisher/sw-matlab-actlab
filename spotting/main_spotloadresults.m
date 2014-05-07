% main_spotloadresults
%
% load spotting results, used by:  main_spotsweep
%
% provides: CVFolds, trainSLC (cells!), testSLC, trainseglist (cells!), testseglist
%
% TODO: combine training segments from append loads!
%
% requires:
thisTargetClasses;
SpotType;
SimSetID_List;
% section_jitter;
LabelConfThres;

% if (~exist('LabelConfThres', 'var')), LabelConfThres = 0; end;

if ~exist('DoPerformanceEval', 'var'), DoPerformanceEval = false; end;
if ~exist('ReturnDistance', 'var'), ReturnDistance = false; end;
if ~exist('BestThresOnly', 'var'), BestThresOnly = true; end;
if ~exist('Repository', 'var'), initdata; end;



% find out class automatically
% filename = spot_isfile(SpotType, SimSetID, spotclass)

% number of parallel spotting streams
NrSpotters = length(SimSetID_List)*length(thisTargetClasses);


% -------------------------------------------------------------------------
% load spotting results
% -------------------------------------------------------------------------

fprintf('\n%s: Loading section information for CV slices...', mfilename);
switch upper(SpotType)
	case { 'SIMS' 'SFCV' }  % parallel results
		[trainSLC testSLC trainseglist testseglist CVFolds ] = ...
			prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
			'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false, ...
			'SpotType', SpotType, 'ReturnDistance', ReturnDistance, 'verbose',2);

	case 'SIMSMAX'
		[trainSLC testSLC trainseglist testseglist CVFolds ] = ...
			prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
			'BestThresOnly', false, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', true, ...
			'ConvertDistance', false, 'SpotType', 'SIMS', 'ReturnDistance', ReturnDistance, 'verbose',2);

	case { 'SIMSAPPEND', 'SFCVAPPEND' }  
        % load results from non-overlapping spotting runs, serialise results
        % WARNING: for confidence sweeps using independent spotters confidences may have different scaling
        %   normalise by stdv or perfrom sweeping independently and combine prmetrics
		if strcmpi(SpotType, 'SIMSAPPEND')
			thisSpotType = 'SIMS';   
%             if ~exist('ConvertDistance','var'), ConvertDistance = true; end;
		else
			thisSpotType = 'SFCV';    
%             if ~exist('ConvertDistance','var'), ConvertDistance = true; end;
		end;
        ConvertDistance = false;
		simoffsets = zeros(1, length(SimSetID_List)+1);  		testSLCoffsets = zeros(1, length(SimSetID_List)+1);
		trainSLC = []; testSLC = []; trainseglist = []; testseglist = [];
		for s = 1:length(SimSetID_List)
			thisSimSetID = SimSetID_List{s};
% 			%filename = dbfilename(Repository, 'prefix', 'SIMS', 'indices', 1, 'suffix', thisSimSetID, 'subdir', 'SPOT');
% 			filename = dbfilename(Repository, 'prefix', 'SIMS', 'indices', '*', 'suffix', thisSimSetID, 'subdir', 'SPOT');
% 			filename = findfiles(filename, 'notfoundmode', 'raiseerror', 'returnmode', 'first');
			filename = spot_isfile(thisSpotType, thisSimSetID);
            if isemptycell({filename}), fprintf('\n%s: WARNING: Spot file %s not found for SetSimID: %s.', mfilename, thisSpotType, thisSimSetID); end;

			partsizes = repos_getpartsize(Repository, loadin(filename, 'Partlist'), 'OffsetMode', true);
			simoffsets(s+1) = partsizes(end)+1;

			[this_trainSLC  this_testSLC this_trainseglist this_testseglist CVFolds ] = ...
				prepallspotresults(Repository, thisTargetClasses, {thisSimSetID}, ...
				'BestThresOnly', BestThresOnly, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', ~BestThresOnly, ...         
				'ConvertDistance', ConvertDistance, 'SpotType', thisSpotType, 'ReturnDistance', ReturnDistance, 'verbose',2);
          
% 				'BestThresOnly', false, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', true, ...         

            %this_testSLC(:,6) = mstandardise(this_testSLC(:,6));
            % this does not work since each spotter has a specific distribution average, 
            % due to outliers this is hard to determine

			testSLC = [testSLC; segment_shiftlist(this_testSLC, sum(simoffsets(1:s)))];
			testseglist = [testseglist; segment_shiftlist(this_testseglist, sum(simoffsets(1:s)))];
            testSLCoffsets(s+1) = size(this_testSLC,1);
		end;
		% distances are converted to confidence using the applicable thresholds in prepspotresults
		fprintf('\n%s: Distance ranges: %.2f-%.2f', mfilename, min(testSLC(:,6)), max(testSLC(:,6)));
		%hist(testSLC(:,6), 20); drawnow;

	case {'SCOMP', 'SFUS'}
		[trainSLC testSLC trainseglist testseglist CVFolds ] = ...
			prepallspotresults(Repository, 1, SimSetID_List, ...
			'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false, ...
			'SpotType', SpotType, 'verbose',2);


	case 'SFUSAPPEND'  % load results from non-overlapping spotting runs, append results
		simoffsets = zeros(1, length(SimSetID_List)+1);
		trainSLC = []; testSLC = []; trainseglist = []; testseglist = [];
		for s = 1:length(SimSetID_List)
			thisSimSetID = SimSetID_List{s};
			%filename = dbfilename(Repository, 'prefix', 'SFUS', 'indices', 1, 'suffix', thisSimSetID, 'subdir', 'SPOT');
			filename = dbfilename(Repository, 'prefix', 'SFUS', 'indices', '*', 'suffix', thisSimSetID, 'subdir', 'SPOT');
			filename = findfiles(filename, 'notfoundmode', 'raiseerror', 'returnmode', 'first');

			partsizes = repos_getpartsize(Repository, loadin(filename, 'Partlist'), 'OffsetMode', true);
			simoffsets(s+1) = partsizes(end)+1;

			[this_trainSLC this_testSLC this_trainseglist this_testseglist CVFolds ] = ...
				prepallspotresults(Repository, 1, {thisSimSetID}, ...
				'BestThresOnly', false, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', true, ...
				'SpotType', 'SFUS', 'verbose',2);

			%trainSLC = [trainSLC; segment_shiftlist(this_trainSLC, sum(simoffsets(1:s)))];
			testSLC = [testSLC; segment_shiftlist(this_testSLC, sum(simoffsets(1:s)))];
			%trainseglist = [trainseglist; segment_shiftlist(this_trainseglist, sum(simoffsets(1:s)))];
			testseglist = [testseglist; segment_shiftlist(this_testseglist, sum(simoffsets(1:s)))];
		end;
	otherwise
		error('SpotType ''%s'' not understood.', SpotType);
end;

if (DoPerformanceEval)
	fprintf('\n%s: Total result:', mfilename);
	totalmetric = prmetrics_softalign(testseglist, testSLC, 'LabelConfThres', LabelConfThres, 'jitter', section_jitter);
	prmetrics_printstruct(totalmetric);

	fprintf('\n%s: Class-wise result:', mfilename);
	clear classmetric;
	for class = 1:length(thisTargetClasses)
		classmetric(class) = prmetrics_softalign( ...
			segment_findlabelsforclass(testseglist, thisTargetClasses(class)), ...
			segment_findlabelsforclass(testSLC, thisTargetClasses(class)), 'LabelConfThres', LabelConfThres, 'jitter', section_jitter );
	end;
	prmetrics_printstruct(classmetric);

	fprintf('\n%s: Coverage with spot segments: GT labels:%.1f%%,  total data: %.1f%%', mfilename, ...
		sum(segment_size(testSLC))/sum(segment_size(testseglist))*100, ...
		sum(segment_size(testSLC))/testseglist(end,2));
end; % if (DoPerformanceEval)
