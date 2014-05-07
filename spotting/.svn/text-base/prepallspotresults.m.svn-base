function [trainSLC testSLC trainseglist testseglist CVFolds allspotterclassmap] = ...
	prepallspotresults(Repository, Classes, SimSetID_List, varargin)
% Extract spotting results from main_simspotting() or similar spotting
% result files. Function builds on prepspotresult().
%
% trainSLC, testSLC:  Segment lists for each cvslice, (spotter), (threshold)
% Classes:                 List of classes, numbered according to Sim files, 1:n
% SimSetID_List:        Singe ID or list of IDs to fetch (cell list)
%
% Options:
% BestThresOnly:        True: Return section list for best result only
% MaxThresOnly:         Ture: Return all segments from last (loosest)
%                       threshold. Must go with: BestThresOnly=false
% MergeSpotters:        True: Return section list merged for all spotters
%                       Can be used only if either BestThresOnly or MaxThresOnly was set
% MergeCV:              True: append all CVs
% ReloadGT: False: Use ground truth from spotting runs, True: Recreate GT
% 
% Copyright 2006-2008 Oliver Amft

[config_BestThresOnly config_MaxThresOnly config_MergeSpotters config_MergeCV ...
	MergedClasses, config_MapClassSpec SpotType section_jitter ConvertDistance ReloadGT ...
    ReturnDistance verbose] = ...
	process_options(varargin, ...
	'BestThresOnly', true, 'MaxThresOnly', false, 'MergeSpotters', false, 'MergeCV', false, ...
	'MergedClasses', nan, 'MapClassSpec', {}, 'SpotType', 'SIMS', 'section_jitter', 0.5, ...
	'ConvertDistance', true, 'ReloadGT', false, 'ReturnDistance', false, 'verbose', 1);


if (verbose), fprintf('\n%s: SimSetIDs: %s', mfilename, cell2str(SimSetID_List)); end;

% probe SimSetID file to determine parameters, use first hit (class nr is typically unknown here) 
filenamemask = repos_makefilename(Repository, 'prefix', SpotType, 'indices', '*', 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
%filename = repos_makefilename(Repository, 'prefix', SpotType, 'indices', Classes(1), 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
filename = findfiles(filenamemask, 'notfoundmode', 'raiseerror', 'returnmode', 'first'); 

clear CVFolds;
CVFolds = loadin(filename, 'CVFolds' );

if isempty(Classes)
	fprintf('\n%s:  Guessing classes...', mfilename); 
	Classes = loadin(filename, 'thisTargetClasses');
	%Classes = 1:length(Classes);
	fprintf('%s    <===   CHECK !', mat2str(Classes)); 
end;

% merged classes: several classids in one spot file (typically spotters had
% been merged in a previous processing state)
if isnan(MergedClasses)
	if length(findfiles(filenamemask))==1 && length(Classes)>1
		MergedClasses = true; 
	else
		MergedClasses = false;
	end;
end;
if (MergedClasses) && length(Classes)>1
	fprintf('\n%s: Classes are merged, loading first id only.', mfilename);
	Classes = Classes(1);
end;

% number of parallel spotting streams
NrSpotters = length(SimSetID_List)*length(Classes);

if (verbose), fprintf('\n%s: CVFolds: %u, Spotters: %u', mfilename, CVFolds, NrSpotters); end;


% combine all section spotting results for each CV fold, class and sim run
% retrieve strainSLC, stestSLC
% (SLC=section list and confidence)
if (verbose), fprintf('\n%s: Loading section information for CV slice...', mfilename); end;

clear trainSLC testSLC trainseglist testseglist;

if (~config_MergeSpotters)
	trainSLC = cell(NrSpotters,CVFolds); testSLC = cell(NrSpotters,CVFolds);
else
	trainSLC = cell(1,CVFolds); testSLC = cell(1,CVFolds);
end;

trainseglist = cell(1,CVFolds); testseglist = cell(1,CVFolds);
for cvslice = 1:CVFolds
	if (verbose), fprintf(' %.0f%%', cvslice/CVFolds*100); end;

	for classnr = 1:length(Classes)
		allspotterclassmap = [];
		for spotternr = 1:length(SimSetID_List)

% 			[this_trainSLC this_testSLC this_trainseglist this_testseglist dummy thisTargetClasses] = ...
% 				prepspotresults(Repository, SimSetID_List{spotternr}, Classes(classnr), cvslice, ...
% 				'BestThresOnly', config_BestThresOnly, 'SpotType', SpotType, ...
% 				'ConvertDistance', ConvertDistance, 'ReloadGT', ReloadGT, 'verbose', false);

			[this_trainSLC this_testSLC this_trainseglist this_testseglist dummy thisTargetClasses] = ...
				spot_loadcvresults(Repository, SimSetID_List{spotternr}, Classes(classnr), cvslice, ...
				'ReturnBestThres', config_BestThresOnly, 'SpotType', SpotType, ...
				'ConvertDistance', ConvertDistance, 'ReloadGT', ReloadGT, 'ReturnDistance', ReturnDistance, 'verbose', false);


			% return max threshold results
			% requires BestThresOnly=false and config_MaxThresOnly = true
			if (config_MaxThresOnly) && (iscell(this_trainSLC))
				this_trainSLC = this_trainSLC{end};
			end;
			if (config_MaxThresOnly) && (iscell(this_testSLC))
				this_testSLC = this_testSLC{end};
			end;


			% class re-mapping
			% assign individual class numbers to all spotters (independent spotters)
			% requires BestThresOnly=true OR config_MaxThresOnly = true
			thismap = [];
			if iscell(config_MapClassSpec) && (length(config_MapClassSpec) >= spotternr)
				thismap = config_MapClassSpec{spotternr};
			elseif (~iscell(config_MapClassSpec)) && (~isempty(config_MapClassSpec)) && (config_MapClassSpec == true)
				thismap = length(allspotterclassmap)+1:length(allspotterclassmap)+length(thisTargetClasses);
				allspotterclassmap = [allspotterclassmap thismap];
			end;
			if ~isempty(thismap)
				[dummy this_trainSLC] = segment_mergespec2mapspec(num2cell(thismap), this_trainSLC);
				[dummy this_testSLC] = segment_mergespec2mapspec(num2cell(thismap), this_testSLC);
			end;
            

            % iff needed for some analysis, put re-estimation of optimal threshold here
            % OAM REVISIT: Not done, since inherents many paramters
            % see also: prmetrics_findoptimumfromseg

            
			% combine spotting result
			if (config_MergeSpotters)
				trainSLC(cvslice) = cellappend(trainSLC(cvslice), this_trainSLC,1);
				testSLC(cvslice) = cellappend(testSLC(cvslice), this_testSLC,1);
			else
				if ~isempty(trainSLC{spotternr+length(SimSetID_List)*(classnr-1), cvslice}), error('Uuups, overriding something here!'); end;
				trainSLC{spotternr+length(SimSetID_List)*(classnr-1), cvslice} = this_trainSLC;
				testSLC{spotternr+length(SimSetID_List)*(classnr-1), cvslice} = this_testSLC;
			end;

		end; % for spotternr

		% labeling, all classes, assumed same for all spotters of one class
		% loading from spotting results avoids fiddeling with sampling rate and CV slicing
		trainseglist{cvslice} = [trainseglist{cvslice}; this_trainseglist];
		testseglist{cvslice} = [testseglist{cvslice}; this_testseglist];

		if (verbose>1) && (config_MergeSpotters)  % print problems otherwise
			fprintf('\n%s: Class %u: Test labels: %u Test sections: %u', mfilename, ...
				Classes(classnr), sum(cellfun('size', testseglist,1)), sum(cellfun('size', testSLC,1)));
		end;
	end; % for classnr

end; % for cvslice



% merge all testing CV slices into one big list
% Done only for testSLC, since trainSLC contains overlapping segments from
% individual CV spotting runs.
if (config_MergeCV)
	if ~config_MergeSpotters, error('Spotters must be merged to merge CVs.'); end;
	
	tmp_testSLC = []; tmp_testseglist = [];
	for cvslice = 1:CVFolds
		tmp_testSLC = [tmp_testSLC; testSLC{cvslice}];
		tmp_testseglist = [tmp_testseglist; testseglist{cvslice}];
	end;
	testSLC = segment_sort(tmp_testSLC,2);
	testseglist = segment_sort(tmp_testseglist,2);
end;

