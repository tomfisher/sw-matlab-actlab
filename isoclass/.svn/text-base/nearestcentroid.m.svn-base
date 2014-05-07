function [targets scores distmat] = nearestcentroid( trainingfeatureset, traininglabelset, testfeatureset, varargin)
% function [targets scores distmat] = nearestcentroid( trainingfeatureset, traininglabelset, testfeatureset, varargin)
% 
% Nearest class center classifier
%
%    trainingfeatureset :   N-d matrix of training feature data
%    traininglabelset   :   N-1 column vector of training classlabels
%    testfeatureset     :   M-d matrix of test feature data
%
% Copyright 2005-2008 Oliver Amft
% 2006, Martin Kusserow, Wearable Computing Lab, ETH Zurich


% which method to apply for distance measurement
distancemode = process_options(varargin, 'distancemode', 'euclidean');

% determine number of classes
classes = unique(traininglabelset(:)');

% test data size
[ observations features ] = size(testfeatureset);

% compute nearest class centroid for one class and all observation at once
mu = zeros(length(classes), features);
for class = classes
	selection = ( traininglabelset == class );

	% compute centroid
	mu(class,:) = mean( trainingfeatureset ( selection , : ), 1);
end;

distmat = zeros(observations, length(classes));

for class = classes
	% this is independent of the distance measure
	dist = ( testfeatureset - repmat(mu(class,:), observations, 1) );

	switch lower(distancemode)
		case 'euclidean'
			% euclidian distance matrix, as we make a decision sqrt is not necessary
			distmat(:,class) = sum( dist .^2, 2 );

		case 'neuclidean'
			% compute standard deviation first
			sd = std( trainingfeatureset ( selection, : ));

			% compute standard deviation
			%warn = warning( 'off', 'MATLAB:divideByZero' );
			%warning( warn )
			sd( sd == 0 ) = eps;
			sd = repmat( sd, observations, 1 );

			% zscore euclidian distance matrix, as we make a decision sqrt is not necessary
			distmat( :, class ) = sum( (dist ./ sd).^2, 2 );

		otherwise
			error( '%s: unknown distance mode.\n', mfilename );
	end;
end;

% eliminate unused cols
distmat = distmat( :, classes );

% retrieve class labels (col.nr) of observations having minimum distance
[ values columns ] = min( distmat, [], 2 );

% class label mapping
targets = classes( columns );

% compute confidence scores
maxdistmat = repmat( max( distmat, [], 2 ), 1, length(classes) );
scores = ( maxdistmat - distmat ) ./ maxdistmat;
