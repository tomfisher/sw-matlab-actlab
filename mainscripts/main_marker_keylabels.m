% main_marker_keylabels
%
% Load keylabels for Marker display

% requires
Partindex;

if (marker_version('vernr') < 903), error('Script %s requires Marker version 903 or greater', mfilename); end;


% get labeling
[keylabels labelcomments] = getkeylabels(Repository, Partindex);
clakeylabels = segments2classlabels(size(Repository.Classlist,2), keylabels);

FeatureLabeling = [];
for i = 1:length(clakeylabels)
	FeatureLabeling(:,i) = segments2labeling(clakeylabels{i}, max(keylabels(:,2)));
end;
if (~test('FeatureLabelingNames'))
	FeatureLabelingNames = Repository.Classlist;
end;


if (~isempty(FeatureLabelingNames)) && (~isempty(FeatureLabeling))
	sysno = length(drawerobj.disp)+1;
	drawerobj.disp(sysno).type = 'Labeling';
	drawerobj.disp(sysno).save = false;
	drawerobj.disp(sysno).data = FeatureLabeling;
	drawerobj.disp(sysno).plotfunc = @marker_plotlabeling;
	drawerobj.disp(sysno).plotfunc_params = {size(drawerobj.disp(sysno).data,2)};
	drawerobj.disp(sysno).ylabel = [drawerobj.disp(sysno).type ' [classes]'];
	drawerobj.disp(sysno).datasize = size(drawerobj.disp(sysno).data,1);
	%drawerobj.disp(sysno).sfreq = cla_getmarkersps(Repository, Partindex, 'singlesps', true); %repos_getfield(Repository, Partindex, 'SFrq');
	drawerobj.disp(sysno).sfreq = datasps;
	drawerobj.disp(sysno).xvisible = drawerobj.disp(sysno).sfreq*40;
	drawerobj.disp(sysno).ylim = [0 size(drawerobj.disp(sysno).data,2)+1];
	drawerobj.disp(sysno).signalnames = FeatureLabelingNames;

	%drawerobj.disp(sysno).hideplot = true;
end;
