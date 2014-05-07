% main_getdatafromdb
%
% 
% Copyright 2009 Oliver Amft

% requires
Partlist;
FeatureString;
DSSet;


VERSION = 'V001';
fprintf('\n%s: %s', mfilename, VERSION);

if ~exist('FeatureString', 'var'), error('Variable FeatureString not provided.'); end;
if ~exist('DSSet', 'var'), error('Variable DSSet not provided.'); end;
if ~exist('forcewrite', 'var'), forcewrite = false; end;
if ~exist('DoSave', 'var'), DoSave = true; end;
if ~exist('FeaturePathPriority', 'var'), FeaturePathPriority = 0; end;  % >0: restrict location for feature files


% guess segmentation config for each class
% initmain_segconfig;


fmatrix = [];  
for partnr = 1:length(Partlist)
	Partindex = Partlist(partnr);
	fprintf('\n%s: Process part %u...', mfilename, Partindex);

	SampleRate = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
	partsize = repos_getpartsize(Repository, Partindex);
	partseglist = repos_findlabelsforpart(labellist, partnr, partoffsets, 'remove');

	usesources = unique(fb_getsources(FeatureString));
	usesystems = unique(repos_getsysfromsensor(Repository, Partindex, usesources));

	% Load only if relevant labels in part
	if isempty(partseglist)
		fprintf('\n%s: Part %u has no segments, skipping.', mfilename, Partindex); 
		continue;
	end;


	% create data struct (load data), once for Partindex only
	DataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet);
	actualpartsize = fb_getdatasize(DataStruct, 'SampleRate', SampleRate);
	doload = false;  % not need to load anymore for other classes (this PI)



	% search segmentation list for current PI
% 	thisSegConfig = SegConfig(classnr);
% 	aseglist = cla_getsegmentation(Repository, Partindex, 'SampleRate', SampleRate, ...
% 		'SegType', thisSegConfig.Name, 'SegMode', thisSegConfig.Mode);
% 	aseglist(aseglist(:,2)>min(actualpartsize),:) = []; % omit last (may exceed data size)
% 	aseglist(end,:) = [aseglist(end,1) min(actualpartsize)];
% 
%     DataStruct(1).seglist = [];  % required to make struct compatible with subsequent operation
%     for i = 1:length(DataStruct)
%         DataStruct(i) = fb_modifydatastruct(DataStruct(i), ...
%             'seglist', segment_resample(aseglist, SampleRate, DataStruct(i).SampleRate));
%     end;


	% determine FullFeatureString
	fprintf('\n%s:   Probe features names...', mfilename);
	FullFeatureString = {};
	for i = 1:length(DataStruct)
		testseg = segment_resample(partseglist(1,:), DataStruct(i).BaseRate, DataStruct(i).SampleRate);
		[dummy flist] = makefeatures(testseg, DataStruct(i));
		FullFeatureString = { FullFeatureString{:} flist{:} };
	end;
	fprintf(' %u features.', length(FullFeatureString));
	
	
	% compute features
	fprintf('\n%s:   Compute %u features on %u labels...', mfilename, length(FullFeatureString), size(partseglist,1));
	fmatrix_part = makefeatures_fusion(partseglist, DataStruct);
	fmatrix = [fmatrix; fmatrix_part];
end; % for partnr


% save, single Partindex
if (DoSave)
	filename = fb_findfeaturefile(Repository, [], fidx, '');

    SaveTime = clock;
    fprintf('\n%s: Saving %s...', mfilename, filename);
    save(filename, 'fmatrix' );
%     'SaveTime', 'VERSION', 
%     'FullFeatureString', ...
%         'TargetClasses', 'MergeClassSpec', 'FeatureString', ...
%         'Partindex', 'Partlist', 'DSSet', 'partseglist', 'partsize', 'fidx', 'aseglist');
end;

fprintf('\n%s: Done.', mfilename);


if 0
    fh = figure;
    bins=50; channel = 3;
    
    hist(fmatrix_Standing(:,channel),bins); 
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','k');
    hold on; hist(fmatrix_Sitting(:,channel),bins);
    
    plotfmt(fh, 'prpdf', 'HistExampleSSPEx3');
end;

