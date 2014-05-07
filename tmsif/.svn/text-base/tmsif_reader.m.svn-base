function tmsif_reader(DevPort, Channels, Filename, varargin)
% function tmsif_reader(DevPort, Channels, Filename, varargin)
%
% Read in TMSIF data from Nexus-10, store and plot it.
%
% Parameters:
%
% DevPort: Port to read from, e.g.
%               DevPort = 'COM20';  OR  DevPort = '/dev/rfcomm0';
% Channels: Device channels to extract, e.g.
%               Channels = [0 1 13];
% Filename: File to store data
%
% Optional parameters:
%
% FeatureString: Plotting features, e.g.
%               FeatureString = {'CH0_resample_abs_mean'};


if (exist('DevPort', 'var')~=1) | (exist('Channels', 'var')~=1) | (exist('Filename', 'var')~=1)
	fprintf('\nParameters missing.');
	fprintf('\n\n');
	help mainscripts/main_tmsif
	fprintf('\n');
	return;
end;

if (exist('FeatureString', 'var')~=1) FeatureString = ''; end;

if (exist(filename, 'file'))
	fprintf('\n%s: Data file %s exists already, exiting.', mfilename, filename);
	fprintf('\n ');
	return;
end;

fprintf('\n%s: Initialising...', mfilename);

% data column delimiter
delimiter = ' ';

% re-initialise ports
openports = instrfind('Status', 'open');
if (~isempty(openports)) fclose(openports); end;
allports = instrfind;
if (~isempty(allports)) delete(allports); end;

if (verbose) fprintf('\n%s: Opening port %s...', mfilename, DevPort); end;
try
        ph = serial(DevPort, 'BaudRate', 115200);
        fopen(ph);
catch
	error('Cannot open port.');
	return;
end;
fprintf(' Success.');

% device initialisation
if (verbose) fprintf('\n%s: Initialising device...', mfilename); end;
try
	devinitstruct = tmsi_init(ph);
	if isempty(devinitstruct) error(''); end;
catch
	fclose(ph);
	error('Could not initialise.');
	return;
end;
fprintf(' Success.');

% Figure contains no plot when there is no FeatureString provided. 
% However it is needed for breaking script execution.
if isempty(FeatureString)
	sc = [100 100 200 200];
else
	sc = get(0,'screensize');
end;
fh = figure( ...
	'Name', ['TMSIF plot ' ' - ' filename], 'Position', [sc(1) sc(4)-sc(4)*.7 sc(3) sc(4)*.7], ...
	'NumberTitle', 'off', 'CloseRequestFcn', @close_plot);


try
	while(1)
		% read in TMSIF packet 
		
		% decompile packet
		
		% incremental store to file
		
		% update display
		thisfeature = feature_filter(data(:,1), 'type', 'butter', 'order', 4, 'mode', 'bp', ...
			'sps', 2048, 'lowfrq', 20, 'highfrq', 500);
		t = makefeatures([1 20001], ds, 'swmode', 'cont', 'swsize', windowsize, 'swstep', windowstep);
	end;
catch
	fprintf('\nStoped.');
end;

delete(fh);
fprintf('\n%s: program ended.\n', mfilename);





% %% quit program
% function quit_program(fh, eventdata)
% if (drawerobj.ismodified)
% 	ButtonName=questdlg('Labeling not saved - save it?', 'Confirm program exit', 'Yes', 'No','Cancel','Yes');
% 	switch lower(ButtonName)
% 		case 'yes'
% 			if (figure_keypress(fh, [], 'x') == false) return; end;
% 		case 'cancel'
% 			return;
% 	end;
% end;
% delete(fh);
% fprintf('\n%s: program ended.\n', mfilename);
% end % function quit_program
% 
% %% figure_keypress
% function ok = figure_keypress(fh, eventdata, key)
% ok = true;
% 
% %if ~exist('key','var') key = get(fh,'CurrentCharacter'); else key = ''; end;
% if exist('eventdata','var') && (~isempty(eventdata)) && (~exist('key','var'))
% 	key = eventdata.Key; keymod = cell2mat(eventdata.Modifier);
% else
% 	% figure_keypress() may be called directly, not as callback
% 	keymod = '';
% end;
% 
% if isempty(keymod) userkey = key; else userkey = [keymod '-' key]; end;
% 
% %key
% 
% % exit here when: 1. no key, 2. only modifier pressed (gets into key variable)
% if isempty(key) || (~isempty(strmatch(key, {'alt', 'shift', 'control'}, 'exact'))) return; end;
% 
% %userkey
% 
% % switch userkey
% switch userkey
% 
% 	case {'q', 'control-q'} % quit
% 		%                 if strcmp(userkey, 'q')
% 		%                     ButtonName=questdlg('Confirm exit MARKER?', 'MARKER', 'Yes', 'No', 'Yes');
% 		%                     if strcmp(lower(ButtonName), 'no') return; end;
% 		%                 end;
% 		quit_program(fh, []);
% 		return;
% end;
% end % function figure_keypress
% 
% end % main function
