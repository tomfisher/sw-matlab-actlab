% main_marker_segpoints
%
% Prepare segmentation results for Marker display

% requires
Partindex;

SegConfig;
% SegConfig.Name = 'SWAB';
% SegConfig.Mode = 'RLAaccx_value';


% FeatureSet to use as basis for plot (loaded by main_marker.m)
% Signal to use as basis for plot
FeatureSet;
if (~exist('UseFeatureSet','var')), UseFeatureSet = 1; end;
if (~exist('UseSignal','var'))
	%UseSignal = repos_findassoc(Repository, Partindex, fb_getelements(SegConfig.Mode,1)); 
	UseSignal = strmatch(fb_getelements(SegConfig.Mode,1), Repository.MarkerSignals);
end;

% requires Marker version 0.9.3
if (marker_version('vernr') < 903), error('Script %s requires Marker version 903 or greater', mfilename); end;

initdata;

% load segmentation
fprintf('\n%s: Load segmentation %s, %s.', mfilename, SegConfig.Name, SegConfig.Mode);
seglist = cla_getsegmentation(Repository, Partindex, 'SegType', SegConfig.Name, 'SegMode', SegConfig.Mode, 'Samplerate', datasps);
% filename = dbfilename(Repository, 'indices', Partindex, 'prefix', SegConfig.Name, 'suffix', SegConfig.Mode, 'subdir', 'SEG');
% load(filename, 'seglist', 'segsps');
fprintf('\n%s: Segmentation stats:', mfilename);
fprintf('\n%s:   total segs: %u', mfilename, size(seglist,1));
fprintf('\n%s:   largest: %u,  smallest: %u,  smaller than 3sa: %u', mfilename, ...
	max(segment_size(seglist)), min(segment_size(seglist)), sum(segment_size(seglist)<3));


% configure disp
if (~isempty(seglist))
	sysno = length(drawerobj.disp)+1;
	drawerobj.disp(sysno).type = 'Segments2';
	drawerobj.disp(sysno).save = false;
	drawerobj.disp(sysno).data = FeatureSet{UseFeatureSet}(:,UseSignal);
	drawerobj.disp(sysno).alignshift = alignshift(UseFeatureSet);
	drawerobj.disp(sysno).alignsps = alignsps(UseFeatureSet);

	
	drawerobj.disp(sysno).plotfunc = @marker_plotsegmentation;
	drawerobj.disp(sysno).plotfunc_params = { seglist };
	drawerobj.disp(sysno).plotfunc_extmode = true;
	drawerobj.disp(sysno).ylabel = [ SegConfig.Name ' - ' fb_getelements(SegConfig.Mode,1) ];
	drawerobj.disp(sysno).sfreq = Repository.RepEntries(Partindex).SFrq;
	drawerobj.disp(sysno).hideplot = false;
	drawerobj.disp(sysno).ylim = []; %[0 max(unique(viewlabels(:,4)))+1];
end;

fprintf('\n%s: Segmentation result loaded and display configured.', mfilename);
fprintf('\n');