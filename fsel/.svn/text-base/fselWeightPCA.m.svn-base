function [OrderedEigs pcweights] =PCA(features, varargin)
% function [OrderedEigs pcweights] =PCA(features, varargin)
%
% Compute Prinicpal Components using eig or svd method.
% Project the data using: features * OrderedEigs

% (c) 2007 Oliver Amft, ETH Zurich
% derived from KPM tools of Kevin Murphy's FullBNT toolbox

[ncases nfeatures] = size(features);

[method nrcomps verbose] = process_options(varargin, ...
	'method', 'auto', 'nrcomps', nfeatures, 'verbose', 0);

if (nrcomps > nfeatures), nrcomps = nfeatures; end;

if strcmpi(method, 'auto')
	if ( (nfeatures*nfeatures) < (nfeatures * ncases) )
		method = 'eig';
	else
		method = 'svd';
	end;
end;
if (verbose), fprintf('\n%s: method=%s', mfilename, method); end;


fm = features - repmat(mean(features,1), ncases, 1);

switch lower(method)
	case 'eig' % d*d < d*ncases
		C = cov(fm);
		if issquare(C)
			[v d] =eig(full(C));  %, 'nobalance');
		else
			options.disp = 0;
			[v d] = eigs(C, nrcomps, 'LM', options);
		end;
		[pcweights order] = sort(diag(d), 'descend');
		%selpcweights = pcweights(1:nrcomps);
		ordernoz = order(abs(pcweights)>0.0001);
		
		if (nrcomps > length(ordernoz)), nrcomps = length(ordernoz); end;
		OrderedEigs = v(:,ordernoz(1:nrcomps));
		
	case 'svd'
		%[U,D,V] = svds(fm, nrcomps, 'L');
		%pcweights = V;
		error('Not fully implemented.');

	otherwise
		error('Method not understood.');
end;

if (0)
	fprintf('\n%s: Variance accounted to PCs:', mfilename); 
	cumsum(pcweights./sum(pcweights) * 100)
	fsmetrics_plotscree(pcweights);
end;

