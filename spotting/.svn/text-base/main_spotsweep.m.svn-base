% main_spotsweep
%
% Based on main_spotcombine.m but performs a threshold sweep on the
% loaded spotting results. (Hence loads the results with the highest
% threshold.)

% requires:
% Partlist; % default: Partlist = Repository.UseParts
% SimSetID;   % used as basis for SimSetID_List (not needed when list is configured) 
% SimSetID_List;  % list of spotting results to include, default: use this SimSetID

VERSION = 'V003';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;
initdata;

if ~exist('Partlist','var'), Partlist = Repository.UseParts; end;

initmain_ExpandSimSetID;  % provides SimSetID_List, DoDeleteSimSetID_List


if ~exist('SpotType','var'), SpotType = 'SIMS'; end;
%if (~exist('mythresholds','var')), mythresholds = [0:0.1:0.6 0.7:0.02:1.02];  end;
if ~exist('ThresholdModel', 'var'), ThresholdModel = 'unique1'; end;
if ~exist('PlotPoints', 'var'), PlotPoints = []; end;
if ~exist('LabelConfThres', 'var'), LabelConfThres = 0; end;
if ~exist('MaxLabelConfLimit', 'var'), MaxLabelConfLimit = inf; end;
if ~exist('ReturnDistance', 'var'), ReturnDistance = false; end;

if ~exist('section_jitter', 'var'), section_jitter = 0.5; end;
if ~exist('DoTotalMetrics', 'var'), DoTotalMetrics = false; end;  % total performance eval
if ~exist('DoLoad', 'var'), DoLoad = true; end;  % load spotting results

% load spotting results
if (DoLoad), main_spotloadresults; end;


% -------------------------------------------------------------------------
% sweeping
% -------------------------------------------------------------------------
if ~exist('mythresholds', 'var')
% 	thbeg = min(testSLC(:,6))-0.1; if (thbeg<0), thbeg = 0; end;
% 	thend = max(testSLC(:,6))+0.1;
% 	thdeltas = (thend-thbeg)/PlotPoints;
% 	mythresholds = thbeg:thdeltas:thend;
	% mythresholds = estimatethresholddensity(testSLC(:,6), 'Res', PlotPoints, 'Model', 'polyman');
    mythresholds = estimatethresholddensity(testSLC(:,6), 'Res', PlotPoints, 'Model', ThresholdModel);  
    %mythresholds = estimatethresholddensity(testSLC(:,6),'Res', PlotPoints,  'Model', 'uniexp', 'OptPrecision', 0.3, 'XObs', sum(cellfun('size', trainseglist, 1))/CVFolds);
    %mythresholds = estimatethresholddensity(testSLC(:,6),'Res', PlotPoints,  'Model', 'uniexp', 'OptPrecision', 0.3, 'XObs', size(testseglist,1));
    %mythresholds = sort(testSLC(:,6), 'descend');  
    %mythresholds = estimatethresholddensity(testSLC(:,6),  'Res', PlotPoints,  'Model', ThresholdModel{:}); 
    % figure; plot(mythresholds);
end;
PlotPoints = length(mythresholds);  %mythresholds = sort(mythresholds, 'descend');
thbeg = mythresholds(1); thend = mythresholds(end); thdeltas = [];

fprintf('\n%s: Sweeping range %u points, %.2f-%.2f...', mfilename, PlotPoints, thbeg, thend);
fprintf('\n%s: Processing %u sections (relevant: %u)...', mfilename, size(testSLC,1), size(testseglist,1));
clear classmetrics;  testSL = []; 
for class = 1:length(thisTargetClasses)
	fprintf('\n%s: Class %u...', mfilename, class);
	this_testSLC = segment_findlabelsforclass(testSLC, thisTargetClasses(class));
	if isempty(this_testSLC), fprintf('\n%s: INFO: Class %u not found in test sections.', mfilename,  thisTargetClasses(class)); end;

	% run eval WITHOUT MergeMethod set (would imply a COMP or similar fusion step)
	[this_testSL this_testSC] = similarity_eval( this_testSLC, this_testSLC(:,6), [], 'MergeMethod', [], ...
		'BestConfidence', 'auto', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
    
    fprintf('\n%s: Compute class metrics...', mfilename);
    classmetrics{class} = prmetrics_softalign( ...
        segment_findlabelsforclass(testseglist, thisTargetClasses(class)), ...
        this_testSL, 'LabelConfThres', LabelConfThres, 'MaxLabelConfLimit', MaxLabelConfLimit, 'jitter', section_jitter);
	
	testSL = [testSL this_testSL];
	
	fprintf('\n%s: MAX segment coverage: GT labels:%.1f%%,  total data: %.1f%%', mfilename, ...
		sum(segment_size(segment_findlabelsforclass(testSL{end}, thisTargetClasses(class))))/sum(segment_size(segment_findlabelsforclass(testseglist, thisTargetClasses(class))))*100, ...
		sum(segment_size(segment_findlabelsforclass(testSL{end}, thisTargetClasses(class))))/testseglist(end,2));
	%prmetrics_printstruct(classmetrics{class});
end;

if (DoTotalMetrics)
	fprintf('\n%s: Total result (ignoring classes):', mfilename);
	totalmetrics = prmetrics_softalign(testseglist, testSL, 'LabelConfThres', LabelConfThres, 'jitter', section_jitter);
	prmetrics_printstruct(totalmetrics);
	fprintf('\n%s: Sweep metrics available: totalmetrics, classmetrics{}', mfilename);
else
	fprintf('\n%s: Sweep metrics available: classmetrics{}', mfilename);
end; % if (DoTotalMetrics)


if (DoDeleteSimSetID_List)
	clear SimSetID_List DoDeleteSimSetID_List;
end;
fprintf('\n');
