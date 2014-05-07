function fstruct = fselEvalFeatures(FSelCommand, fmatrix, trainlabelids, varargin)
% function fstruct = fselEvalFeatures(FSelCommand, fmatrix, trainlabelids, varargin)
%
% Wrapper function to perform feature weighting/selection based on best
% NSelFeatures weightings. Weighting and selection/sorting methods can be
% stacked using FSelMethod. Example: FSelMethod = {'ANOVA', 'CORR'};
%
% Fields in fstruct:
% fweighting - exact return of selection+sort/extraction function (special for each method)
% fselect - logic vector of selected features
%
% See also:    fselPostApplyWeights
%
% Copyright 2007-2011 Oliver Amft
%
% Changes:
% 2011-02-13: Calling interface changed to transfer settings between fsel functions, Oliver
%   old: function [fweighting fselect fstruct] = fselEvalFeatures(FSelCommand, fmatrix, trainlabelids, NSelFeatures, varargin)
%
% 2012-09-03: added MRMR support, Mirco Rossi (mrossi@ethz.ch)
% 2013-03-11: re-corrections of calling interface, Oliver


[fstruct.NSelFeatures, fstruct.CheckNANs, ...
    fstruct.sc_beta, fstruct.sc_batch_size, fstruct.sc_sparsity_func, fstruct.sc_epsilon, fstruct.sc_num_iters, fstruct.sc_resample_size, fstruct.sc_num_bases, ...
    fstruct.sc_noisevar, fstruct.sc_tol, fstruct.sc_gamma, fstruct.sc_noise_var, ...
    fstruct.verbose] = process_options(varargin, ...
	'NSelFeatures', size(fmatrix,2), 'CheckNANs', true, ...
    'sc_beta', 0.4, 'sc_batch_size', [], 'sc_sparsity_func', 'epsL1', 'sc_epsilon', 0.01, 'sc_num_iters', 10, 'sc_resample_size', 10e3, 'sc_num_bases', [], ...
    'sc_noisevar', 1, 'sc_tol', 0.005, 'sc_gamma', 0.4, 'sc_noise_var', 1, ...
    'verbose', 0);

fstruct.FSelCommand = FSelCommand;
verbose = fstruct.verbose;

if (verbose), fprintf('\n%s:   Features available: %u', mfilename, size(fmatrix,2)); end;

if (fstruct.CheckNANs) && any(any(isnan(fmatrix)))
	fprintf('\n%s: Found %u NANs in features, setting to zero.', mfilename, sum(sum(isnan(fmatrix))) );
	fmatrix(isnan(fmatrix)) = 0; 
end;

% split command string in separate cells, will be processed sequentially
FSelJobs = str2cellf(upper(fstruct.FSelCommand), '_');

fweighting = zeros(1, size(fmatrix,2));
for fjob = 1:length(FSelJobs)
	if (verbose), fprintf('\n%s:   Feature selection: %s (%s)...', mfilename, FSelJobs{fjob}, mat2str(fstruct.NSelFeatures)); end;
	
	switch FSelJobs{fjob}
		% each of the following method entries should provide:
		%
		% fweighting - vector/matrix of feature weights (depends on method; extraction: matrix, selection: vector)
		% fselect - vector of enabled features (relevant for selection methods mostly)
		
		% --- extraction methods ---
		case 'NONE'
			fweighting = diag(ones(size(fmatrix,2),1));  % create diagonal matrix
			fselect = sum(abs(fweighting),2)>eps;
            
        case '+'    % apply current result to fmatrix
            tmp = fstruct.FSelCommand;  fstruct.FSelCommand = FSelJobs{fjob-1}; % apply previous step
            fmatrix = fselPostApplyWeights(fstruct, fmatrix);
            fstruct.FSelCommand = tmp;
            fweighting = zeros(1, size(fmatrix,2));

		case 'LDA'
			fweighting = fselWeightLDA(fmatrix, trainlabelids);
			fselect = sum(abs(fweighting),2)>eps;
			%[FilteredFeatureString(1:size(ffm_train,2))] = deal({'LDA'});

		case 'PCA'
			%fweighting=pca_kpm(fmatrix', length(thisTargetClasses)-1, 1);
			%[fweighting pcweights] = PCA(fmatrix, 'nrcomps', NSelFeatures-1);
			%allvariance = allvariance + pcweights;
			fweighting = fselWeightPCA(fmatrix, 'nrcomps', fstruct.NSelFeatures);
			fselect = sum(abs(fweighting),2)>eps;
			%[FilteredFeatureString(1:size(ffm_train,2))] = deal({'PCA'});

		case 'WMPCA'
			%wmspca
		case 'PPCA'
			%ppca

        case 'STLEARN'  % self-taught learner
            % assumes that class with ID zero is unlabeled data
            if isempty(fstruct.sc_num_bases), fstruct.sc_num_bases = fstruct.NSelFeatures; end;
            
            % fast sparse coding to obtain bases
            [B S stat] = sparse_coding(fmatrix(trainlabelids==0,:), 'num_bases', fstruct.sc_num_bases, 'beta', fstruct.sc_beta, 'resample_size', fstruct.sc_resample_size, ...
                'batch_size', fstruct.sc_batch_size, 'sparsity_func', fstruct.sc_sparsity_func, 'epsilon', fstruct.sc_epsilon, 'num_iters', fstruct.sc_num_iters, 'verbose', 1);  % 'verbose', 0
            
            %fweighting = [B' S]; % B: [ size(fmatrix,2) X num_bases ]    S: [ num_bases X batch_size ]
            fselect = sum(abs(B),2)>eps; % does not make sense here, still kept to retain consistent routine interface
            
            fstruct.B = B; % B: [ size(fmatrix,2) X num_bases ]
            fstruct.S = S; % S: [ num_bases X batch_size ]
            fstruct.sc_stat = stat;

            
            
            
% --- selection methods ---


		case 'BESTN'
			fweighting = col(fselSortBestN(fmatrix, trainlabelids, fweighting, fstruct.NSelFeatures));
			fselect = (fweighting > 0);
			
% 		case {'CORR', 'PCORR'}  % select non-correlating (independent) features
% 			fweighting = fselWeightPearson(fmatrix, [], []);
% 			fweighting = fselSortCorr(fmatrix, trainlabelids, fweighting, NSelFeatures);
% 		case 'SCORR'
% 			fweighting = fselWeightSpearman(fmatrix, [], []);
% 			fweighting = fselSortCorr(fmatrix, trainlabelids, fweighting, NSelFeatures);
			
		case {'CORRDD', 'PCORRDD'}  % select non-correlating (independent) features for data description
			% check that NULL class exists
			classes = unique(trainlabelids);  if ~any(classes==0), error('Could not confirm NULL class'); end;

			dd = max(trainlabelids);
			fweighting = fselSortCorrDD(fmatrix(trainlabelids==dd,:), fweighting, fstruct.NSelFeatures, 'CorrType', 'Pearson');
			fselect = (fweighting > 0);
		case 'SCORRDD'  % select non-correlating (independent) features for data description
			% check that NULL class exists
			classes = unique(trainlabelids);  if ~any(classes==0), error('Could not confirm NULL class'); end;
			
			dd = max(trainlabelids);
			fweighting = fselSortCorrDD(fmatrix(trainlabelids==dd,:), fweighting, fstruct.NSelFeatures, 'CorrType', 'Spearman');
			fselect = (fweighting > 0);

		case 'FLDA'  % use the length(thisTargetClasses)-1 best features only
			fweighting = LDA(fmatrix, trainlabelids);
			fweighting = sum(abs(fweighting),2);
			fweighting = fselSortBestN([], [], fweighting, fstruct.NSelFeatures);
			fselect = (fweighting > 0);

		case 'MWWZ'  % Mann-Withney Wilcoxen test using the z statisitc (two classes) and Spearman selection 
			fweighting = zeros(1, size(fmatrix,2));
			warning('off', 'MATLAB:divideByZero');
			for f = 1:size(fmatrix,2)
				[p, h, stats] = ranksum(fmatrix(trainlabelids==max(trainlabelids),f), fmatrix(trainlabelids==min(trainlabelids),f), 'method', 'approximate');
				fweighting(f) = abs(stats.zval);
			end;
			warning('on', 'MATLAB:divideByZero');

			fweighting = fweighting / max(fweighting);
			fweighting(isnan(fweighting)) = 0;
			
			fweighting = fselSortCorrDD(fmatrix(trainlabelids==max(trainlabelids),:), fweighting, fstruct.NSelFeatures, 'CorrType', 'Spearman');
			fselect = (fweighting > 0);

		case 'ANOVA'
			fweighting = fselWeightANOVA(fmatrix, trainlabelids);
			fweighting = fselSortBestN([], [], fweighting, fstruct.NSelFeatures);
			fselect = (fweighting > 0);

% 		case 'ANOVAC'  % ANOVA + independence selection (two classes only)
% 			fweighting = fselWeightANOVA(fmatrix, trainlabelids);
% 			dd = max(trainlabelids);
% 			fweighting = fselSortCorrDD(fmatrix(trainlabelids==dd,:), fweighting, NSelFeatures);
% 			fselect = (fweighting > 0);

		case 'MI'
			fweighting = fselWeightMutualInformationOAM(fmatrix, trainlabelids);
			fselect = (fweighting > 0);
		case 'MIBIN100'
			fweighting = fselWeightMutualInformationOAM(fmatrix, trainlabelids, 'BINS', 100);
			fselect = (fweighting > 0);
		case 'MICDIST'
			fweighting = fselWeightMutualInformationOAM(fmatrix, trainlabelids, 'ClassPrior', 'classdist');
			fselect = (fweighting > 0);

		case 'MISEL'
			fweighting = fselWeightMutualInformation(fmatrix, trainlabelids );
			fweighting = col(fselSortBestN(fmatrix, trainlabelids, fweighting, fstruct.NSelFeatures));
			fselect = (fweighting > 0);
		case 'MIFS'
			%fweighting = fselWeightMutualInformationII(fmatrix, trainlabelids );
			fweighting = fselSortMIFS(fmatrix, fweighting, 0.5, fstruct.NSelFeatures, [], 'MIFS');
			fselect = (fweighting > 0);
		case 'MIFSU'
			%fweighting = fselWeightMutualInformationII(fmatrix, trainlabelids );
			fweighting = fselSortMIFS(fmatrix, fweighting, 0.5, fstruct.NSelFeatures, [], 'MIFSU');
			fselect = (fweighting > 0);


		case 'RF'
			fweighting = fselWeightRandomForests(fmatrix, trainlabelids, [], ...
				'NrTrees', 100, 'SplitType', 'Entropy', 'Quality', 0.02, 'FeatPerSplit', 20, 'BootstrapShare', 0.15);
			%fweighting = fselSortBestN(fmatrix, trainlabelids, fweighting, NSelFeatures);
			fselect = (fweighting > 0);

		case 'RANDOM'
			fweighting = fselWeightRandom(fmatrix, trainlabelids, []);
			%fweighting = fselSortBestN(fmatrix, trainlabelids, fweighting, NSelFeatures);
			fselect = (fweighting > 0);

		case 'ONES'
			fweighting = ones(1, size(fmatrix,2));
			fselect = (fweighting > 0);

		case 'PDF2'
			if length(unique(trainlabelids))>2, error('Works for two classes only.'); end;

			PDFRes = size(fmatrix,1)^(1/3);
			fweighting = fselWeightPDF2(fmatrix, trainlabelids, [], 'pdfres', PDFRes, 'verbose', 0);
% 			for f = 1:size(fmatrix,2)
% 				if (fweighting(f) < 0.1), fprintf('\n%s: No diff in PDF for feature %u (%1.3f)', mfilename, f, fweighting(f)); end;
% 			end;

			fselect = (fweighting > 0);

        case 'MRMR' % minimum Redundancy Maximum Relevance Feature Selection. Toolbox: http://penglab.janelia.org/proj/mRMR/
            [fselect] = mrmr_miq_d(fmatrix, trainlabelids, 12);
            fweighting=zeros(1,size(fmatrix,2));
            fweighting(fselect)=1;
            fselect=fweighting;

			
		otherwise
			fprintf('\n%s: Filter method not supported.', mfilename);
			error('');
	end; % switch
    
    % local copies are kept till the end since iterative procedures may use several fjob stages
    fstruct.fweighting = fweighting;
    fstruct.fselect = fselect;
end; % for fjob

