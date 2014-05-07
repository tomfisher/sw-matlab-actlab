function spotmodel = similarity_train(Observations, Method, varargin)
% function spotmodel = similarity_train(Observations, Method, varargin)
%
% Similarity training. Observations are a feature matrix, one instance per line, 
% columns corresponding to individual features.
%
% See also: similarity_dist, similarity_eval
% 
% Copyright 2006-2008 Oliver Amft

spotmodel = [];
[nobs nfeat] = size(Observations);

if ~exist('Params', 'var'), Params = {}; end;
[params_filename ...
	params_normalise, params_combine, params_distmode, param_Linkage, ...
	params_symbolset, params_sdlimit, params_CodebookSize, params_regularize, ...
	params_useprior, params_TrainIterations,  Trainlabels] = process_options(varargin, ...
	'filename', '', ...
	'normalise', 'none', 'combine', 'sum', 'distmode', '', 'linkage', 'single', ...
	'symbolset', '', 'sdlimit', 2, 'codebooksize', 3, 'regularize', true, 'useprior', false, 'TrainIterations', 20, ...
    'trainlabels', ones(nobs,1) );

classids = unique(Trainlabels);
nclasses = length(classids);

nclassobs = zeros(1, nclasses);
for c =1:nclasses
    nclassobs(c) = size(Observations(Trainlabels == classids(c), :), 1);
end;


% load model from file
if strcmpi(Method, 'loadmodel') && (~isempty(params_filename))
	spotmodel = loadin(params_filename, 'spotmodel');
	if ~isfield(spotmodel, 'adaptive'), return; end;

	% adapt the model
	Method = spotmodel.method;
end;

spotmodel.method = lower(Method);
spotmodel.classids = classids;
switch lower(Method)

	case 'threshold'   % fixed threshold per feature
		% config:
		%   SpottingMethod_Params = {'sdlimit', 50}

        if isempty(params_sdlimit) || (size(params_sdlimit,2) ~= nfeat) || (size(params_sdlimit,1) ~= nclasses), 
            params_sdlimit = zeros(nclasses, nfeat); 
        end;
        
        spotmodel.threshold = params_sdlimit;

	case {'bayesgauss', 'euclidnorm', 'euclidn', 'ncc'}  % normalised Euclidean
		% config:
		%   SpottingMethod_Params = {}
        mu = zeros(nclasses, nfeat); sd = zeros(nclasses, nfeat);
        
        for c = 1:nclasses
            mu(c,:) = mean(Observations(Trainlabels == classids(c), :), 1);
            sd(c,:) = std(Observations(Trainlabels == classids(c), :),0,1);
            
            % if std < 1e-10, reset it
            sd(c,:) = sd(c, :)  +  eps * (sd(c, :) < 1e-10);
        end;
        %         mu = mean(Observations, 1);
        % 		sd = std(Observations, 0, 1);


		spotmodel.centers = mu; spotmodel.sd = sd;  % nclasses-by-nfeat-by-nclusters matrix
		spotmodel.priors = ones(nclasses,1);   spotmodel.nclusters = ones(nclasses,1);
		spotmodel.LLreg = 10;
		spotmodel.linkage = param_Linkage;

	case 'euclid'  % NON-normalised Euclidean
		% config:
		%   SpottingMethod_Params = {}

        mu = zeros(nclasses, nfeat);
        for c = 1:nclasses
            mu(c,:) = mean(Observations(Trainlabels == classids(c), :), 1);
        end;

        sd = ones(nclasses, nfeat);
		spotmodel.centers = mu; spotmodel.sd = sd;  % nclasses-by-nfeat-by-nclusters matrix
		spotmodel.priors = ones(nclasses,1);   spotmodel.nclusters = ones(nclasses,1);
		spotmodel.linkage = param_Linkage;

        
	case { 'mahal', 'mahalanobis', 'gaussian' }   % Mahalanobis distance
		% config:
		%   SpottingMethod_Params = {}

        % nclasses-by-nfeat-by-nclusters matrix
        spotmodel.centers = zeros(nclasses, nfeat);  spotmodel.icov = zeros(nclasses, 1, nfeat, nfeat);
        for c = 1:nclasses
            spotmodel.centers(c,:) = mean(Observations(Trainlabels == classids(c), :), 1);
            spotmodel.icov(c,1,:,:) = pinv(cov( Observations(Trainlabels == classids(c), :) ));  % ncluster=1
        end;
        
		spotmodel.priors = ones(nclasses,1);   spotmodel.nclusters = 1;
		spotmodel.linkage = param_Linkage;

		%[dummy spotmodel.R] = qr( (Observations - spotmodel.mu(ones(nobs,1),:) ) ,0);



	case { 'hcluster', 'nhcluster' }   % hierarchical clustering approach using Eulidean distance
		% config:
		%   SpottingMethod_Params = {'codebooksize', 10}
        
        % OAM REVISIT: added multi-class functionality, but not tested!
        
         % nclasses-by-nfeat-by-nclusters matrix
        if min(nclassobs)<params_CodebookSize
            fprintf('\n%s: WARNING: Changed clusters: Coodbook: %u, Observations: %s', mfilename, ...
                params_CodebookSize, mat2str(nclassobs));
            params_CodebookSize = min(nclassobs);
        end;

        centers = zeros(nclasses, nfeat, params_CodebookSize); 	sd = zeros(nclasses, nfeat, params_CodebookSize);
        for c = 1:nclasses
            thisObservations = Observations(Trainlabels == classids(c), :);    

            fmdist = pdist(thisObservations, 'Euclidean'); % distance vector
            fmlink = linkage(fmdist, 'Ward'); % clustering
            fmcluster = cluster(fmlink, 'MaxClust', params_CodebookSize); % generating clusters

            for i = 1:params_CodebookSize
                centers(c,:,i) = mean( thisObservations(fmcluster==i,:), 1 );
                sd(c,:,i) = std( thisObservations(fmcluster==i,:), 0, 1 );

                % if std < 1e-10, reset it
                sd(c,:,i) = sd(c,:,i)  +  eps * (sd(c,:,i) < 1e-10);
            end;

            if (params_useprior)
                % Set priors depending on number of points in each cluster
                % OAM REVISIT: Prior does NOT improve modelling performance!
                error('Not implemented.');
            else
                priors(c,:) = ones(1, params_CodebookSize);
            end;

            if strcmpi(Method, 'nhcluster')
                sd(c,:,:) = ones(nfeat, params_CodebookSize);
            end;
        end; % for c
        
		spotmodel.centers = centers; spotmodel.sd = sd;  spotmodel.priors = priors;
		spotmodel.nclusters = params_CodebookSize;  % const size of clusters for all classes
		spotmodel.linkage = param_Linkage;


	case { 'kmeans', 'covkmeans', 'nkmeans' }  % k-means clustering approach
		% uses Netlab
		% config:
		%   SpottingMethod_Params = { 'codebooksize', 10 }
		if (nobs<params_CodebookSize)
			fprintf('\n%s: WARNING: Changed clusters: Coodbook: %u, Observations: %u', mfilename, params_CodebookSize, nobs);
			params_CodebookSize = nobs;
		end;

		if ~any(findtoolboxpath('lit/matlab/netlab')), error('Could not find Netlab in path.'); end;

		bestdist = inf;  progress = 0.1;
		for trainiter =1:params_TrainIterations
			clear trainmodel;
			%progress = print_progress(progress, trainiter/params_TrainIterations);

			centers = zeros(params_CodebookSize, nfeat);
			options = foptions;
			options(14) = 500;  % nr of interations
			options(5) = 1;	% init centres randomly from data
			[centers, options, post] = kmeans(centers, Observations, options); % post: selected center (1-of-N coded)

			if (params_useprior)
				% Set priors depending on number of points in each cluster
				% OAM REVISIT: Prior does NOT improve modelling performance!
				cluster_sizes = max(sum(post, 1), 1);  % Make sure that no prior is zero
				priors = cluster_sizes/sum(cluster_sizes); % Normalise priors
			else
				priors = ones(1, params_CodebookSize);
			end;

			if strcmpi(Method, 'covkmeans')
				% use mahalanobis
				icov = zeros(1, params_CodebookSize, nfeat, nfeat);  % nclasses = 1
				for i = 1:params_CodebookSize
					if sum(post(:,i)>0) < 3
						icov(1, i,:,:) = ones(nfeat, nfeat);  % is that suffient??
						fprintf('\n%s: Too few objects (%u) in cluster %u, cov skipped (Method=%s).', mfilename, ...
							sum(post(:,i)>0), i, upper(Method));
					else
						icov(1, i,:,:) = pinv(cov(Observations(post(:,i)>0,:)));
					end;
				end;  % for i

				trainmodel.icov = icov;

			else  % Method == 'kmeans'
				% determine std (default)
				sd = zeros(params_CodebookSize, nfeat);
				for i = 1:params_CodebookSize
					sd(i,:) = std( Observations(post(:,i)>0,:), 0, 1 );
				end;
				sd = sd + (sd == 0)*eps;

				trainmodel.sd = sd;
			end;
			if strcmpi(Method, 'nkmeans')
				trainmodel.sd = ones(params_CodebookSize, nfeat);
			end;

			trainmodel.centers = centers;  trainmodel.priors = priors;  trainmodel.classids  = 1;
			trainmodel.nclusters = params_CodebookSize;
			trainmodel.linkage = param_Linkage;
			trainmodel.method = Method;
			
			thisdist = similarity_dist(Observations, trainmodel);
			if (0), fprintf('\n%2u: %.3f  %.3f', trainiter, mean(thisdist), std(thisdist)); end;
			thisdist = 	mean(thisdist);
			if thisdist < bestdist
				spotmodel = trainmodel; 	bestdist = thisdist;
			end;
		end % trainiter
		%disp(bestdist);
		
		% 		SpottingMethod_Params = {  'codebooksize'    [10] ,  'TrainIterations', 1}
		% 		t = [];
		% 		for i = 1:100
		% 			spotmodel = similarity_train(fmtrain, SpottingMethod, SpottingMethod_Params{:}); secdist = similarity_dist(fmtest, spotmodel); t = [t; min(secdist) mean(secdist)]; disp(t(end,:))
		% 		end;
		
		
	case 'lvq'  % LVQ cluster building method
		% use netlab toolbox
		% LBG learning algorithm??
		error('Not implemented.');

	case 'nnd'  % NN description algorithm; nearest distance only, no NN(NN(.))
		% config:
		%   SpottingMethod_Params = {}
		spotmodel.centers = Observations;
		spotmodel.sd = ones(nobs, nfeat);
		spotmodel.priors = ones(1, nobs);
		spotmodel.nclusters = nobs;
		spotmodel.linkage = param_Linkage;


	case 'knnd' % k-NN description algorithm
		% config:
		%   SpottingMethod_Params = {'codebooksize', 10}
		if (nobs<params_CodebookSize)
			fprintf('\n%s: WARNING: Changed k: Coodbook: %u, Observations: %u', mfilename, params_CodebookSize, nobs);
			params_CodebookSize = nobs;
		end;
		spotmodel.k = params_CodebookSize;
		spotmodel.priors = ones(1, params_CodebookSize);

		spotmodel.centers = Observations;
		% 		spotmodel.sd = ones(nobs, nfeat);
		% 		spotmodel.priors = ones(1, nobs);
		spotmodel.nclusters = nobs;
		spotmodel.linkage = 'mean';



		if (0)
			% quick testing
			spotmodel = similarity_train(fmtrain, SpottingMethod, SpottingMethod_Params);
			secdist = similarity_dist(fmtest, spotmodel);
			mythresholds = estimatethresholddensity(secdist, 'Model', 'polyplus', 'Order', 2);
			[this_trainSeg this_trainDist] = similarity_eval( fmsectionlist_ts, secdist, trainseglist, ...
				'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
			metrics_train = prmetrics_softalign(trainseglist, this_trainSeg, 'jitter', 0.5, 'LabelConfThres', 1);
			b = prmetrics_findoptimum(metrics_train, 0.1);
			prmetrics_printstruct(metrics_train(b))
			%prmetrics_plotpr('view', [], prmetrics_sort(metrics_train))
		end;



	case 'bntgmm'
		% BNT gaussian mixture model
		% config:
		%   SpottingMethod_Params = {'codebooksize', 10, 'distmode', 'diag', 'regularize', 1}
		if (nobs<params_CodebookSize)
			fprintf('\n%s: WARNING: Changed mixtures: Coodbook: %u, Observations: %u', mfilename, params_CodebookSize, nobs);
			params_CodebookSize = nobs;
		end;

		if isempty(params_distmode), params_distmode = 'diag'; end;

		% remove kmeans from voicebox, netlab
		PathStruct = modifypath('Mode', 'suspend', 'PathString', ...
			{'lit/matlab/voicebox', 'lit/matlab/netlab', 'lit/matlab/somtoolbox2', 'lit/matlab/cocmod', ...
			'lit/matlab/Auditory', 'lit/matlab/sdh'});
		try
			% see mixgauss_classifier_train, mixgauss_classifier_apply

			% iterate multiple times to determine good solution
			clear tsm;   bestLLa = -inf;
			progress = 0.1;
			for i =1:params_TrainIterations
				progress = print_progress(progress, i/params_TrainIterations);

				%disp('start mixgauss_em');
				[tsm.mu, tsm.sigma, tsm.priors] = mixgauss_em(Observations', params_CodebookSize, ...
					'max_iter', 100, 'thresh', 0.01, 'cov_type', params_distmode, 'mu', [], 'Sigma', [], 'method', 'kmeans', ...
					'cov_prior', [], 'verbose', 0, 'prune_thresh', 0);

				%disp('start mixgauss_prob');
				[B B2 LL] = mixgauss_prob(Observations', tsm.mu, tsm.sigma, tsm.priors);

				if sum(LL)>bestLLa,  bestLLa = sum(LL);  spotmodel = tsm;  end;
			end; % for i

			LLpost = LL' + ones(nobs,1) * log(spotmodel.priors');
			if (params_regularize)
				spotmodel.LLreg = max(LLpost(:));
				% 		spotmodel.LLreg = mean(max(LLpost,[],1)); % geometric mean of max LLs: http://en.wikipedia.org/wiki/Geometric_mean
				% 		spotmodel.LLreg = 0-max(LLpost(:));
				% 		LLsum = log(sum(exp(LLpost),2));  % log(sum(B,1))';
				% 		[dummy maxLLpos] = max(LLsum);
				% 		spotmodel.LLreg = 0-max(LLpost(maxLLpos,:))-eps;
			else
				spotmodel.LLreg = 0;
			end;

		catch
		end;
		modifypath('Mode', 'restore', 'PathStruct', PathStruct);

		spotmodel.method = 'bntgmm';  % restore method field

	case 'netgmm'
		% Netlab gaussian mixture model, see DEMGMM1
		% config:
		%   SpottingMethod_Params = {'codebooksize', 10, 'distmode', 'spherical', 'regularize', 0}
		if (nobs<params_CodebookSize)
			fprintf('\n%s: WARNING: Changed mixtures: Coodbook: %u, Observations: %u', mfilename, params_CodebookSize, nobs);
			params_CodebookSize = nobs;
		end;

		if ~any(findtoolboxpath('lit/matlab/netlab')), error('Could not find Netlab in path.'); end;
		if isempty(params_distmode), params_distmode = 'spherical'; end;

		% iterate multiple times to determine good solution
		bestmix = [];   bestLLa = -inf;
		%progress = 0.1;
		for i =1:params_TrainIterations
			%progress = print_progress(progress, i/params_TrainIterations);

			mix = gmm(nfeat, params_CodebookSize, params_distmode);   %  'spherical', 'diag', 'full', 'ppca'
			%mix = gmm(nfeat, params_CodebookSize, 'spherical');   %  'spherical', 'diag', 'full', 'ppca'
			options = foptions;
			options(14) = 20;	% iterations of k-means in initialisation
			mix = gmminit(mix, Observations, options);  % Initialise the model parameters from the data

			% Set up vector of options for EM trainer
			options = zeros(1, 18);
			options(1)  = 0;		% Prints out error values.
			options(14) = 100;		% max. number of iterations.
			[mix, options, errlog] = gmmem(mix, Observations, options);

			[a LLa] = gmmactiv(mix, Observations);  % LL only implemented for spherical
			if sum(LLa)>bestLLa,   bestLLa = sum(LLa);   bestmix = mix; end;
		end; % for i

		[a LLa] = gmmactiv(bestmix, Observations);  % redo for best model

		LLpost = LLa + ones(nobs,1) * log(bestmix.priors);
		if (params_regularize)
			spotmodel.LLreg = max(LLpost(:));
		else
			spotmodel.LLreg = 0;
		end;

		spotmodel.mix = bestmix;

		if (0)
			% quick testing
			spotmodel = similarity_train(fmtrain, SpottingMethod, SpottingMethod_Params);
			secdist = similarity_dist(fmtest, spotmodel);
			mythresholds = estimatethresholddensity(secdist, 'Model', 'polyplus', 'Order', 2);
			[this_trainSeg this_trainDist] = similarity_eval( fmsectionlist_ts, secdist, trainseglist, ...
				'BestConfidence', 'min', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
			metrics_train = prmetrics_softalign(trainseglist, this_trainSeg, 'jitter', 0.5, 'LabelConfThres', 1);
			b = prmetrics_findoptimum(metrics_train, 0.1);
			prmetrics_printstruct(metrics_train(b))
			%prmetrics_plotpr('view', [], prmetrics_sort(metrics_train))
		end;


	case 'parzen'
		% Gaussian model built for every training object
		% Use leave-on-out to determine spherical/diag cov




		% --- event level methods ---

	case 'bernoulli'  % classic discrete Bayesian fusion
		% config:
		%   SpottingMethod_Params = {'codebooksize', 2}
		% codebooksize: max nr of states in features, e.g. if feature=0/1 => codebooksize=2
		%
		% OAM REVISIT: Change to string-based processing (as histogram method)?
		nstates = max(params_CodebookSize);   % nr of states that features can take
		alpha = 1; % Dirichlet prior for zero MLE issue
		tot = size(Observations,1);

		thetamap = zeros(nstates, nfeat);  % occurence hist of every feature in every class
		mapidx = nan(nstates, nfeat);     % lookup index for thetamap
		for f = 1:nfeat
			values = unique(Observations(:,f));  % determine existing observation values
			mapidx(:,f) = [ values repmat(nan, 1, nstates-length(values)) ];  % map unknown obs to last element
			values = mapidx(:,f); % reset values from extended ones (including values at missing positions

			for v = 1:nstates  % all states (classes)
				cnt = sum(Observations(:,f)==values(v));
				thetamap(v,f) = log((cnt+alpha)/(tot+2*alpha));
				%thetamap(v,f) = log((cnt+alpha)/(tot+2*alpha)) - log((tot-cnt+alpha)/(tot+2*alpha));
			end; % for v
		end; % for f

		spotmodel.thetamap = thetamap;  spotmodel.mapidx = mapidx;


	case 'editdistance'  % symbol based (uses string)
		editParams = {'normalise', params_normalise, 'combine', params_combine, 'distmode', params_distmode};

		% Observations must be struct containing strings
		% estimate best fitting string by selecting training obs with
		% lowest distance to all other training obs
		linkmat = ppdist(Observations, @editdistwrapper, 'verbose', 0, ...
			'funcargs', { 'categories', {'string'}, editParams{:} });

		linkdist = sum(squareform(linkmat));
		[trainscore bestpos] = min(linkdist);

		spotmodel.trainscore = trainscore;
		spotmodel.trainstring = Observations(bestpos).string;
		spotmodel.editdist_params = Params;

	case 'strhist'  % symbol based (uses string)
		%if isempty(Params), Params = {unique(cell2str({Observations(:).string},''))}; end;
		%length(unique(cell2str({Observations(:).string},'')))

		if ~isfield(spotmodel, 'symbolset'),  spotmodel.symbolset = params_symbolset; end;
		%spotmodel.histogram = strhist(Observations, 'symbolset', spotmodel.symbolset);

		h = zeros(length(Observations), length(spotmodel.symbolset));
		for obs = 1:length(Observations)
			h(obs,:) = strhist(Observations(obs), 'symbolset', spotmodel.symbolset);
		end;

		if isfield(spotmodel, 'histogram')
			% adapting model
			if isfield(spotmodel, 'adaptive'), fix = 1-spotmodel.adaptive;
			else fix = 1; warning('matlab:similarity_train:adaptive', 'Adaptive mode, but no factor found?!'); end;
			% 			fix = 0.6;
			%h = mclipping(h, 'limitvals', spotmodel.clipsd);
			h = fix.*spotmodel.histogram + (1-fix).*mean(h, 1);
			spotmodel.histogram = h;
		else
			% new model
			spotmodel.sdlimit = params_sdlimit;
			[h spotmodel.clipsd] = mclipping(h, 'sdlimit', spotmodel.sdlimit);
			spotmodel.histogram = mean(h, 1);
		end;

	case 'strhistn' % symbol based (uses string)
		if ~isfield(spotmodel, 'symbolset'),  spotmodel.symbolset = Params{1}; end;

		% 		obssymbols = cell2str({Observations(:).string},'');
		h = zeros(length(Observations), length(spotmodel.symbolset));

		for obs = 1:length(Observations)
			h(obs,:) = strhist(Observations(obs), 'symbolset', spotmodel.symbolset);
		end;

		if isfield(spotmodel, 'mu')
			% adapting model
			fix = 1.0;  			spotmodel.fix = fix;
			%h = mclipping(h, 'limitvals', spotmodel.clipsd);
			mu = fix.*spotmodel.mu + (1-fix).*mean(h, 1);

			sd = fix.*spotmodel.sd + (1-fix).*std(h, 0, 1);
			sd = sd + ((sd == 0) * 1e-10);
		else
			% new model
			spotmodel.sdlimit = Params{2};
			[h spotmodel.clipsd] = mclipping(h, 'sdlimit', spotmodel.sdlimit);
			mu = mean(h, 1); sd = std(h, 0, 1);  sd = sd + ((sd == 0) * 1e-10);
		end;

		spotmodel.mu = mu; spotmodel.sd = sd;

        % 		nobs = length(Observations);
		% 		d = (h - repmat(row(mu),nobs,1)) ./ repmat(row(sd),nobs,1);
		% 		if any(d>1e3),
		% 			fprintf('\n%s: Modelling error at features: %s', mfilename, mat2str(find(d > 1e3)));
		% 		end;

    case 'histaocc'  % histogram from instance features (cell lists) of all spotters combined
        % config:
		%   SpottingMethod_Params = {'symbolset', {[5 6 7], [58:62], 1}}
		% symbolset: codes per spotter
        
		if ~isfield(spotmodel, 'symbolset'),  symbolset = params_symbolset; 
        else symbolset = spotmodel.symbolset; end;
        
        h = cell(1, nfeat);
        for s = 1:nfeat, h{s} = zeros(nobs, length(symbolset{s})); end;
        for obs = 1:nobs  % for all rows
            for s = 1:nfeat % for all spotters
                [symtype symcount] = countele(Observations{obs,s});
                for i = 1:length(symtype), 
                    h{s}(obs, symbolset{s}==symtype(i)) = symcount(i); 
                end;
            end;
        end;
        
        % for all spotters
        hall = [];
        for s = 1:nfeat
            hall = [hall, h{s}];
        end;
        centers = mean(hall,1); sd = std(hall, 0, 1); sd = sd + ((sd == 0) * 1e-10);
        
        spotmodel.centers = centers; spotmodel.sd = sd; spotmodel.symbolset = symbolset;
        
        
	otherwise
		error('Method %s not supported.', Method);

end;  % switch lower(Method)
