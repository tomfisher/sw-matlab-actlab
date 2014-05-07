function threslist = similarity_findthresholds(simmodel, Samples, varargin)
% function threslist = similarity_findthresholds(simmodel, Samples, varargin)
%
% Estimate evaluation thresholds from Samples values for a similartiy
% model. The model is used to guess an appropriate threshold distribution.
% Samples should be natural numbers.
%
% See also: similarity_train, similarity_dist, similarity_eval
% See also: estimatethresholddensity

% Copyright 2008 Oliver Amft

% align with params of estimatethresholddensity
[Model Res Order StartPt EndPt verbose] = process_options(varargin, ...
	'Model', 'auto', 'Res', 100, 'Order', 1, 'StartPt', 0, 'EndPt', [],   'verbose', 1);

% filter out Model=='auto'
if strcmpi(Model, 'auto')
	switch lower(simmodel.method)
		case { 'bntgmm', 'netgmm' }
			Model = 'polyauto';  Order = 2;
		otherwise
			Model = 'polyman';  Order = 2;  % manual pt setting
			% less sensitive to local outliers that modify solution
			% since starting point is fixed to zero
			% see: 
			%   p1o2 = load('SPOTOliver_CLettuce3_AA_Test-thres_p1o2')
			%   figure; plot(cell2mat(p1o2.mythresholds')')
	end;
end;

% set Start/End points



threslist = estimatethresholddensity(Samples, ...
	'Model', Model, 'Res', Res, 'Order', Order, 'StartPt', StartPt, 'EndPt', EndPt, ...
	'verbose', verbose);
