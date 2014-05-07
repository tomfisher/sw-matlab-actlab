% main_markertest.m
%
% Experimenting script for Marker with some sin/cos data.


% plug in the data for your plots here
fs = 1;
t = 0:1/fs:2000;
data1 = sin(2*pi*0.005.*t).';
data2 = cos(2*pi*0.01 .*t).';
x = [0,1,2,3,4,5,4,3,2,1];
data3 = repmat(x,1,200).';
clear x;
clear FeatureSet;
FeatureSet = {[data1 1.5*data2], data2, data3};
Classlist = {'MyClass one', 'MyClass two', 'whatever'};

% prepare your labels,
% label format is 'segments', e.g. [begin end size class #number]
% some conversion methods from other formats are provided:
%   classlabels2segments, labeling2segments
initlabels = [ ...
	200 300 101 2 1 1;
	1200 1800 601 3 2 0];

% configure the names of your plots here
PlotTitle = {'Plot title 1','Plot title 2','Plot title 3'};

clear drawerobj;

% configure title of the MARKER window, e.g. subjects name, optional
drawerobj.title = sprintf('%s', mfilename);

% printout label count
if exist('initlabels','var')
	fprintf('\n%s: Found %u labels.', mfilename, size(initlabels,1));
end;

% setup marker display from FeatureSets
for sysno = 1:length(FeatureSet)
	drawerobj.disp(sysno).data = FeatureSet{sysno};

	drawerobj.disp(sysno).ylabel = [PlotTitle{sysno} ' [amp.]'];

	% reference sampling rate [Hz] for the data, must be equal for all plots
	drawerobj.disp(sysno).sfreq = fs;

	% y-axis resolution, optinally (default: guessed automatically)
	% drawerobj.disp(sysno).ylim = [0 max(3*std(drawerobj.disp(sysno).data))]

	% alignment shift in samples, optional
	%drawerobj.disp(sysno).alignshift = 0;

	% alignment sample rate (relative to sfreq), optional
	%drawerobj.disp(sysno).alignsps = 0;

	% size of the data
	%drawerobj.disp(sysno).datasize = max(size(drawerobj.disp(sysno).data));

	% initial visible data range (x-axis), optional
	drawerobj.disp(sysno).xvisible = drawerobj.disp(sysno).sfreq*345;

	% show/hide of individual subplots, optional
	%drawerobj.disp(sysno).hideplot = false;

	% show/hide of individual signals, optional
	%     drawerobj.disp(sysno).hidesignal(1) = false;
	%     if (sysno == 1)
	%         drawerobj.disp(sysno).hidesignal(2) = false;
	%     end;

	% config player information
	% you may listen to the sound section or display a aviatar
	if (0)
		% here we plug in a method to play sound, optional
		% you may register your "play" method in marker_player()
		drawerobj.disp(sysno).playerdata.sourcefile = 'data/mywavfile.wav'; % needed for sound
		drawerobj.disp(sysno).playerdata.playchannel = 1; % optional
	end;
end;


% this is a SPARE plot, e.g. to dispaly optional labels
if (~exist('viewlabels','var'))
	viewlabels = [ ...
		100 200 101 2 1 1; ...
		1000 1500 501 3 2 0; ...
		1300 1600 301 1 3 0.5 ];
end;

sysno = length(FeatureSet)+1;
drawerobj.disp(sysno).type = 'Segments';
drawerobj.disp(sysno).save = false;  % on saving: exclude plot information in CLA file
drawerobj.disp(sysno).data = viewlabels;
drawerobj.disp(sysno).sfreq = fs;
drawerobj.disp(sysno).plotfunc = @marker_plotsegments;
drawerobj.disp(sysno).plotfunc_params = { max(unique(viewlabels(:,4))) };
drawerobj.disp(sysno).ylabel = [drawerobj.disp(sysno).type ' [classes]'];
drawerobj.disp(sysno).sfreq = fs;
drawerobj.disp(sysno).hideplot = false;
drawerobj.disp(sysno).ylim = [0 max(unique(viewlabels(:,4)))+1];
drawerobj.disp(sysno).signalnames = {};



% override automatic setting of y-axis scaling, optional
% use this if MARKER does not gess size correctly
drawerobj.disp(3).ylim = [0 5];

% string cell array of names for the labels, optional
drawerobj.labelstrings = Classlist;

% maximum number of classes/label types, default: 1
drawerobj.maxLabelNum = length(drawerobj.labelstrings);


% configure a default file name (suggested when saving a label file), optional
%[fdir fname fext] = fileparts('mylabelfile.mat');
%drawerobj.iofilename = [fname fext];
%drawerobj.defaultDir = fdir;

% Marker window size: [height width], optional
% drawerobj.windowsizescaling = [1 0.7];
drawerobj.windoworientation = 'classic';

fprintf('\n%s: Launching Marker...', mfilename);
marker(drawerobj, initlabels);
