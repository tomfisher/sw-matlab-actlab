function thisfeature = feature_emgfilter(sdata, varargin)
% function thisfeature = feature_emgfilter(sdata, varargin)
%
% EMG filtering routine
% 
% SPS should be supplied at least.

[Mode, SPS, FilterOrder, Lowfrq] = ...
    process_options(varargin, ...
    'mode', 'filter', 'sps', 1024, 'filterorder', 4, ...
    'lowfrq', 20);

thisfeature = sdata;

% apply bandpass filter: [Lowfrq 0.5*SPS]
thisfeature = feature_filter(thisfeature, 'type', 'butter', 'order', 4, 'mode', 'bp', ...
	'sps', SPS, 'lowfrq', Lowfrq, 'highfrq', SPS/2);
% thisfeature = feature_filter(thisfeature, 'type', 'fir', 'order', 4, 'mode', 'bp', ...
% 	'sps', SPS, 'lowfrq', Lowfrq, 'highfrq', SPS/2);
if strcmpi(Mode, 'bandpass'), return; end;

% apply notch filter for 50Hz
% OAM REVISIT: check Matlab notch
thisfeature = feature_filter(thisfeature, 'type', 'butter', 'order', 4, 'mode', 'bs', ...
	'sps', SPS, 'lowfrq', 49, 'highfrq', 51);
% apply notch filter for 100Hz
thisfeature = feature_filter(thisfeature, 'type', 'butter', 'order', 4, 'mode', 'bs', ...
	'sps', SPS, 'lowfrq', 99, 'highfrq', 101);
if strcmpi(Mode, 'filter'), return; end;


% abs
thisfeature = col(abs(thisfeature));

% mean
WindowSize = round(SPS * 0.15); % 150ms
WindowStep = 1;
thisfeature = swindow(thisfeature, WindowSize, WindowStep, @mean, 'mode', 'cont');
