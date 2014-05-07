function [filename filexists] = spot_findfeaturefile(Repository, Partindex, thisClass, fidx, Subject, varargin)
% function filename = spot_findfeaturefile(Repository, Partindex, thisClass, fidx, Subject, varargin)
%
% Find best place to store/load feature file using priorities
% 
% Copyright 2008 Oliver Amft

[Priority verbose] = process_options(varargin, 'priority', 1, 'verbose', 0);

%filexists = false; filename = '';

% Priority 1: global repos path with subject name subdir
filename = repos_makefilename(Repository, 'prefix', 'SFeatures' , 'indices', [Partindex thisClass], ...
	'suffix', fb_getelements(fidx,2), 'subdir', Subject, 'globalpath', fullfile(Repository.Path, 'FEATURES'));

filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') && (Priority<=1), return; end;


% Priority 2: global repos
filename = repos_makefilename(Repository, 'prefix', 'SFeatures' , 'indices', [Partindex thisClass], ...
	'suffix', fb_getelements(fidx,2), 'subdir', 'FEATURES', 'globalpath', Repository.Path);

filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') && (Priority<=2), return; end;


% Priority 3: local path (fallback)
filename = repos_makefilename(Repository, 'prefix', 'SFeatures' , 'indices', [Partindex thisClass], ...
	'suffix', fb_getelements(fidx,2), 'subdir', 'FEATURES' );

filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') && (Priority<=3), return; end;


if (verbose)
	fprintf('\n'); 
end;
warning('main_spotfeatures:featurefile', 'Using local directory instead of Repository for feature files (if applicable).');