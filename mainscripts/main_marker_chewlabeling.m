% main_marker_chewlabeling
%
% Prepare Marker display for chew labeling
%
% typical calling procedure:
%
%    DisplayResult = 'chewlabeling'; Partindex = 87; main_marker

% requires
drawerobj; % as configured by main_marker

% requires Marker version 0.9.3
if (marker_version('vernr') < 903), error('Script %s requires Marker version 903 or greater', mfilename); end;


% customize displays
for splot = 1:length(drawerobj.disp)
	drawerobj.disp(splot).xvisible = drawerobj.disp(splot).sfreq*10;
	drawerobj.editnplay = true;
	
	switch upper(drawerobj.disp(splot).type)
		case 'XSENS'
			drawerobj.disp(splot).hideplot = true;
		case 'SCALES'
			drawerobj.disp(splot).hideplot = true;
		case 'WAV'
			drawerobj.disp(splot).hidesignal(:) = true;
			drawerobj.disp(splot).hidesignal(1) = false;
			drawerobj.disp(splot).ylim = [-.3 .3];
		case 'EMG'
			drawerobj.disp(splot).hidesignal(:) = true;
			drawerobj.disp(splot).hidesignal(1:2) = false;
			drawerobj.disp(splot).ylim = [0 2e4];
	end;
end;  % for i
