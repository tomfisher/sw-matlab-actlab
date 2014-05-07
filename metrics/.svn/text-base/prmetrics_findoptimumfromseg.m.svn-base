function [testSLCopt metricopt] = prmetrics_findoptimumfromseg(testSLC, testseglist, varargin)
% function [testSLCopt metricopt] = prmetrics_findoptimumfromseg(testSLC, testseglist, varargin)
% 
% Estimate optimum threshold from a segmentation/confidence list given a target precision.
% 
% See also: prmetrics_findoptimum, prmetrics_findoptimumfromseg
% 
% Copyright 2009 Oliver Amft

[ThresModel PrecisionThres ConvertDistance BestConfidence LabelConfThres section_jitter verbose] = process_options(varargin, ...
    'ThresModel', 'unique1', 'PrecisionThres', 0.1, 'ConvertDistance', false, ...
    'BestConfidence', 'max', 'LabelConfThres', 0, 'section_jitter', 0.5, 'verbose', 1);

mythresholds = estimatethresholddensity(testSLC(:,6),  'Res', [],  'Model', ThresModel);

[testSL testSC] = similarity_eval( testSLC, testSLC(:,6), [], 'MergeMethod', [], ...
    'BestConfidence', BestConfidence, 'verbose', verbose, 'AnalyseRange', mythresholds, 'LoopMode', 'pretend');

metrics = prmetrics_softalign( testseglist, testSL, 'LabelConfThres', LabelConfThres, 'jitter', section_jitter );
% prmetrics_plotpr('view', [], metrics)

bestthres = prmetrics_findoptimum(metrics, PrecisionThres);

testSLCopt = segment_createlist(testSL{bestthres}, 'conflist', testSC{bestthres});

if ~isempty(testSLCopt)  && ConvertDistance
    testSLCopt(:,6) = distance2confidence(testSLCopt(:,6), mythresholds(bestthres)); 
end;

metricopt = metrics(bestthres);