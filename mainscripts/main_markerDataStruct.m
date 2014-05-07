% main_markerDataStruct.m
%
% MARKER launch script to view a DataStruct

% requires
DataStruct;
labellist;

initdata;
Classlist = Repository.Classlist;

clear drawerobj;

% configure title of the MARKER window, e.g. subjects name, optional
drawerobj.title = sprintf('%s', mfilename);

% printout label count
if exist('initlabels','var'), fprintf('\n%s: Found %u labels.', mfilename, size(initlabels,1)); end;
initlabels = segment_resample(labellist, DataStruct(1).BaseRate, DataStruct(1).SampleRate);

% setup marker display from FeatureSets
for sysno = 1:length(DataStruct)
	drawerobj.disp(sysno).data = DataStruct(sysno).Data;
	drawerobj.disp(sysno).ylabel = DataStruct(sysno).Name;
	drawerobj.disp(sysno).sfreq = DataStruct(sysno).SampleRate;
	drawerobj.disp(sysno).signalnames = DataStruct.DTable;
	
	drawerobj.disp(sysno).xvisible = drawerobj.disp(sysno).sfreq*10;
end;


% string cell array of names for the labels, optional
drawerobj.labelstrings = Classlist;

% maximum number of classes/label types, default: 1
drawerobj.maxLabelNum = length(drawerobj.labelstrings);

fprintf('\n%s: Launching Marker...', mfilename);
marker(drawerobj, initlabels);
