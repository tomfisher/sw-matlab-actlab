function [fmatrix FullFeatureString] = fb_computefeatures(Repository, Partlist, FeatureString, DSSet, seglist, partoffsets, varargin)
% function [fmatrix FullFeatureString] = fb_computefeatures(Repository, Partlist, FeatureString, DSSet, seglist, partoffsets, varargin)
%
% Compute one-valued features for given informations, uses makedatastruct()
% and makefeatures_fusion(). If features have been computed before, use
% this when LoadFeatures=true, otherwise compute anew. Parameter seglist should be
% supplied at default SampleRate since makefeatures_fusion() is used.
%
% Optional parameters:
% Alignment         repos_prepdata() data alignment parameter; bool, default=true
% PartFiles         Save/Load a file for each Partindex; default=true
% fidx              Filename suffix for feature files; default='test'
% IgnoreFileVersion Disable feature file version checking; bool, default=false
%
% For more parameters, see source code. See also: fb_loadfeatures.m

% OAM REVISIT: Do seglist comparison before loading!

fmatrix = []; FullFeatureString = {};

[Alignment aseglist SaveFeatures PartFiles GlobalPath FeatureDir ...
	fidx verbose] = process_options(varargin, ...
	'Alignment', true, 'aseglist', [], 'SaveFeatures', true, ...
	'PartFiles', true, 'GlobalPath', 'DATA', 'FeatureDir', 'FEATURES', ...
	'fidx', 'test', 'verbose', 1);

VERSION = '001';
if (verbose), fprintf('\n%s: %s', mfilename, VERSION); end;



% load data, compute features
for partno = 1:length(Partlist)
	Partindex = Partlist(partno);
	partsize = partoffsets(partno+1)-partoffsets(partno);
	partseglist = repos_findlabelsforpart(seglist, partno, partoffsets, 'remove');
	if (verbose), fprintf('\n%s: Process part %u...', mfilename, Partindex); end;

	% Load only if relevant labels in part
	if isempty(partseglist)
		if (verbose), fprintf('\n%s: Part %u has no segments, skipping.', mfilename, Partindex); end;
		continue;
	end;


	% compute features anew
	if (verbose), fprintf('\n%s:   Create DataStruct...', mfilename); end;
	DataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet, 'Alignment', Alignment);


	% adapt segmentation list to sampling rate of the data when potentially
	% used as a feature by makefeatures.
	if (verbose), fprintf('\n%s:   Load segmentation for feature support...', mfilename); end;	
	SampleRate = cla_getmarkersps(Repository, Partindex, 'singlesps', true);
	if ~isempty(aseglist)
		aseglist = segment_resample(aseglist, SampleRate, DataStruct.SampleRate);
		DataStruct = fb_modifydatastruct(DataStruct, 'seglist', aseglist);
	end;

	
	% compute features
	if (verbose), fprintf('\n%s:   Compute features...', mfilename); end;
	fmatrix_part = makefeatures_fusion(partseglist, DataStruct);
	fmatrix = [fmatrix; fmatrix_part];


	% determine FullFeatureString
	%FullFeatureString = cell(1, size(fmatrix,2));
	if (verbose), fprintf('\n%s:   Probe features names...', mfilename); end;	
	FullFeatureString = {};
	for i = 1:length(DataStruct)
		testseg = segment_resample(partseglist(1,:), DataStruct(i).BaseRate, DataStruct(i).SampleRate);
		[dummy flist] = makefeatures(testseg, DataStruct(i));
		FullFeatureString = {FullFeatureString{:} flist{:}};
	end;
	if (verbose), fprintf(' %u features.', length(FullFeatureString)); end;
	
	% save, single Partindex
	if (PartFiles==true) && (SaveFeatures==true)
		SaveTime = clock;
		filename = dbfilename(Repository, 'prefix', 'Features', 'indices', Partindex, 'suffix', fidx, 'subdir', FeatureDir, 'GlobalPath', GlobalPath);
		if (verbose), fprintf('\n%s: Save features to %s...', mfilename, filename); end;
		save(filename, 'SaveTime', 'VERSION', ...
			'fmatrix_part', 'FullFeatureString', ...
			'Partindex', 'FeatureString', 'DSSet', 'partseglist', 'partsize', 'fidx', 'aseglist');
	end;
end; % for partno



% save, entire fmatrix
if (PartFiles==false) && (SaveFeatures==true)
	SaveTime = clock;
	filename = dbfilename(Repository, 'prefix', 'Features', 'indices', Partlist, 'suffix', fidx, 'subdir', FeatureDir, 'GlobalPath', GlobalPath);
	if (verbose), fprintf('\n%s: Save features to %s...', mfilename, filename); end;
	save(filename, 'SaveTime', 'VERSION', ...
		'fmatrix', 'FullFeatureString', ...
		'Partlist', 'FeatureString', 'DSSet', 'seglist', 'partoffsets', 'fidx', 'aseglist');
end;
