% main_isoclustering
% 
% Perform clustering of features

% requires
Partlist;
fidx;
SimSetID;
TargetClasses;
FeatureString;
DSSet;

VERSION = '001';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if (~exist('ClusteringMethod', 'var')) 
    ClusteringMethod = 'Hierarchical'; ClusteringParams = {'euclidean', 'ward'};
end;

if (~exist('DoLoad', 'var')), DoLoad = true; end;   % load/compute features
if (~exist('DoNorm', 'var')), DoNorm = true; end;  % normalise features
if (~exist('FSelMethod', 'var')), FSelMethod = 'none'; end;  % perform feature selection
if (~exist('DoSave', 'var')), DoSave = true; end;   % save result
if (~exist('DoEqualize', 'var')), DoEqualize = true; end;   % use eual number of observations


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


% ------------------------------------------------------------------------
% Clustering
% ------------------------------------------------------------------------


if (DoEqualize)
	% use equal number of observations
	labelcount = zeros(1, length(thisTargetClasses));
	for class = 1:length(thisTargetClasses)
		labelcount(class) = sum(seglist(:,4) == class);
	end;

	[minclasslabels minclass] = min(labelcount);
	fprintf('\n%s:   Minimal observation size: %u (from class %u).', mfilename, minclasslabels, thisTargetClasses(minclass));

	% remove observations
	for class = 1:length(thisTargetClasses)
		minseglist = segment_findlabelsforclass(seglist, class);
		if (size(minseglist,1) <= minclasslabels), continue; end;
		rmsegs = minseglist( minclasslabels+1:labelcount(class), : );
		
		removed = segment_findequals(seglist, rmsegs);
		seglist(removed, :) = [];
		fmatrix(removed, :) = [];
	end;
end;


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
% OAM REVISIT: integrate fsel toolbox here
switch FSelMethod
	case 'LDA'
		fweighting = LDA(nfm_all, seglist(:,4));
		[FilteredFeatureString(1:size(fweighting,2))] = deal({'LDA'});
	case 'PCA'
		%fweighting=pca_kpm(nfm_train', length(thisTargetClasses)-1, 1);
		fweighting = PCA(nfm_all, 'nrcomps', length(thisTargetClasses)-1);
		[FilteredFeatureString(1:size(fweighting,2))] = deal({'PCA'});
	case 'WMPCA'
		%wmspca
	case 'PPCA'
		%ppca
	otherwise
		fweighting = diag(ones(size(nfm_all,2),1));
		FilteredFeatureString = fm_FeatureString;
end;
ffm_all = nfm_all * fweighting;



labelcount = zeros(1, length(thisTargetClasses));
for class = 1:length(thisTargetClasses)
	labelcount(class) = sum(seglist(:,4) == class);
end;
fprintf('\n%s:   Objects for clustering : %s', mfilename, mat2str(labelcount));


% perform clustering
fprintf('\n%s: Perform clustering...', mfilename);
fprintf('\n%s:   Features for clustering: %u', mfilename, size(ffm_all,2));
fprintf('\n%s:   Objects for clustering : %u', mfilename, size(ffm_all,1));
fprintf('\n%s:   Run clustering %s (%s)...', mfilename, ClusteringMethod, cell2str(ClusteringParams,','));
switch lower(ClusteringMethod)
	case {'hierarchical'}
		fprintf('pdist...'); fm_dist = pdist(ffm_all, ClusteringParams{1}); % distance vector
		fprintf('linkage...'); ClusteringResults.link = linkage(fm_dist, ClusteringParams{2}); % clustering
		%fprintf('cluster...'); ClusteringResults.cluster = cluster(ClusteringResults.link); %, 'MaxClust', DesiredClusters); % generating clusters
	case 'manova1'
		[ClusteringResults.d ClusteringResults.p ClusteringResults.stats] = manova1(ffm_all,  seglist(:,4));
	case 'kmeans'
		
	case 'ksom'
		
	case 'som'
		ClusteringResults.sD = som_data_struct(ffm_all);
		for class = 1:length(thisTargetClasses), 
			ClusteringResults.sD = som_label(ClusteringResults.sD, 'add', find(seglist(:,4)==class), Classlist{class}); 
		end;
		ClusteringResults.sD = som_normalize(ClusteringResults.sD, 'var');
		fprintf('\n%s: som_make...', mfilename); 
		ClusteringResults.sM = som_make(ClusteringResults.sD, 'msize', ClusteringParams{1});
		fprintf('\n%s: som_autolabel...', mfilename); 
		ClusteringResults.sM = som_autolabel(ClusteringResults.sM, ClusteringResults.sD);
		
		% som_show(ClusteringResults.sM);
		fprintf('\n%s: som_show...', mfilename); 
		fh = figure('visible', 'off'); 
		sH = som_show(ClusteringResults.sM, 'umat', 'all', 'bar', 'none', 'footnote', '');
		% som_grid(ClusteringResults.sM, 'surf', ClusteringResults.sM.codebook(:,4))
		
		fprintf('\n%s: kmeans_clusters...', mfilename); 
		[ClusteringResults.c,ClusteringResults.p,ClusteringResults.err,ClusteringResults.ind] = ...
			kmeans_clusters(ClusteringResults.sM, 20); 

end;


% SAVE
if (DoSave)
    SaveTime = clock;
    classisox_filename = dbfilename(Repository, 'prefix', 'ISOCLUST', 'suffix', SimSetID, 'subdir', 'ISO');
    fprintf('\n%s:   Save %s...', mfilename, classisox_filename);
    save(classisox_filename, ...
		'fweighting', ...
		'ClusteringMethod', 'ClusteringParams', 'ClusteringResults', ...  %'fm_link', ...  % 'fm_dist', 'fm_cluster',
        'thisTargetClasses', 'Classlist', 'FeatureString', 'FilteredFeatureString', 'fm_FeatureString', ...
        'seglist', 'MergeClassSpec', 'Partlist', 'DSSet', ...
        'StartTime', 'SaveTime');
    fprintf('done.\n');
end;
