% main_marker_spotviewlabels
%
% Extract/prepare spotting results for Marker display
%
% Calling procedure:
%
%   DisplayResult = 'spot'; SimSetID = 'OliverCLettuce2AA'; SpotType = 'SIMS'; Partindex = 87; main_marker; 
%
% Optional parameters: 
%   DoSetupDisp - initialise additional MARKER display, default: true
%   ConfViewLimit - lower confidence limit to visualise labels
%   thisTargetClasses - specific class to display, if omitted this is guessed (check printout) 

% requires
Partindex;
SimSetID;
%MergeClassSpec;

% requires Marker version 0.9.3
if (marker_version('vernr') < 903), error('Script %s requires Marker version 903 or greater', mfilename); end;

if ~exist('DoSetupDisp','var'),  DoSetupDisp = true; end;  % setup MARKER plot
if ~exist('ConfViewLimit','var'),  ConfViewLimit = 0; end;  % lower limit for label confidence to visualise
if (ConfViewLimit>0), fprintf('\n%s: ConfViewLimit=%.2f', mfilename, ConfViewLimit); end;

initdata;

% thisTargetClasses can be determined automatically, if only one file
% for the SimSetID exists. prepallspotresults does the job. 
if ~exist('thisTargetClasses','var'), thisTargetClasses = []; end;  % use automatic guessing

if ~exist('SimSetID_List','var'), 	SimSetID_List = {SimSetID}; end;
if ~exist('SpotType','var'),  SpotType = 'SIMS'; end;

if ~exist('ReestimateThres','var'),  ReestimateThres = false; end;


% OAM REVISIT: Merge with main_spotloadresults

switch SpotType
	case { 'SIMS' 'SFCV' }
		fprintf('\n%s: Loading section information for CV slices...', mfilename);
        if strcmpi(SpotType, 'SIMS')
            if ~exist('ConvertDistance','var'), ConvertDistance = true; end;
        else
            ConvertDistance = false; 
        end;
        if ~ReestimateThres
            [dummy labellist dummy testseglist] = prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false, ...
                'SpotType', SpotType, 'ConvertDistance', ConvertDistance);
        else
            [dummy labellist dummy testseglist] = prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
                'BestThresOnly', false, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', true, ...
                'SpotType', SpotType, 'ConvertDistance', ConvertDistance);
        end;

        % get Partlist (needed to determine partoffsets and match labels to part viewed 
		filename = spot_isfile(SpotType, SimSetID_List{1}, thisTargetClasses);
% 		if isempty(thisTargetClasses) % assume any class
% 			filename = dbfilename(Repository, 'prefix', SpotType, 'indices', '*', 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
% 			filename = findfiles(filename, 'notfoundmode', 'raiseerror', 'returnmode', 'first');
% 			fprintf('\n%s: Load Partlist from %s.', mfilename, filename);
% 		else
% 			filename = dbfilename(Repository, 'prefix', SpotType, 'indices', thisTargetClasses, 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
% 		end;
		load(filename, 'Partlist');
		if isempty(thisTargetClasses), load(filename, 'thisTargetClasses'); end;

	case 'SIMS2'
		fprintf('\n%s: Loading section information for CV slices...', mfilename);
		thisTargetClasses = []; % use automatic guessing
		[dummy labellist dummy testseglist] = prepallspotresults(Repository, 1:length(thisTargetClasses), SimSetID_List, ...
			'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false, ...
			'SpotType', 'SIMS');

	case 'SFUS'
		fprintf('\n%s: Loading section information for CV slices...', mfilename);
		thisTargetClass = 1; % most likely nothing else
		[dummy labellist dummy testseglist] = prepallspotresults(Repository, thisTargetClass, SimSetID_List, ...
			'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false, ...
			'SpotType', 'SFUS');  % 'ConvertDistance', false

		% get Partlist (needed to determine partoffsets and match labels to part viewed 
		if isempty(thisTargetClasses) % assume any class
			filename = dbfilename(Repository, 'prefix', SpotType, 'indices', '*', 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
			filename = findfiles(filename, 'notfoundmode', 'raiseerror', 'returnmode', 'first');
			fprintf('\n%s: Load Partlist from %s.   <=== CHECK!', mfilename, filename);
		else
			filename = dbfilename(Repository, 'prefix', SpotType, 'indices', thisTargetClasses, 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
		end;
		load(filename, 'Partlist');

		
	case 'SCOMP2'
		% OAM REVISIT: This is a hack to run script independent of other files
		filename = fullfile('DATA', 'SPOT', ['SCOMP' '_' mat2str(thisTargetClasses(1)) '_' SimSetID '.mat']);
		fprintf('\n%s: Load labels from %s...', mfilename, filename);
		load(filename, 'testSeg', 'testDist');
		labellist = [ testSeg(:,1:5) testDist(:) ];
		
	case { 'CC1', 'CC3' }
		LabelType = SpotType;   LabelVar = 'CCPhase1List'; 
		partseglist = cla_getseglist(Repository, Partindex);
		chewseglist = sandbox('initmain_segchewlabels', 'in', {'labellist_load', partseglist, 'Repository', Repository, ...
			'Partlist', Partindex, 	'partoffsets', 0, 'MergeClassSpec', MergeClassSpec, 'LabelType', ...
			LabelType, 'LabelVar', LabelVar}, 'out', {'labellist_load'});
		

	otherwise
		error('SpotType not understood.');
end;

% fprintf('\n%s: Spotting result (without considering LabelConfThres, default jitter):', mfilename);
% prmetrics_printstruct(prmetrics_softalign(testseglist, labellist));

if ~exist('MergeClassSpec','var')
    %fprintf('\n%s: WARNING: No MergeClassSpec given, merging all classes.', mfilename);
	MergeClassSpec = { thisTargetClasses };
end;
fprintf('\n%s: MergeClassSpec = {%s}, thisTargetClasses = %s', mfilename, ...
    cell2str(MergeClassSpec,','), mat2str(thisTargetClasses));



% re-estimate best threshold
if ReestimateThres
    % WARNING: BestThresOnly should be off!
    % assuming that distance has been converted to confidence already
    labellist_loaded = labellist;
    [labellist metricopt] = prmetrics_findoptimumfromseg(labellist_loaded, testseglist, 'PrecisionThres', 0.6);
%     prmetrics_printstruct(metricopt);
end;



prmetrics_printstruct(prmetrics_softalign(testseglist, labellist));
viewlabels = prepviewlabels(Repository, Partlist, Partindex, labellist, 'MapClassSpec', MergeClassSpec);
%prmetrics_printstruct(prmetrics_softalign(repos_findlabelsforpart(testseglist, find(Partlist==Partindex), partoffsets, 'remove'), labellist))
viewlabels = viewlabels(viewlabels(:,6)>=ConfViewLimit,:);

viewclasses = unique(viewlabels(:,4));

% configure disp
if (~isempty(viewlabels)) && (DoSetupDisp)
	sysno = length(drawerobj.disp)+1;
	drawerobj.disp(sysno).type = 'Segments';
	drawerobj.disp(sysno).save = false;
	drawerobj.disp(sysno).data = viewlabels;
	drawerobj.disp(sysno).plotfunc = @marker_plotlabeling;
	% OAM REVISIT: hack
%	drawerobj.disp(sysno).plotfunc_params = { max(viewclasses), marker_makelabelstr([], drawerobj, 1:max(viewclasses)) };
% 	drawerobj.disp(sysno).plotfunc_params = { max(viewclasses) };	
	drawerobj.disp(sysno).plotfunc_params = { viewclasses, marker_makelabelstr([], drawerobj, viewclasses) };
	drawerobj.disp(sysno).ylabel = 'Events [class]';
	drawerobj.disp(sysno).sfreq = Repository.RepEntries(Partindex).SFrq;
	drawerobj.disp(sysno).hideplot = false;
	drawerobj.disp(sysno).ylim = []; %[0 max(unique(viewlabels(:,4)))+1];
	drawerobj.disp(sysno).showlabels = false(1, size(Repository.Classlist,2));
	drawerobj.disp(sysno).showlabels(Repository.SyncClasses) = true;

	drawerobj.title = [ drawerobj.title '   SimSetID: ' SimSetID ];
end;

%keep('Partindex', 'SimSetID', 'viewlabels');
% clear thisTargetClasses SimSetID_List SpotType MergeClassSpec filename labellist;

fprintf('\n%s: SimSetID: %s  Total labels: %u', mfilename, SimSetID, size(viewlabels,1));
fprintf('\n%s: Labels loaded into ''viewlabels''', mfilename);
fprintf('\n');