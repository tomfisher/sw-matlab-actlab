% main_isofanalysis
% 
% Perform feature selection

% requires
Partlist;
fidx;
SimSetID;
TargetClasses;
FeatureString;
DSSet;

VERSION = '001';
fprintf('\n%s: %s', mfilename, VERSION);


if (~exist('DoLoad', 'var')), DoLoad = true; end;   % load/compute features
if (~exist('DoNorm', 'var')), DoNorm = true; end;  % normalise features
if (~exist('FSelMethod', 'var')), FSelMethod = 'none'; end;  % perform feature selection
if (~exist('DoSave', 'var')), DoSave = true; end;   % save result


% initmain;    % should be run independently
% these parameters are needed:
% thisTargetClasses, MergeClassSpec, labellist, partoffsets
labellist;

% description of feature strings
% FeatureString - Features requested for inclusion in eval (manual selection) 
% fm_FeatureString_load - computed and expanded feature string BEFORE manual selection 
% fm_FeatureString - computed and expanded feature string AFTER manual selection
% FilteredFeatureString - Features AFTER automatic feature selection stage

% ------------------------------------------------------------------------
% 0. comination of features
% ------------------------------------------------------------------------
if (DoLoad)
    fprintf('\n%s: Process features...', mfilename);
	
	% load precomputed features
    [fmatrix found fm_seglist fm_partoffsets fm_FeatureString] = fb_loadfeatures(Repository, Partlist, 'fidx', fb_getelements(fidx,2));

	if (found)
		% adapt seglist, fmatrix to MergeClassSpec class settings (remove labels only!)
		fprintf('\n%s:   Adapt seglist to MergeClassSpec...', mfilename);
		[seglist thisTargetClasses removed] = segment_classfilter(MergeClassSpec, fm_seglist);
		fmatrix(removed, :) = []; % remove observations that are not in spec
		fprintf(' %u removed', length(find(removed>0)));
        
        % adapt seglist, fmatrix to labellist settings (remove labels only!)
		fprintf('\n%s:   Adapt seglist to labellist...', mfilename);
        removed = ~segment_findequals(seglist, labellist);
		seglist(removed, :) = []; fmatrix(removed, :) = [];
		fprintf(' %u removed', length(find(removed>0)));
		
		
		% adapt features to FeatureString
		usedfeatures = false(1, length(fm_FeatureString));
		for f = 1:length(FeatureString)
			usedfeatures(strmatch(FeatureString{f}, fm_FeatureString)) = true;
		end;
 		fmatrix(:,~usedfeatures) = []; % remove columns that are not requested
        fm_FeatureString_load = fm_FeatureString;
		fm_FeatureString(~usedfeatures) = [];
        fprintf('\n%s:   Selected %u of %u available features.', mfilename, length(fm_FeatureString), length(fm_FeatureString_load));
	else
		% compute features here
		seglist = labellist;
		[fmatrix fm_FeatureString] = fb_computefeatures(Repository, Partlist, ...
			FeatureString, DSSet, seglist, partoffsets, ...
			'SaveFeatures', false);
	end;
end;


% check that label list and features match (crude)
if isempty(fmatrix)
	error('Feature matrix is empty.');
end;
if ( size(seglist,1) ~= size(fmatrix,1) )
	error('Segment list and feature matrix do not match.');
end;
if ( length(fm_FeatureString) ~= size(fmatrix,2) )
	error('Feature list and feature matrix do not match.');
end;
if ( ~all(findn(1:length(thisTargetClasses), unique(seglist(:,4)))) )
	error('Some classes have no observations.'); 
end;

novarfeatures = fm_FeatureString(var(nfm_all) == 0);
if ~isempty(novarfeatures)
	fprintf('\n%s: Zero variance features: Columns: %s', mfilename, mat2str(find(var(nfm_all) == 0)));
	fprintf('\n%s: Zero variance features: Names: %s (%s)', mfilename, cell2str(novarfeatures, ', '));
end;


% ------------------------------------------------------------------------
% Clustering
% ------------------------------------------------------------------------

fprintf('\n%s: Perform clustering...', mfilename);

% clip and standardise features: nfm_train (nfm_means nfm_stds)
if (DoNorm)
	[nfm_all clipvals] = mclipping(fmatrix, 'sdlimit', 5);
	[nfm_all nfm_means nfm_stds] = mstandardise(nfm_all);
else
	fprintf('\n%s:   *** Do NOT normalise.', mfilename);
	nfm_all = fmatrix;
end;


% perform feature selection
fprintf('\n%s:   Features matrix: %s', mfilename, mat2str(size(nfm_all)));
fprintf('\n%s:   Feature selection: %s...', mfilename, FSelMethod);
switch FSelMethod
	case 'CORR'
		fweighting = corrcoef(nfm_all);
		FilteredFeatureString = fm_FeatureString;

	case 'PHASECORR'
		% requires:
		SeqLabels;  % sequence number ids
		PhaseSplit;  % splitting of sequence
		seqlabellist = []; fm1 = []; fm2 = [];
		for seqid = 1:length(SeqLabels)
			thisseqlabels = segment_findlabelsforclass(labellist_load, SeqLabels(seqid));

			for label = 1:size(thisseqlabels,1)
				relevantlabels = segment_findincluded(thisseqlabels(label,:), seglist);
				
				% split in 2 equal chunks
				fm1 = [ fm1; nfm_all(relevantlabels(1:round(size(relevantlabels,1)*PhaseSplit), :), :) ];
				fm2 = [ fm1; nfm_all(relevantlabels(round(size(relevantlabels,1)*PhaseSplit)+1:end, :), :) ];
			end; % for label
		end; % for seqid

		minsize = min([size(fm1,1) size(fm2,1)]);
		fweighting = corrcoef([fm1(1:minsize,:) fm2(1:minsize,:)]);

		
end;


		
	
% SAVE
if (DoSave)
    SaveTime = clock;
    classisox_filename = dbfilename(Repository, 'prefix', 'ISOFANA', 'suffix', SimSetID, 'subdir', 'ISO');
    fprintf('\n%s:   Save %s...', mfilename, classisox_filename);
    save(classisox_filename, ...
		'fweighting', ...
        'TargetClasses', 'Classlist', 'FeatureString', 'FilteredFeatureString', 'fm_FeatureString', ...
        'seglist', 'MergeClassSpec', 'Partlist', 'DSSet', ...
        'StartTime', 'SaveTime');
    fprintf('done.\n');
end;
