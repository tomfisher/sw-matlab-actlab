% main_marker
%
% Spotting view examples:
% DisplayResult = 'spot'; SimSetID = 'HolgerGTSUIRAASCV2'; SpotType = 'SIMS'; thisTargetClasses = 2; Partindex = 95; main_marker;
% FilterScript = {'main_marker_spotviewlabels', 'main_marker_chewlabeling'}; SimSetID = 'AelC5R1'; SpotType = 'SIMS'; thisTargetClasses = 12; Partindex = 111; main_marker;
% DisplayResult='spot'; SimSetID = 'ClemensDrillAllTDMS3MVMW'; thisTargetClasses = 2; ReestimateThres = true; Partindex = 106; main_marker;
% DisplayResult='spot'; SpotType = 'SFCV'; SimSetID = 'ClemensDrillAllTDMS3MVCOMP'; thisTargetClasses = 2:4; MergeClassSpec = num2cell(2:4); Partindex = 106; main_marker
%
% Chew labeling view examples:
% DisplayResult = 'chewlabeling'; Partindex = 95; main_marker;
%
% requires:
Partindex;
% (StandardiseData)
% (FeatureLabeling)
% SimSetID;

initdata;
marker_ismodified = false;

% quick config of filter
% e.g.   DisplayResult = 'iso'
if ~exist('DisplayResult','var'), DisplayResult = []; end;

% additional scripts to execute
% main_marker_keylabels
% main_marker_spareplot
% main_marker_isoviewlabels
% main_marker_spotviewlabels
% main_marker_segpoints
if ~exist('FilterScript','var'), FilterScript = {}; end;

% really launch marker
if ~exist('DoLaunch','var'), DoLaunch = true; end;

% load spotting result
if ~isempty(DisplayResult) && ischar(DisplayResult)
	fprintf('\n%s: Configure results filter scripts...', mfilename);
	switch lower(DisplayResult)
		case 'iso'
			% requires: SimSetID
			SimSetID; % check whether sim id was set (required)
			FilterScript = {'main_marker_isoviewlabels'};
		case 'spot'
			% requires: SimSetID
			SimSetID; % check whether sim id was set (required)
			FilterScript = {'main_marker_spotviewlabels'};
		case 'seg'
			% requires:  SegConfig.Name, SegConfig.Mode
			FilterScript = {'main_marker_segpoints'};
		case 'altlabel'
			% requires: fidx, LabelVar
			FilterScript = {'main_marker_altlabels'};
		case 'chewlabeling'
			% requires: -
			FilterScript = {'main_marker_chewlabeling'};
		otherwise
			error('DisplayResult setting not supported.');
	end;
end;


% determine datafile for display (MARKER datafile)
features_filename = '';
% look in current directory
if ~exist(features_filename, 'file')
	features_filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'globalpath', '');
end;
% look in DATA/MARKERDATA subdir of current directory
if ~exist(features_filename, 'file')
	features_filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'subdir', 'MARKERDATA');
end;
% look in MARKERDATA subdir of global repository directory
if ~exist(features_filename, 'file')
	features_filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'subdir', 'MARKERDATA', 'globalpath', Repository.Path);
end;
% look in <dataset>/MARKERDATA subdir of global repository directory
if ~exist(features_filename, 'file')
    features_filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'subdir', repos_getfield(Repository, Partindex, 'Dir'), 'globalpath', Repository.Path);
end;




% loading view data
clear FeatureSet partsize SysFeatureString datasps;
if ~exist(features_filename, 'file')
	% if features file was not found, try loading raw data
	fprintf('\n%s: MARKERDATA not found. Loading raw data => repos_prepdata()...', mfilename);
	usesystems = repos_getsystems(Repository, Partindex);

	for sys = 1:length(usesystems)
		[FeatureSet{sys}, loadedDTable datasps(sys)] = repos_prepdata(Repository, Partindex, usesystems{sys}, ...
			'SampleRate', repos_getfield(Repository, Partindex, 'SFrq', usesystems{sys}), 'alignment', false);

		% remove columns not requested by Repository.MarkerSignals
		if isfield(Repository, 'MarkerSignals')
			FeatureSet{sys} = FeatureSet{sys}(:,cellstrmatch(Repository.MarkerSignals, loadedDTable, '', 'ReturnZeros', false));
		end;
		partsize(sys) = length(FeatureSet{sys});

		%SysFeatureString{sys} = repos_getdtable(Repository, Partindex, usesystems{sys});
        SysFeatureString{sys} = loadedDTable;
	end;

	% check that there is one data rate only
	if length(unique(datasps))>1
		error('Data has more than one data rate. This is not supported.');
	end;
	datasps = datasps(1);

else
	% loading from prepocessed (main_prepmarker.m)
	fprintf('\n%s: Loading Marker feature data...', mfilename);
	load(features_filename, 'FeatureSet', 'partsize', 'newsps');
	
	if isempty(FeatureSet)
		fprintf('\n%s: Display feature file(s) not found at: %s', mfilename, features_filename);
		fprintf('\n');
		return;
	end;
	datasps = newsps;
	
	if ~isempty(lsmatfile(features_filename, 'SysFeatureString'))
		load(features_filename, 'SysFeatureString');
	else
		SysFeatureString = cell(1, length(FeatureSet));
		%strtok(FeatureString(signr:signr+size(drawerobj.disp(splot).data,2)-1), '_');
	end;
end;

if (datasps ~= repos_getfield(Repository, Partindex, 'SFrq'))
	error('Mismatch in data rate settings: Data and repos differs.');
end;


% optionally standardise features
if test('StandardiseData') && (StandardiseData)
	fprintf('\n%s: Standardise features...', mfilename);
	for splot = 1:length(allsystems)
		FeatureSet{splot} = zscore(FeatureSet{splot});
	end;
end;


% load allSegLabels
% adapt begin of data (data alignment)
[alignshift alignsps alignrate plottypes found] = repos_getalignment(Repository, Partindex);


% fetch initlabels, labelsps
initlabels = repos_getlabellist(Repository, Partindex);
if isempty(initlabels)
	fprintf('\n%s: Trying ''Keylabel''...', mfilename);
	[initlabels labelcomments] = getkeylabels(Repository, Partindex);
    if ~isempty(initlabels)
        fprintf(' found %u keylabels.', size(initlabels,1));
        marker_ismodified = true;
    else
        fprintf(' nothing found.');        
    end;
end;
if ~isempty(initlabels)
	fprintf('\n%s: Found %u labels.', mfilename, size(initlabels,1));
end;

labelsps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
if (labelsps ~= datasps) && (~isempty(initlabels))
	fprintf('\n%s: WARNING: Sampling rate of labels (%uHz) and data (%uHz) differs, correcting labels.', ...
		mfilename, labelsps, datasps);

	initlabels = segment_resample(initlabels, labelsps, datasps, 'segmentmode', true);
end;



% setup marker drawerobj
allsystems = repos_getsystems(Repository, Partindex);
clear drawerobj;
drawerobj.maxLabelNum = size(Repository.Classlist,2);
drawerobj.labelstrings = Repository.Classlist;
drawerobj.locklabels = isemptycell(Repository.Classlist);


for splot = 1:length(allsystems)
	thissys = allsystems{splot};

	drawerobj.disp(splot).type = thissys;
	drawerobj.disp(splot).data = FeatureSet{splot};
	drawerobj.disp(splot).plotfunc = @plot;
	drawerobj.disp(splot).ylabel = [thissys ' [amp.]'];
	drawerobj.disp(splot).alignshift = alignshift(splot);
	drawerobj.disp(splot).alignsps = alignsps(splot);
	drawerobj.disp(splot).datasize = partsize(splot);
	%drawerobj.disp(splot).sfreq = repos_getfield(Repository, Partindex, 'SFrq', thissys);
	drawerobj.disp(splot).sfreq = datasps;
	drawerobj.disp(splot).xvisible = drawerobj.disp(splot).sfreq*40;
	drawerobj.disp(splot).signalnames = fb_getsources(SysFeatureString{splot});
	
	%drawerobj.disp(splot).signalnames = strtok(SysFeatureString(signr:signr+size(drawerobj.disp(splot).data,2)-1), '_');
	%signr = signr + size(drawerobj.disp(splot).data,2);
end; % for splot


% config label display
for splot = 1:length(drawerobj.disp)
	drawerobj.disp(splot).showlabels = false(1, size(Repository.Classlist,2));

	% hack for non-fusion data sets
	if (~isfield(Repository, 'GestureClasses'))
		drawerobj.disp(splot).showlabels = true(1, size(Repository.Classlist,2));
		continue;
	end;

    if isfield(Repository, 'SyncClasses'), drawerobj.disp(splot).showlabels(Repository.SyncClasses) = true; end;

	switch upper(drawerobj.disp(splot).type)
		case { 'XSENS', 'CRNT_XSENS' }
			drawerobj.disp(splot).showlabels(Repository.GestureClasses) = true;
			drawerobj.disp(splot).showlabels(Repository.MiscClasses) = true;
			drawerobj.disp(splot).showlabels(Repository.SeqClasses) = true;
		case 'WAV'
			try drawerobj.disp(splot).showlabels(Repository.ChewClasses) = true; catch end;
			try drawerobj.disp(splot).showlabels(Repository.SwallowClasses) = true; catch end;
		case 'EMG'
			drawerobj.disp(splot).showlabels(Repository.ChewClasses) = true;
			drawerobj.disp(splot).showlabels(Repository.SwallowClasses) = true;
			drawerobj.disp(splot).showlabels(Repository.SeqClasses) = true;			
		case 'SCALES'
			drawerobj.disp(splot).showlabels(Repository.GestureClasses) = true;
			drawerobj.disp(splot).showlabels(Repository.ScalesClasses) = true;

		case 'LABELING'
			%drawerobj.disp(splot).showlabels = true(1, size(Repository.Classlist,2));
	end;
end;


% config signal display
for splot = 1:length(drawerobj.disp)

	% hack for non-fusion data sets
	if (~isfield(Repository, 'GestureClasses')), break;	end;

	showsignals = true(1, size(FeatureSet{splot},2));
	switch upper(drawerobj.disp(splot).type)
		case 'XSENS'
			showsignals = false(1, size(FeatureSet{splot},2));
			showsignals([ ...
				strmatch('RLAphi', SysFeatureString{splot}) strmatch('RLAtheta', SysFeatureString{splot}) strmatch('RLApsi', SysFeatureString{splot}) ...
				strmatch('LLAphi', SysFeatureString{splot}) strmatch('LLAtheta', SysFeatureString{splot}) strmatch('LLApsi', SysFeatureString{splot}) ...
				]) = true;
% 			showsignals([ ...
% 				strmatch('RLAacc', SysFeatureString{splot}) strmatch('LLAacc', SysFeatureString{splot}) ]) = true;
	end;

	drawerobj.disp(splot).hidesignal = ~showsignals;
end; % signal display


% config player information
for splot = 1:length(drawerobj.disp)
	switch upper(drawerobj.disp(splot).type)
		case 'XSENS'
			player = 1;  % player set 1
			%drawerobj.disp(splot).playerdata(player).playerfun = @marker_player_playmotion;
			drawerobj.disp(splot).playerdata(player).playerfun = @marker_player_playnancy;
			drawerobj.disp(splot).playerdata(player).title = 'Play motion (XSENS)';

			drawerobj.disp(splot).playerdata(player).Repository = Repository;
			drawerobj.disp(splot).playerdata(player).Partindex = Partindex;

		case 'WAV'
			WAVFile = repos_getfilename(Repository, Partindex, 'WAV');

			player = 1;  % player set 1
			drawerobj.disp(splot).playerdata(player).playerfun = @marker_player_playsound;
			drawerobj.disp(splot).playerdata(player).title = 'Play IEAR';
			channel = repos_findassoc(Repository, Partindex, 'IEAR', 'WAV');
			drawerobj.disp(splot).playerdata(player).file = WAVFile;
			drawerobj.disp(splot).playerdata(player).channel = channel;
			drawerobj.disp(splot).playerdata(player).gain = 1.3;

			player = 2;  % player set 2
			drawerobj.disp(splot).playerdata(player).playerfun = @marker_player_viewsound;
			drawerobj.disp(splot).playerdata(player).title = 'View active ch';
			drawerobj.disp(splot).playerdata(player).file = WAVFile;
			drawerobj.disp(splot).playerdata(player).exportvar = 'markerwavdata';

			player = 3;  % player set 3
			drawerobj.disp(splot).playerdata(player).playerfun = @marker_player_playsound;
			drawerobj.disp(splot).playerdata(player).title = 'Play SMIC';
			channel = repos_findassoc(Repository, Partindex, 'SMIC', 'WAV');
			drawerobj.disp(splot).playerdata(player).file = WAVFile;
			drawerobj.disp(splot).playerdata(player).channel = channel;
			drawerobj.disp(splot).playerdata(player).gain = 1;

			player = 4;
			drawerobj.disp(splot).playerdata(player).playerfun = @marker_player_playsound;
			drawerobj.disp(splot).playerdata(player).title = 'Play ACC';
			channel = repos_findassoc(Repository, Partindex, 'ACC', 'WAV');
			drawerobj.disp(splot).playerdata(player).file = WAVFile;
			drawerobj.disp(splot).playerdata(player).channel = channel;
			drawerobj.disp(splot).playerdata(player).gain = 1;
	end;
end; % for splot


% drawerobj.consolemenus = true;
drawerobj.askbeforequit = false;
drawerobj.defaultsavetype = 1;
drawerobj.ismodified = marker_ismodified;

[fdir fname fext] = fileparts(repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKER', 'subdir', 'labels'));
drawerobj.iofilename = [fname fext];
drawerobj.defaultDir = fdir;

if ~isempty(FilterScript)
	drawerobj.title = sprintf('Part: %3u, Subject: %s, FilterScript: %s', ...
		Partindex, repos_getfield(Repository, Partindex, 'Subject'), cell2str(FilterScript));
else
	drawerobj.title = sprintf('Part: %3u, Subject: %s', Partindex, repos_getfield(Repository, Partindex, 'Subject'));
% 	drawerobj.title = sprintf('Part: %3u, Subject: %s', Partindex, 'XXX');
end;


% run a script to post-filter the drawerobj settings for specific views
if ~isempty(FilterScript)
	for i = 1:length(FilterScript)
		fprintf('\n%s: Run FilterScript %s...', mfilename, FilterScript{i});
		if ~test(FilterScript{i})
			fprintf('\n');
			fprintf('\n%s: Script failed:', mfilename);
			errorprinter(lasterror, 'MsgOffset', -1, 'DoWriteFile', false);
			countdown(4, 'premsg', 'Launching Marker in');
		else
			fprintf('\n%s: Script %s completed.', mfilename, FilterScript{i});
		end;
	end;
end;

if (DoLaunch)
	fprintf('\n%s: Launching Marker...', mfilename);
	marker(drawerobj, initlabels);
	clear initlabels ;
end;
