function [dist conf] = similarity_dist(Observations, spotmodel)
% function [dist conf] = similarity_dist(Observations, spotmodel)
%
% determine observation confidence by applying spotmodel
%
% supported methods:
%                  'EUCLIDNORM': normalised euclidean distance (requires: mu, sd, [thres])
%                  'THRESHOLD' : distance to a threshold (requires: thres)
%                  'NAIVEBAYES': Naiive Bayes (requires: mu, sd)
%                  'EDITDISTANCE': observations are structs with strings
%
% Observations     new feature vector to test, [obs x feat]
%
% determine mu and std:
%       mu = mean(Obs,1);
%       sd = std(Obs,0,1);
%
% See also: similarity_train, similarity_eval
% 
% Copyright 2006-2008 Oliver Amft

[nobs nfeat] = size(Observations);
classids = spotmodel.classids;
nclasses = length(classids);

dist = []; conf = [];

% compute distances
switch lower(spotmodel.method)
	case 'threshold'
		% requires: threshold (thres) per feature
		thres = spotmodel.threshold;

		dist = zeros(nobs, nfeat);
		for obs = 1:nobs
            for c = 1:nclasses
                dist(obs,c) = sum( Observations(obs,:) - row(thres(c,:)) );
            end;
		end;

		% dist(find(dist < 0)) = 0;
		conf = (dist >= 0);
		% conf(find(dist >= 0),:) = 1; conf(find(dist < 0),:) = 0;
		% conf = shiftnorm(dist);

    case 'threshold2'
		% requires: two thresholds [lower, upper], one feature
		thres = spotmodel.threshold;  % nclasses-by-2 matrix

		dist = zeros(nobs, nclasses);
        for c = 1:nclasses
            dist(:,c) = ~isbetween( Observations, thres(c,2:3) );
        end;


	case { 'euclidnorm', 'euclidn', 'euclid', 'ncc', 'hcluster', 'kmeans', 'nnd', 'nkmeans', 'nhcluster' }
		% report center wih shortest euclid distance
		centers = spotmodel.centers; sd = spotmodel.sd;    % nclasses-by-nfeat-by-nclusters matrix
		priors = spotmodel.priors; nclusters = spotmodel.nclusters;
		linktype = spotmodel.linkage;

		dist = zeros(nobs, nclasses, max(nclusters));
		for c = 1:nclasses
            for i = 1:nclusters
                % dist: nobs-by-nclasses-by-nclusters matrix
                dist(:,c,i) = sqrt(sum( ( (Observations - centers(ones(nobs,1)*c,:,i)) ./ sd(ones(nobs,1)*c,:,i) ).^2, 2) );
            end;
		end;

		dist = similarity_dist_combine(dist, priors, linktype);


	case { 'mahal', 'mahalanobis', 'gaussian', 'covkmeans' }
		% Mahalanobis distance, independent gaussians
		centers = spotmodel.centers;  % nclasses-by-nfeat-by-nclusters matrix
        icov = spotmodel.icov;    % nclasses-by-nfeat-by-nfeat matrix
		priors = spotmodel.priors; nclusters = spotmodel.nclusters;
		linktype = spotmodel.linkage;
		
        % there exists no implementation yet that uses clusters with a covariance model
        % anyway, here is a precaution
		if nclusters==1 && ndims(icov)<4, t(1,:,:,:) = icov; icov = shiftdim(t, 3); end;

		dist = zeros(nobs, nclasses, nclusters);
        for c = 1:nclasses
		for i = 1:nclusters
            %d = Observations - row(centers(ones(nobs,1)*c,:));
			% this inefficient but easy to understand
			for obs = 1:nobs
                d = Observations(obs,:) - row(centers(c,:));
				dist(obs,c,i) = sqrt( d * (squeeze(icov(c,i,:,:)) * d') );
			end;
		end;
        end;

		dist = similarity_dist_combine(dist, priors, linktype);
		
		% alternative
		%ri = spotmodel.R' \ (Observations - spotmodel.mu(ones(nobs,1),:))';
		%dist = sum(ri.*ri,1)'*(78-1);


	case 'knnd'
		centers = spotmodel.centers;     % nclasses-by-nfeat-by-nclusters matrix
		nclusters = spotmodel.nclusters;  % nr of training objects
		k = spotmodel.k;  
		priors = spotmodel.priors; 
		linktype = spotmodel.linkage;

		dist = zeros(nobs,1);
		for obs =1:nobs % distance of ever object to every other - corresponds to ppdist
			tmp = sqrt(sum( (ones(nclusters,1)*Observations(obs,:) - centers) .^ 2, 2));
			tmp = sort(tmp);

			dist(obs) = similarity_dist_combine(row(tmp(1:k)), priors, linktype);
		end;



	case 'bayesgauss'   % ... Naiive Bayes using normal distribution
		% requires: mu, sd
		mu = spotmodel.centers; sd = spotmodel.sd;  reg = spotmodel.LLreg;

		%obslik = zeros(nobs, nfeat);
		% find out about warning identifier: [s id ]= lastwarn; disp(id);


		o = -0.5 * ((Observations - ones(size(Observations,1),1)*mu) ./ (ones(size(Observations,1),1)*sd)) .^2;
		o = o - log( ones(size(Observations,1),1)*(sqrt(2*pi) .* sd) ) - log(reg);

		o = o + eps*(o==0);

		%lastwarn('');
		%warning('off', 'MATLAB:log:logOfZero');
		%obslik = sum( log(exp(o)),2 );
		obslik = logsumexp(o,2);
		%warning('on', 'MATLAB:log:logOfZero');
		%[s id]= lastwarn; if (~isempty(id)), fprintf('\n%s: %s', mfilename, id); end;

		%dist = obslik * (-1);
		%dist = obslik;
		%conf = shiftnorm(dist); % based on these observations

		% convert obslik to distance: 1. reflect at 0, 2. shift to positive values
		% dist = 0 - obslik;
		% mins = min(dist, [], 2); % min obslik for each observation (row)
		% dist = dist + repmat(abs(mins .* (mins < 0)), 1,2);
		%eobslik = exp(obslik);

		obslik = obslik-max(obslik(:));
		% convert loglik to distance: reflect at 0
		if any(obslik >0), error('Obslik is positive!'); end;
		dist = abs(obslik);


	case 'bntgmm'
		% remove kmeans from voicebox, netlab...
		PathStruct = modifypath('Mode', 'suspend', 'PathString', ...
			{'lit/matlab/voicebox', 'lit/matlab/netlab', 'lit/matlab/somtoolbox2', 'lit/matlab/cocmod', ...
			'lit/matlab/Auditory', 'lit/matlab/sdh'});

		try
			% OAM REVISIT: apply prior in log-space
			[B B2 LL] = mixgauss_prob(Observations', spotmodel.mu, spotmodel.sigma, spotmodel.priors);

			% OAM REVISIT: should MOG be normailised??
			LLpost = LL' + ones(nobs,1)*log(spotmodel.priors') + spotmodel.LLreg;  % log(B+(B==0)*eps(0))' + spotmodel.LLreg;
			%LLsum = log(sum(exp(LLpost),2));   LLsum(LLsum>0) = 0;
			LLsum = logsumexp(LLpost,2); LLsum(LLsum>0) = 0;
			% 		LLsum = log(sum(B,1))';
			dist = abs(LLsum);
			% 		Bsum = sum(B,1) ./ spotmodel.Bnorm;  Bsum(Bsum>1) = 1;
			% 		dist = 1-Bsum;
			% dist = sum(B,1);
		catch
		end;
		modifypath('Mode', 'restore', 'PathStruct', PathStruct);

	case 'netgmm'
		% see DEMGMM1
		mix = spotmodel.mix;
		LLreg = spotmodel.LLreg;
		%Z = gmmpost(mix, Observations);
		[a LLa] = gmmactiv(mix, Observations);   % LL implemented for spherical only
		%post = (ones(nobs, 1)*mix.priors).*a;
		LLpost = LLa + ones(nobs,1) * log(mix.priors) + LLreg;
		%LLsum = sum(exp(LLpost),2);
		%LLsum = log(LLsum-(LLsum==0)*1e-200); LLsum(LLsum>0) = 0;
		LLsum = logsumexp(LLpost,2); LLsum(LLsum>0) = 0;
		dist = abs(LLsum);
		% OAM REVISIT: should MOG be normailised??





		% --- event level methods ---

	case 'bernoulli'  % discrete input Bayes fusion
		% requires:
		%   thetamap - trained/derived Bernoulli estimates
		%   mapidx - lookup table mapping observations to entries in thetamap

		thetamap = spotmodel.thetamap;  mapidx = spotmodel.mapidx;
		obslik = zeros(nobs, 1);  % one class only
		for obs = 1:nobs
			for f = 1:nfeat
				thisidx = find(mapidx(:,f)==Observations(obs,f));
				% map unknown values (not seen in training) to last map entry, empty
				if isempty(thisidx), thisidx = size(thetamap,1); end;
				obslik(obs) = obslik(obs) + thetamap(thisidx, f); % thetamap is log-valued
			end; % for f
		end; % for obs

		% convert loglik to distance: reflect at 0
		if any(obslik >0), error('Obslik is positive!'); end;
		dist = abs(obslik);


	case 'editdistance'  % symbol based (uses string)
		trainstring.string = spotmodel.trainstring;

		% 		dist = zeros(nobs,1);
		% 		for obs = 1:nobs
		% 			dist(obs) = EditDist(Observations(obs).string, trainstring.string);
		% 		end;
		dist = editdistwrapper(trainstring, Observations, 'categories', {'string'}, spotmodel.editdist_params{:});

		conf = dist ./ length(trainstring.string); % crude!


	case 'histogram'  % symbol based (uses string)
		dist = zeros(nobs, nfeat);

		for obs = 1:nobs
			obshist = strhist(Observations(obs), 'symbolset', spotmodel.symbolset);
			% 			obshist = zeros(1, length(spotmodel.symbolset));
			% 			% compute observation histogram
			% 			for i = 1:length(spotmodel.symbolset)
			% 				obshist(i) = sum(Observations(obs).string == spotmodel.symbolset(i));
			% 			end;

			%obshist = mclipping(obshist, 'limitvals', spotmodel.clipsd);

			% does not support independent weighting of insertion/deletion error
			dist(obs) = sum(abs(spotmodel.histogram - obshist));
		end;


	case 'strhistn' % symbol based (uses string)
		mu = spotmodel.mu; sd = spotmodel.sd;

		dist = zeros(nobs, nfeat);
		for obs = 1:nobs
			obshist = strhist(Observations(obs), 'symbolset', spotmodel.symbolset);
			%obshist = mclipping(obshist, 'limitvals', spotmodel.clipsd);

			dist(obs) = sqrt(sum( ( (obshist - row(mu)) ./ row(sd) ).^2, 2) );
		end;

    case 'histaocc'  % histogram from instance features (cell lists) of all spotters combined
		centers = spotmodel.centers; sd = spotmodel.sd;  symbolset = spotmodel.symbolset;
        dist = zeros(nobs, nfeat);    nsym = cellfun('size', symbolset,2);
        h = cell(1, nfeat);
        for s = 1:nfeat, h{s} = zeros(nobs, length(symbolset{s})); end;
        
        for obs = 1:nobs
            for s = 1:nfeat
                [symtype symcount] = countele(Observations{obs,s});
                for i = 1:length(symtype),
                    h{s}(obs, symbolset{s}==symtype(i)) = symcount(i);
                end;
            end;
        end;
        
        hall = nan(nobs, sum(nsym));  nsymcnt = cumsum([0 nsym]);
        for s = 1:nfeat
            hall(:,nsymcnt(s)+1:nsymcnt(s+1)) = h{s};
        end;

        dist = sqrt(sum( ( (hall - centers(ones(nobs,1),:)) ./ sd(ones(nobs,1),:) ).^2, 2) );
        %dist(obs) = sqrt(sum( ( (obshist - row(mu)) ./ row(sd) ).^2, 2) );
        %plot(dist); ylim([0 20]);

	otherwise
		error('Method %s not supported.', spotmodel.method);
end; % switch spotmodel.method

return; % similarity_dist


function dist = similarity_dist_combine(dist, priors, linktype)
% receives a distance matrix of the form nobs X ndistances, determines
% distance according to linktype for each observation (row)
% dist: nobs-by-nclasses-by-nclusters matrix
dist = dist ./ shiftdim(priors(:,:, ones(size(dist,1),1) ), 2);
switch lower(linktype)
	case { 'single', 'min' }
		dist = min(dist, [], 3);
	case { 'average', 'mean' }
		dist = mean(dist, 3);
	case { 'complete', 'max' }
		dist = max(dist, [], 3);

		% geomean, harmmean
	otherwise
		error('Linkage type ''%s'' not supported.', upper(linktype));
end;