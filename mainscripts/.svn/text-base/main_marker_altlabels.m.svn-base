% main_marker_altlabels
%
% Prepare alternative labels for Marker display. Chew segments are created with main_chewseg1.m
%
% typical calling procedure:
%
%    DisplayResult = 'altlabel'; Partindex = 87; main_marker

% requires
Partindex;
% LabelType; % labeling type to load
% LabelVar; % labeling variable to load
drawerobj; % as configured by main_marker

if ~exist('LabelType','var'), LabelType = 'CC1'; end;
if ~exist('LabelVar','var'), LabelVar = 'CCPhase1List'; end;

% requires Marker version 0.9.3
if (marker_version('vernr') < 903), error('Script %s requires Marker version 903 or greater', mfilename); end;

found = true;

% load alt labeling
filename = dbfilename(Repository, 'indices', Partindex, 'prefix', LabelType, 'suffix', LabelVar, 'subdir', 'SEG');
if ~exist(filename,'file')
	fprintf('\n%s: No labeling file found: %s. Label list is left unchanged.', mfilename, filename);
	found = false;
end;

if (found)
	fprintf('\n%s: Load alt labeling %s, file: %s.', mfilename, LabelVar, filename);
	altlabels = loadin(filename, 'seglist');
	fprintf('\n%s:   total segs: %u', mfilename, size(altlabels,1));

	% now replace labels with same id in initlabels
	labelids = unique(altlabels(:,4));
	initlabels(findn(initlabels(:,4), labelids),:) = [];
	initlabels = segment_sort([initlabels; altlabels]);
end;

% customize displays
for splot = 1:length(drawerobj.disp)
	drawerobj.disp(splot).xvisible = drawerobj.disp(splot).sfreq*12;

	switch upper(drawerobj.disp(splot).type)
		case 'XSENS'
			drawerobj.disp(splot).hideplot = true;
		case 'SCALES'
			drawerobj.disp(splot).hideplot = true;
		case 'WAV'
			drawerobj.disp(splot).hidesignal(:) = true;
			drawerobj.disp(splot).hidesignal(1) = false;
			drawerobj.disp(splot).ylim = [-.1 .1];
		case 'EMG'
			drawerobj.disp(splot).hidesignal(:) = true;
			drawerobj.disp(splot).hidesignal(1:2) = false;
			drawerobj.disp(splot).ylim = [0 2e4];
	end;
end;  % for i

if (found)
	fprintf('\n%s: Alt labels loaded and display configured.', mfilename);
	fprintf('\n');
else
	error('No alt labels found.');
end;
