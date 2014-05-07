function [testSeg testConf Thresholds] = similarity_eval(simlist, simconf, testSegLabels, varargin)
% function [testSeg testConf Thresholds] = similarity_eval(simlist, simconf, testSegLabels, varargin)
% 
% Evaluate similarity search lists using thresholds.
%
% WARNING: Can process one class at a time only!
% 
% See also: similarity_dist, similarity_train
% 
% Copyright 2006-2008 Oliver Amft

% def_analyserange = [min(simconf) max(simconf)];
def_thresholds = [1:15 20:5:150 200:20:500];

[verbose AnalyseRange MergeMethod MergeMethod_Params BestConfidence LoopMode] = ...
	process_options(varargin, ...
	'verbose', 2, 'AnalyseRange', def_thresholds, ...
    'MergeMethod', 'FrontOfBest', 'MergeMethod_Params', {}, ...
	'BestConfidence', 'minimum', 'LoopMode', 'pretend');


if (verbose>1)
	fprintf('\n%s: merge method: %s, sections=%u, BestConfidence=%s', ...
		mfilename, MergeMethod, size(simlist,1), BestConfidence);
	fprintf('\n%s: analyse thresholds: %.2f:%.2f (%u)... ', ...
		mfilename, min(AnalyseRange), max(AnalyseRange), length(AnalyseRange));
end;

if strcmpi(BestConfidence, 'auto')
    if isbetween(simconf, [0 1]), BestConfidence = 'max'; 
    else BestConfidence = 'min'; end;
    if (verbose>2), fprintf('\n%s: BestConfidence: %s', mfilename, BestConfidence); end;
end;

% reflect AnalyseRange list to start with best threshold first
if strcmpi(BestConfidence, 'max') && (AnalyseRange(1) < AnalyseRange(end))
    AnalyseRange  = fliplr(AnalyseRange);
end;


% % before_trainsegs = [1 train_seglist(1,1)];
% % after_trainsegs = [train_seglist(end,2) max(max(simlist))];

Thresholds = zeros(1,length(AnalyseRange));
progress = 0.1;
testSeg = cell(1,length(AnalyseRange)); testConf = cell(1,length(AnalyseRange));
for iter = 1:length(AnalyseRange)
	dval = AnalyseRange(iter);
	Thresholds(iter) = dval;

	% apply threshold and refine step if too large
	switch lower(BestConfidence)
		case {'minimum', 'min'}
			keepsegs = (min(simconf,[],2) <= dval);
		case 'max'
			keepsegs = (max(simconf,[],2) >= dval);
	end;

	if (verbose>2), fprintf('\n%s: iter %u: dval=%.3f ', mfilename, iter, dval); end;
	thres_simlist = simlist(keepsegs,:); thres_simconf = simconf(keepsegs,:);

	if isempty(thres_simlist), continue; end;
	
	% merge sections that obey to threshold
	if isempty(MergeMethod)
		thres_simlistM = thres_simlist;  thres_simconfM = thres_simconf;
	else
		if (verbose>2), fprintf('\n%s: merge: %u (%3.1f%%) ', mfilename, ...
				size(thres_simlist,1), size(thres_simlist,1)/size(simlist,1)*100); end;

		[thres_simlistM, thres_simconfM] = spot_segmentmerge( MergeMethod, thres_simlist, thres_simconf, ...
            'BestConfidence', BestConfidence, 'verbose', verbose-1, MergeMethod_Params{:});
	end;


	if (verbose>1)
		% intermediate statisitcs
		testmiss = sum(segment_countoverlap(testSegLabels, thres_simlistM) == 0);
        testhit = sum(segment_countoverlap(testSegLabels, thres_simlistM) > 0);
		fprintf('\n%s: i %u: d=%.1f  ret:%u, miss:%u of %u, hit:%u  ', ...
			mfilename,  iter, dval, size(thres_simlistM,1), testmiss, size(testSegLabels,1), testhit);
		%fprintf('\n');
	end;
	if (verbose>0)
		%progress = print_progress(progress, size(thres_simlist,1)/size(simlist,1));
		progress = print_progress(progress, iter/length(AnalyseRange));
	end;

	% store results
	testSeg{iter} = thres_simlistM; testConf{iter} = thres_simconfM;


	% done when no additional sections available
	switch lower(BestConfidence)
		case {'minimum', 'min'}
			todo = (simconf > dval);
		case 'max'
			todo = (simconf < dval);
	end;
	if ~strcmpi(LoopMode, 'complete')
		if (~any(todo)) || (~any(simconf(todo) < Inf)), break; end;
	end;
end; % for iter


% pretend to complete the threshold sweep; this is faster than actually
% performing the analysis, however correct since no additional sections are
% available
if strcmpi(LoopMode, 'pretend') && (iter < length(AnalyseRange))
	for iter_p = iter+1:length(AnalyseRange)
		testSeg{iter_p} = testSeg{iter}; testConf{iter_p} = testConf{iter};
		Thresholds(iter_p) = AnalyseRange(iter_p);
		
		if (verbose>0), progress = print_progress(progress, iter_p/length(AnalyseRange)); end;
	end;
else
	Thresholds(iter+1:end) = [];
end;
