% main_markersegments
%
% requires:
Partlist;
SegmentSet;
% SegmentSet().name
% SegmentSet().seglist
% SegmentSet().classlist

initdata;
marker_ismodified = false;

% really launch marker
if ~exist('DoLaunch','var'), DoLaunch = true; end;
if ~exist('viewsize','var'), viewsize = 500; end;  % in sec.
if ~exist('FilterScript','var'), FilterScript = {}; end;
if ~exist('markertitleaddendum','var'), markertitleaddendum = ''; end;

% fetch initlabels, labelsps
initlabels = repos_getlabellist(Repository, Partlist);
if ~isempty(initlabels),	fprintf('\n%s: Found %u labels.', mfilename, size(initlabels,1)); end;


% setup marker drawerobj
clear drawerobj;
drawerobj.maxLabelNum = size(Repository.Classlist,2);
drawerobj.labelstrings = Repository.Classlist;

for splot = 1:length(SegmentSet)
	drawerobj.disp(splot).type = 'Segments';
	drawerobj.disp(splot).ylabel = SegmentSet(splot).name;
	drawerobj.disp(splot).data = SegmentSet(splot).seglist;
% 	drawerobj.disp(splot).datasize = partsize(splot);
	drawerobj.disp(splot).sfreq = repos_getfield(Repository, Partlist(1), 'SFrq');
	drawerobj.disp(splot).xvisible = drawerobj.disp(splot).sfreq*viewsize;
% 	drawerobj.disp(splot).signalnames = fb_getsources(SysFeatureString{splot});
	drawerobj.disp(splot).plotfunc = @marker_plotlabeling;
    if isfield(SegmentSet, 'classnames') && ~isempty(SegmentSet(splot).classnames)
        drawerobj.disp(splot).plotfunc_params = { unique(SegmentSet(splot).seglist(:,4)), SegmentSet(splot).classnames };
    end;
	drawerobj.disp(splot).hideplot = false;
	drawerobj.disp(splot).ylim = []; %[0 max(unique(viewsegments(:,4)))+1];
	drawerobj.disp(splot).save = false;    
end; % for splot



% misc settings
drawerobj.consolemenus = true;
drawerobj.askbeforequit = false;
drawerobj.defaultsavetype = 1;
drawerobj.ismodified = marker_ismodified;

[fdir fname fext] = fileparts(dbfilename(Repository, 'indices', Partlist, 'prefix', 'MARKER', 'subdir', 'labels'));
drawerobj.iofilename = [fname fext];
drawerobj.defaultDir = fdir;

drawerobj.title = [ sprintf('SEGMENTS Parts: %s, Subject: %s ', ...
    mat2str(Partlist), repos_getfield(Repository, Partlist(1), 'Subject'))  markertitleaddendum];



% run a script to post-filter the drawerobj settings for specific views
if ~isempty(FilterScript)
	for i = 1:length(FilterScript)
		fprintf('\n%s: Run FilterScript %s...', mfilename, FilterScript{i});
		if ~test(FilterScript{i})
			fprintf('\n');
			fprintf('\n%s: Script failed:', mfilename);
			errorprinter(lasterror, 'MsgOffset', -1, 'DoWriteFile', false);
			countdown(4, 'premsg', 'Launching Marker in');
		else
			fprintf('\n%s: Script %s completed.', mfilename, FilterScript{i});
		end;
	end;
end;


if (DoLaunch)
	fprintf('\n%s: Launching Marker...', mfilename);
	marker(drawerobj, initlabels);
	clear initlabels ;
end;
