function dist = editdistwrapper(ThisObs, Observations, varargin)
% function dist = editdistwrapper(ThisObs, Observations, varargin)
% 
% Wrapper for handling edit distance called by (p)pdist

% From doc pdist:
% Y = pdist(X,@distfun) accepts a function handle to a distance function of
% the form     d = distfun(u,V)
% which takes as arguments a 1-by-p vector u, corresponding to a single row
% of X, and an m-by-p matrix V, corresponding to multiple rows of X.
% distfun must accept a matrix V with an arbitrary number of rows. distfun
% must return an m-by-1 vector of distances d, whose kth element is the
% distance between u and V(k,:).

[categories distmode normalise combine] = process_options(varargin, ...
	'categories', fieldnames(Observations), 'distmode', 'i', ...
	'normalise', 'strlength', 'combine', 'sum');

nobs = length(Observations);  % corresponds to m

dist = zeros(nobs,1);

% determine distance for each element in biblist
thisedist = zeros(1, length(categories)); thischars = zeros(1, length(categories));
for k = 1:nobs
	
	% evaluate each category type
	for catnr = 1:length(categories)
		lengths = [ length(ThisObs.(categories{catnr})) length(Observations(k).(categories{catnr})) ];
		
		if any(lengths == 0)

			% filter out empty strings; not handled by EditDist.m
			thisedist(catnr) = max( lengths );  % one is zero, other greater than zero
			thischars(catnr) = thisedist(catnr) + (thisedist(catnr) == 0); % prevent div by zero
			
		else
			
			obs1 = ThisObs.(categories{catnr}); obs2 = Observations(k).(categories{catnr});
			thischars(catnr) = length( obs1 );  % default normalisation length 
			
			% eval distmode settings
			if any(distmode == 'l')  % use shortest length
				obs1 = obs1(1:min(lengths)); obs2 = obs2(1:min(lengths));
				thischars(catnr) = min(lengths);
			end;
			if any(distmode == 'i')  % ignore case
				obs1 = lower(obs1); obs2 = lower(obs2);
			end;
			if any(distmode == 's')  % sort
				obs1 = sort(obs1); obs2 = sort(obs2);
			end;
			
			% actually compare strings
			thisedist(catnr) = EditDist( obs1, obs2 );
			
		end;
	end; % for catnr
	
	
	% optional normalising step for each category
	switch lower(normalise)
		case 'strlength'
			thisedist = thisedist ./ thischars;
		case 'none'
			% nop
		otherwise
			error('Normalise setting %s not supported.', lower(normalise));
	end;
	
	
	% combination strategy for individual categories
	switch lower(combine)
		case 'sum'
			dist(k) = sum(thisedist);
		case 'mean'
			dist(k) = mean(thisedist);  % equal weighting for all categories
		case 'sqaremean'
			dist(k) = mean(thisedist.^2);  % polynomial weighting of category result
		otherwise
			error('Combine setting %s not supported.', lower(normalise));
	end;
	
	%dist(k) = mean(thisedist ./ thischars);  
	%dist(k) = sum(thisedist ./ thischars);  % sum: same as mean, but not normalised for categories
	%dist(k) = mean( (thisedist ./ thischars) .^2 );  % mean: polynomial weighting of category result
end; % for k

