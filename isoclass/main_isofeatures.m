% main_isofeatures
%
% Compute isolated features from segment list seglist and corresponding partoffsets.
% If seglist, partoffsets are not supplied, labels for the PIs will be used.
% 
% Copyright 2008 Oliver Amft

% requires
Partlist;
fidx;
FeatureString;
% DSSet;
% seglist
% partoffsets

VERSION = 'V006';
fprintf('\n%s: %s', mfilename, VERSION);

if ~exist('FeatureString', 'var'), error('Variable FeatureString not provided.'); end;
if ~exist('DSSet', 'var'), error('Variable DSSet not provided.'); end;
if ~exist('forcewrite', 'var'), forcewrite = false; end;
if ~exist('DoSave', 'var'), DoSave = true; end;
if ~exist('FeaturePathPriority', 'var'), FeaturePathPriority = '*'; end;  % >0: restrict location for feature files

% 	initmain;
% initmain has renumbered classes, this is not what we want for feature
% computation. In this way feature files are more generic.
[seglist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');
if isempty(thisTargetClasses),
	thisTargetClasses = TargetClasses;
	fprintf('\n%s: WARNING: seglist is empty! This happens when no valid labels were found in', mfilename);
	fprintf('\n%s: any PI of Partlist - usually a bogus config!  thisTargetClasses=%s', mfilename, mat2str(thisTargetClasses));
	warning('MATLAB:main_spotfeatures', 'All PIs must be available for spotting - to determine search depth.');
end;
% WARNING: Do not replace labellist here, this may break further scripts run subsequently to this one

% guess segmentation config for each class
% initmain_segconfig;

% feature computation
% fprintf('\n%s: Compute features for %u segments...', mfilename, size(seglist,1));
% fmatrix = fb_computefeatures(Repository, Partlist, FeatureString, DSSet, ...
%     seglist, partoffsets, 'fidx', fb_getelements(fidx,2), 'LabelConfThres', LabelConfThres);

fmatrix = [];  leftout = true;
for partnr = 1:length(Partlist)
	Partindex = Partlist(partnr);
	fprintf('\n%s: Process part %u...', mfilename, Partindex);

	SampleRate = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
	partsize = repos_getpartsize(Repository, Partindex);
	partseglist = repos_findlabelsforpart(seglist, partnr, partoffsets, 'remove');

	usesources = unique(fb_getsources(FeatureString));
	usesystems = unique(repos_getsysfromsensor(Repository, Partindex, usesources));

	% 	filename = dbfilename(Repository, 'prefix', 'ISOFeatures' , 'indices', Partindex, ...
	% 		'suffix', fb_getelements(fidx,2), 'subdir', Subject, 'globalpath', fullfile(Repository.Path, 'FEATURES'));
	filename = fb_findfeaturefile(Repository, Partindex, fidx, Subject, 'FeatureFileLocation', FeaturePathPriority, 'prefix', 'ISOFeatures');

	% Load only if relevant labels in part
	if isempty(partseglist)
		fprintf('\n%s: Part %u has no segments, skipping.', mfilename, Partindex); 
		leftout = true;  continue;
	end;

    % check if file exists, if so: skip
	if exist(filename,'file') && (forcewrite==false)
		partdata = load(filename, 'SaveTime', 'FullFeatureString');
		fprintf('\n%s: File %s exist and forcewrite not used, skipping.', mfilename, filename);
		fprintf('\n%s: Features:%u, Date: %s', mfilename, length(partdata.FullFeatureString), datestr(partdata.SaveTime) );

		fprintf('\n');	leftout = true;  continue;
	end;

	% set semaphore
    if ~exist('allsim_batchmode', 'var') || (allsim_batchmode==false)
        jobdesc = strrep(tasktitle,' ','_');
        semafilename = [filename '.processing.mat'];
        [success jobdesc_read] = semaphorefile(semafilename, jobdesc, 'operation', 'set', 'verbose', 0);
        if ~success
            leftout = true;
            fprintf('\n%s: File %s is under process at %s, skipping.', mfilename, filename, jobdesc_read);
            fprintf('\n');	continue;
        end;
    end;
    % now it should be save to proceed

	fprintf('\n%s:   Features file: %s.', mfilename, filename);

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
%     	[dummy flist] = makefeatures(testseg, DataStruct(i));
        [dummy flist] = makefeatures(testseg, DataStruct(i),job);
		FullFeatureString = { FullFeatureString{:} flist{:} };
	end;
	fprintf(' %u features.', length(FullFeatureString));
	
	
	% compute features
	fprintf('\n%s:   Compute %u features on %u labels...', mfilename, length(FullFeatureString), size(partseglist,1));
% 	fmatrix_part = makefeatures_fusion(partseglist, DataStruct);
    fmatrix_part = makefeatures_fusion(partseglist, DataStruct,job);
%gabriele add start
    if strcmpi(job, 'feature')
        fmatrix = [];
    end
%gabriele add end
	fmatrix = [fmatrix; fmatrix_part];
    

	% save, single Partindex
	if (DoSave)
		SaveTime = clock;
		fprintf('\n%s: Saving %s...', mfilename, filename);
% 		save(filename, 'SaveTime', 'VERSION', ...
% 			'fmatrix_part', 'FullFeatureString', ...
% 			'TargetClasses', 'thisTargetClasses', 'MergeClassSpec', 'FeatureString', ...
% 			'Partindex', 'Partlist', 'DSSet', 'partseglist', 'partsize', 'fidx');  % , 'aseglist'
%gabriele add start
        if strcmpi(job, 'feature')
            fmatrix_part_CONT = [fmatrix_part(:,1:2:end),fmatrix_part(:,end)];
            fmatrix_part = fmatrix_part(:,1:2:end);
            fmatrix = fmatrix(:,1:2:end);
            save(filename, 'SaveTime', 'VERSION', ...
                'fmatrix_part','fmatrix_part_CONT', 'FullFeatureString', ...
                'TargetClasses', 'thisTargetClasses', 'MergeClassSpec', 'FeatureString', ...
                'Partindex', 'Partlist', 'DSSet', 'partseglist', 'partsize', 'fidx');  % , 'aseglist'
        else
            save(filename, 'SaveTime', 'VERSION', ...
                'fmatrix_part', 'FullFeatureString', ...
                'TargetClasses', 'thisTargetClasses', 'MergeClassSpec', 'FeatureString', ...
                'Partindex', 'Partlist', 'DSSet', 'partseglist', 'partsize', 'fidx');  % , 'aseglist'
        end
%gabriele add end
    end;
    if ~exist('allsim_batchmode', 'var') || (allsim_batchmode==false)
        inprocess = semaphorefile(semafilename, jobdesc, 'operation', 'rm', 'verbose', 0);
        if ~inprocess, error('Something has interfered with the semaphore.'); end;
    end;

end; % for partnr

if (~leftout)
	if (size(fmatrix,1) ~= size(seglist,1)), error('\n%s: Features and seglist do not match.', mfilename); end;
else
	fprintf('\n%s: Left out some PIs that were marked to be in process somewhere else.', mfilename);
end;

fprintf('\n%s: Done.', mfilename);