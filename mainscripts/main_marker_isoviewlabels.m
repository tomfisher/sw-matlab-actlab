% main_marker_isoviewlabels
%
% Extract/prepare classification results for Marker display

% Changelog
% 20090319 - Minor changes to work with ClassType = 'CLASS' (mk)

% requires
Partindex;
%SimSetID;

% requires Marker version 0.9.3
if (marker_version('vernr') < 903), error('Script %s requires Marker version 903 or greater', mfilename); end;

initdata;

% (mk) -----
%if (~exist('ClassType','var')),  ClassType = 'ISOCLASS'; end;
if (~exist('ClassType','var')),  ClassType = 'CLASS'; end;
if (~exist('SimSetID','var')),  fprintf('\n%s: No SimSetID defined. Skipping isoviewlabels.', mfilename); return; end;
% ----- (mk)

switch ClassType
    % (mk) -----
	%case {'ISOCLASS'}
    case { 'ISOCLASS', 'CLASS'}
		fprintf('\n%s: Loading viewlabel information...', mfilename);
        % (mk) ----- MODIFY: Replaced deprecated function call
        %filename = dbfilename(Repository, 'prefix', ClassType, 'suffix', SimSetID, 'subdir', 'ISO');
		filename = repos_makefilename(Repository, 'prefix', ClassType, 'suffix', SimSetID, 'subdir', 'ISO');
        % (mk) ----- MODIFY: Added filename check
		if ~exist(filename, 'file'), return; end;
        load(filename, 'gtseglist', 'alltestIndices', 'predictedclass', 'Partlist', 'MergeClassSpec', 'cmetrics');
		fprintf('\n%s: Total classification result:', mfilename);
		disp(cmetrics_mkstats(cmetrics));
		labellist = gtseglist(alltestIndices,:);
        labellist(:,4) = predictedclass;        

	otherwise
		error('ClassType not understood.');
end;


viewlabels = prepviewlabels(Repository, Partlist, Partindex, labellist,'MapClassSpec', MergeClassSpec);


% configure disp
if (~isempty(viewlabels))
	sysno = length(drawerobj.disp)+1;
	drawerobj.disp(sysno).type = 'Segments';
	drawerobj.disp(sysno).save = false;
	drawerobj.disp(sysno).data = viewlabels;
	drawerobj.disp(sysno).plotfunc = @marker_plotlabeling;
	labelids = unique(viewlabels(:,4));
    % (mk) ----- DEBUG
	%drawerobj.disp(sysno).plotfunc_params = { max(labelids), marker_makelabelstr([], drawerobj, min(labelids):max(labelids)) };
    drawerobj.disp(sysno).plotfunc_params = { labelids, marker_makelabelstr([], drawerobj, min(labelids):max(labelids)) };
    % ----- (mk)
	drawerobj.disp(sysno).ylabel = [drawerobj.disp(sysno).type ' [classes]'];
	drawerobj.disp(sysno).sfreq = Repository.RepEntries(Partindex).SFrq;
	drawerobj.disp(sysno).hideplot = false;
	drawerobj.disp(sysno).ylim = []; %[0 max(unique(viewlabels(:,4)))+1];
end;


%keep('Partindex', 'SimSetID', 'viewlabels');
clear MergeClassSpec filename labellist;


fprintf('\n%s: Labels loaded and display configured.', mfilename);
fprintf('\n');