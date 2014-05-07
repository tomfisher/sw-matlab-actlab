% initmain
%
% default initialisations
% 
% Copyright 2005-2009 Oliver Amft

initdata;

if ~exist('TargetClasses', 'var'), TargetClasses = Repository.TargetClasses; end;
fprintf('\n%s: TargetClasses = %s', mfilename, strcut(mat2str(TargetClasses), 'CutLength', 40));

if ~exist('batchmode', 'var'), pause(2); end;

% Do label ID configuration
if ~exist('initmain_classconfig', 'var'), initmain_classconfig = true; end;

% Do labels configuration
if ~exist('initmain_loadlabellist', 'var'), initmain_loadlabellist = true; end;

% Do run child scripts initmain_*
if ~exist('initmain_runchildren', 'var'), initmain_runchildren = false; end;


% ------------------------------------------------------------------------
% class ID configuration
% * use MergeClassSpec to renumber label IDs, if needed
% * load labels
% ------------------------------------------------------------------------
% requires: Partlist TargetClasses, (MergeClassSpec)
% returns : MergeClassSpec labellist_load labellist partoffsets thisTargetClasses Classlist LabelGroup
%
% labellist: depends on MergeClassSpec, TargetClasses, Partlist

if (initmain_classconfig)
	if ~test('Partlist'), Partlist = Partindex; end;
	if (~test('MergeClassSpec')) || isempty(MergeClassSpec)
		MergeClassSpec = num2cell(TargetClasses);
% 	else
% 		MergeClassSpec = segment_checkmergeclassspec(MergeClassSpec, TargetClasses);
	end;
	if (initmain_loadlabellist)
		[labellist_load partoffsets] = repos_getlabellist(Repository, Partlist);
	end;
    
    fprintf('\n%s: Merging classes: %s...', mfilename, cell2str(MergeClassSpec, ','));
    [labellist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load);
	if isempty(labellist), 
		warning('MATLAB:initmain', 'No target classes found.'); 
		thisTargetClasses = TargetClasses;
		fprintf('\n%s: Setting thisTargetClasses=%s', mfilename, mat2str(thisTargetClasses));
	end;
	if any(segment_size(labellist)==0), warning('initmain:zerolabels', 'Some labels have zero size.'); end;

	fprintf('\n%s: Classes: %s', mfilename, mat2str(thisTargetClasses));
	fprintf('\n%s: Labels: %u, selected+merged: %u', mfilename, size(labellist_load,1), size(labellist,1));
	Classlist = Repository.Classlist(TargetClasses); %Repository.Classlist(thisTargetClasses);
	%LabelGroup = cla_findlabelgroupforclass(Repository,thisTargetClasses);
	SampleRate = repos_getmarkersps(Repository, Partlist(1), 'singlesps', true);
end;


% ------------------------------------------------------------------------
% run local initmain scripts
% ------------------------------------------------------------------------
% this is typically not used - too dangerous to break something

if (initmain_runchildren)
	scripts = dir('initmain_*');
	for f = 1:length(scripts)
		if (exist(scripts.name,'file') ~= 2), continue; end;
		[dummy fname fext] = fileparts(scripts(f).name);
		if (~strcmpi(fext, '.m')), continue; end;

		fprintf('\n%s: Running child: %s...', mfilename, [fname fext]);
		eval(fname);
	end;
end;

fprintf('\n%s: Done.', mfilename);
