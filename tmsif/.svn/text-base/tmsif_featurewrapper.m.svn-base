function fmatrix = tmsif_featurewrapper(data)

% data as expected:
% 
% columns 1..4: raw EMG data
% column 5: Status
% column 6: SAW
% column 7: LossCounter

% thisfeature = feature_filter(data(:,1:4), 'type', 'butter', 'order', 4, 'mode', 'bp', ...
% 	'sps', 2048, 'lowfrq', 20, 'highfrq', 500);


ds.DTable = {'TSEC', 'TMSEC', 'EMG1', 'EMG2', 'EMG3', 'EMG4', 'SMARKER', 'LOSSCNT'};
% ds.DTable = {'TSEC', 'TMSEC', 'EMG1', 'EMG2', 'EMG3', 'EMG4', 'STAT', 'DIGI', 'SAW', 'LOSSCNT', 'PCOUNT'};
%ds.DTable = { 'TMSEC', 'EMG1', 'EMG2', 'EMG3', 'EMG4', 'STAT', 'DIGI', 'SAW', 'LOSSCNT', 'PCOUNT'};
%ds.DTable = {'TSEC', 'TMSEC', 'EMG1', 'EMG2', 'EMG3', 'EMG4', 'DIGI'};
%ds.DTable = {'TMSEC', 'EMG1', 'EMG2', 'EMG3', 'EMG4', 'DIGI'};
%ds.DTable = {'TSEC', 'TMSEC', '??', 'SAW', 'LC', 'PCOUNT'};
%ds.FeatureString = {'EMG1_butterbp4_abs', 'SAW_value', 'LC_value', 'DIGI_value'};
%ds.FeatureString = {'SAW_value', 'LC_value', 'SAW_emgrect'};
%ds.FeatureString = {'EMG1_emgrect', 'EMG2_emgrect', 'EMG3_emgrect', 'EMG4_emgrect', 'SAW_value', 'LC_value'};
ds.FeatureString = { ...
	'EMG1_butterbp4_abs', ... 
	'EMG2_butterbp4_abs', ... 	
	'EMG3_butterbp4_abs', ...
	'EMG4_butterbp4_abs', ...
	'SMARKER_value'};
%ds.SampleRate = 2048;
%ds.SampleRate = 128;
ds.SampleRate = 256;

if isempty(data) 
    % send nr of columns with no data provided
	data = rand(round(ds.SampleRate/4), length(ds.DTable));
end;

ds.Data = data;
windowsize = 256/8; %round(ds.SampleRate * 0.150); % 150ms window
windowstep = 1;
fmatrix = makefeatures([1 length(ds.Data)], ds, 'swmode', 'cont', ...
	'swsize', windowsize, 'swstep', windowstep, ...
	'lowfrq', 25, 'highfrq', ds.SampleRate/2	);
