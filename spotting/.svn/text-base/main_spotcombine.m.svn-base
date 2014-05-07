% main_spotcombine
%
% Combine similarity spotting runs (classes, similarity runs)
% Different similarity spotting runs are specified by SimSetID_List.
% Will consider bestthres only.

warning('MATLAB:main_spotcombine', 'Old: use main_spotfusion.m instead!');

% requires:
% Partlist; % default: Partlist = Repository.UseParts
SimSetID;   % used for saving results
% SimSetID_List;  % list of spotting results to include, default: use this SimSetID

VERSION = 'V001';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if (~exist('Partlist','var')), Partlist = Repository.UseParts; end;
if (~exist('MergeMethod','var')), MergeMethod = 'FrontOBest'; end;

if (~exist('SimSetID_List','var')), 
	% SimSetID_List can be self-expanding, e.g.:  Expand_SimSetID_List = '{[Subject ''TEST1''], [Subject ''TEST2'']}';  
	% OR set from SimSetID (merging spotters from multiple classes)
	if exist('Expand_SimSetID_List', 'var'),  
		SimSetID_List = eval(Expand_SimSetID_List); 
	else
		SimSetID_List = {SimSetID};
	end;
	DoDeleteSimSetID_List = true;
else
	DoDeleteSimSetID_List = false;
end;

%if (~exist('thisTargetClasses','var')), thisTargetClasses = TargetClasses; end;

if (~exist('DoSave', 'var')), DoSave = true; end;   % save result


% number of parallel spotting streams
NrSpotters = length(SimSetID_List)*length(thisTargetClasses);




% -------------------------------------------------------------------------
% direct results (SIM)
% -------------------------------------------------------------------------
% % build lists for each CV, containing all spotters
% clear allspotters_trainSLC allspotters_testSLC;
% for cvslice = 1:CVFolds
%     allspotters_trainSLC{cvslice} = classlabels2segments(trainSLC(cvslice,:,1));
%     allspotters_testSLC{cvslice} = classlabels2segments(testSLC(cvslice,:));
% end;
% % combine all CV slices
% % allCV_trainSLC = segment_sort(cell2mat(trainSLC(:)),2);
% allCV_testSLC = segment_sort(cell2mat(testSLC(:)),2);
% allCV_testseglist = segment_sort(cell2mat(testseglist(:)),2);
% % result
% fprintf('\n%s: Total SIM result:', mfilename);
% totalmetric_SIM = prmetrics_fromsegments(allCV_testseglist, allCV_testSLC, section_jitter);
% prmetrics_printstruct(totalmetric_SIM);


fprintf('\n%s: Loading section information for CV slices...', mfilename);
[trainSLC testSLC trainseglist testseglist CVFolds ] = ...
    prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
    'BestThresOnly', true, 'MergeSpotters', true, 'MergeCV', true, 'MaxThresOnly', false);

fprintf('\n%s: Total SIM spotting result (ignores classification):', mfilename);
totalmetric_SIM = prmetrics_fromsegments(testseglist, testSLC, section_jitter);
prmetrics_printstruct(totalmetric_SIM);
fprintf('\n%s: Coverage with spot segments: GT labels:%.1f%%,  total data: %.1f%%', mfilename, ...
    sum(segment_size(testSLC))/sum(segment_size(testseglist))*100, ...
	sum(segment_size(testSLC))/testseglist(end,2));

fprintf('\n%s: Class-wise SIM result:', mfilename);
clear classmetric_SIM;
for class = 1:length(thisTargetClasses)
    classmetric_SIM(class) = prmetrics_fromsegments( ...
        segment_findlabelsforclass(testseglist, thisTargetClasses(class)), ...
        segment_findlabelsforclass(testSLC, thisTargetClasses(class)), section_jitter);
end;
prmetrics_printstruct(classmetric_SIM);


% -------------------------------------------------------------------------
% segment merging (COMP)
% -------------------------------------------------------------------------
% mythresholds = 0:0.1:1;
fprintf('\n%s: Merging sections for CV slice...', mfilename);

% [testSL testSC Thresholds] = similarity_eval( ...
%     allCV_testSLC, allCV_testSLC(:,6), [], ...
%     'BestConfidence', 'max', 'verbose', 1, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');
% 
% prmetrics_plotpr('view', [], prmetrics_fromsegments(allCV_testseglist, testSL, section_jitter));
% testSL = testSL{end};
% [testSL testSC] = spot_segmentmerge( ...
%     'FrontOBest', allCV_testSLC, allCV_testSLC(:,6), 'BestConfidence', 'max', 'verbose', 0);

% OAM REVISIT: Alternative: use spot_segmentmerge()
[testSL testSC] = spot_segmentmerge( MergeMethod, testSLC, testSLC(:,6), 'BestConfidence', 'max', 'verbose', 0 );

% OAM REVISIT: Supporting spotters vs. Disagreeing spotters => modes in spot_segmentmerge  

fprintf('\n%s: Total COMP spotting result (ignores classification):', mfilename);
totalmetric_COMP= prmetrics_fromsegments(testseglist, testSL, section_jitter);
prmetrics_printstruct(totalmetric_COMP);
fprintf('\n%s: Segments coverage: GT labels:%.1f%%,  total data: %.1f%%', mfilename, ...
    sum(segment_size(testSL))/sum(segment_size(testseglist))*100, sum(segment_size(testSL))/testseglist(end,2));


fprintf('\n%s: Class-wise COMP result:', mfilename);
clear metric_COMP;
for class = 1:length(thisTargetClasses)
    metric_COMP(class) = prmetrics_fromsegments( ...
        segment_findlabelsforclass(testseglist, thisTargetClasses(class)), ...
        segment_findlabelsforclass(testSL, thisTargetClasses(class)), section_jitter);
end;
prmetrics_printstruct(metric_COMP);

% save it
if (DoSave)
    % make report files compatible with other spotting output files, i.e. 'SIMS'
    testSeg = testSL; testDist = testSC; testSegGT = testseglist; 
    trainSegGT = {[]}; trainSeg = {[]}; trainDist = {}; 
    metrics = metric_COMP;  CVFolds = 1;  bestthres = 0; mythresholds = [];
    SaveTime = clock;
    filename = dbfilename(Repository, 'prefix', 'SCOMP', 'indices', 1, 'suffix', SimSetID, 'subdir', 'SPOT');
    fprintf('\n%s: Save %s...', mfilename, filename);
    save(filename, ...
        'trainSeg', 'trainDist', 'testSeg', 'testDist', ...
        'trainSegGT', 'testSegGT', ...
		'bestthres', 'mythresholds', ...
        'metrics', 'classmetric_SIM', 'totalmetric_SIM', 'section_jitter', ...
        'thisTargetClasses',  'Partlist', 'CVFolds', ...
        'StartTime', 'SaveTime', 'VERSION');
    fprintf('done.');
end;

if (DoDeleteSimSetID_List)
	clear SimSetID_List DoDeleteSimSetID_List;
end;
fprintf('\n');


% error('Breakpoint');

if (0)
    % load max threshold results for all CVs, omitting distance conversion
    thisTargetClasses = 7
    SimSetID_List = {'OliverW1Psel'}
    
    fprintf('\n%s: Loading section information for CV slices...', mfilename);
    [trainSLC testSLC trainseglist testseglist CVFolds ] = ...
        prepallspotresults(Repository, thisTargetClasses, SimSetID_List, ...
        'BestThresOnly', false, 'MergeSpotters', true, 'MergeCV', true, 'ConvertDistance', false, 'MaxThresOnly', true);

    
    figure; hold on; ylim([0 1]); pc = lines(3);
    segment_plotmark([], testSLC, 'similarity', testSLC(:,6), 'width', 2, 'pcolor', pc(3,:));
    segment_plotmark([], segment_findlabelsforclass(testseglist, thisTargetClasses(1)), 'fill', 'style', 'r');
    
    ylim([0 40])
end;


if (0)
    
    figure; hold on; ylim([0 1]); pc = lines(length(thisTargetClasses));

    segment_plotseglist(testSeg);
    
    
    
    % visualise individual results!
    class = 1;
    
    figure; hold on; ylim([0 1]); pc = lines(length(thisTargetClasses));
    tseg = segment_findlabelsforclass(testSL, class);
    segment_plotmark([], tseg, 'similarity', tseg(:,6), 'width', 2, 'style', 'b-');
    segment_plotmark([], segment_findlabelsforclass(testseglist, class), 'fill', 'style', 'k');
    
    for i = 1:thisTargetClasses
        if isempty([]) continue; end;
        segment_plotmark([], trainSLC{cvslice, i}, 'similarity', ...
            trainSLC{cvslice, i}(:,6), 'width', 2, 'pcolor', pc(i,:));
    end;
    segment_plotmark([], segment_findlabelsforclass(trainseglist{cvslice}, class), 'fill', 'style', 'k');
    
end;


