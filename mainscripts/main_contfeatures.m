% main_contfeatures
%
% Compute continuous features per window - DSSet.*.swsize; 
% 
% Copyright 2013 Marija Milenkovic, Oliver Amft
% 
% requires
Partlist;
fidx;

VERSION = 'V001';
fprintf('\n%s: %s', mfilename, VERSION);

if ~exist('FeatureString', 'var'), error('Variable FeatureString not provided.'); end;
if ~exist('DSSet', 'var'), error('Variable DSSet not provided.'); end;
if ~exist('MergeClassSpec', 'var'), error('Run initmain first.'); end;

if ~exist('forcewrite', 'var'), forcewrite = false; end;
if ~exist('DoSave', 'var'), DoSave = true; end;
if ~exist('FeatureFileLocation', 'var'), FeatureFileLocation = '*'; end;  % >0: restrict location for feature files
if ~exist('DoAlignment', 'var'), DoAlignment = true; end;  % align data according to Marker

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


fmatrix = [];  leftout = false;
for partnr = 1:length(Partlist)
	Partindex = Partlist(partnr);
	fprintf('\n%s: Process part %u...', mfilename, Partindex);

    filename = fb_findfeaturefile(Repository, Partindex, fidx,  'FeatureFileLocation', FeatureFileLocation, 'prefix', 'CONTFeatures');

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
	DataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet, 'Alignment', DoAlignment);
	partsize = fb_getdatasize(DataStruct);  % , 'SampleRate', SampleRate

	% determine FullFeatureString
	fprintf('\n%s:   Probe features names...', mfilename);
	FullFeatureString = {};
	for i = 1:length(DataStruct)
		testseg = segment_resample([1 DataStruct(i).swsize], DataStruct(i).BaseRate, DataStruct(i).SampleRate);
		[dummy flist] = makefeatures(testseg, DataStruct(i));
		FullFeatureString = { FullFeatureString{:} flist{:} };
	end;
	fprintf(' %u features.', length(FullFeatureString));

	% compute features
    for i = 1:length(DataStruct)
        fprintf('\n%s:   Compute %u features on %u instances for DataType %s...', mfilename, length(FullFeatureString), fb_getdatasize(DataStruct(i)), DataStruct(i).Name);
    end;
	fmatrix_part = makefeatures_fusion([1 inf], DataStruct);

	% save, single Partindex
    if (DoSave)
        SaveTime = clock;
        fprintf('\n%s: Saving %s...', mfilename, filename);
        save(filename, 'SaveTime', 'VERSION', ...
            'fmatrix_part', 'FullFeatureString', ...
            'TargetClasses', 'thisTargetClasses', 'MergeClassSpec', 'FeatureString', ...
            'Partindex', 'Partlist', 'DSSet', 'partsize', 'fidx');  % , 'aseglist'
    end;
    if ~exist('allsim_batchmode', 'var') || (allsim_batchmode==false)
        inprocess = semaphorefile(semafilename, jobdesc, 'operation', 'rm', 'verbose', 0);
        if ~inprocess, error('Something has interfered with the semaphore.'); end;
    end;

end; % for partnr

if leftout
    fprintf('\n%s: Left out some PIs that were marked to be in process somewhere else.', mfilename);
end;

fprintf('\n%s: Done.', mfilename);