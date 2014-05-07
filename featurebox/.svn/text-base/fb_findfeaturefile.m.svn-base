function [filename filexists] = fb_findfeaturefile(Repository, Partindex, fidx, varargin)
% function [filename filexists] = fb_findfeaturefile(Repository, Partindex, fidx, varargin)
%
% Find best place to store/load feature file using priorities
% 
% Copyright 2013 Oliver Amft

[FeatureFileLocation prefix filename Priority verbose] = process_options(varargin, ...
    'FeatureFileLocation', '*', 'prefix', 'ISOFeatures', 'filename', '', 'priority', -1, 'verbose', 0);

if Priority >= 0
    fprintf('\n%s: WARNING: Parameter ''Priority'' is depricated.', mfilename);
end;


% Priority 1: global repos path with subject name subdir
if ~exist(filename, 'file')
    filename = repos_makefilename(Repository, 'prefix', prefix, 'indices', Partindex, ...
        'suffix', fb_getelements(fidx,2), 'subdir', repos_getfield(Repository, Partindex, 'Dir'), 'globalpath', Repository.Path);
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') && strcmp(FeatureFileLocation, 'RepositoryFilePath'), return; end;


% Priority 2: global repos
if ~exist(filename, 'file')
    filename = repos_makefilename(Repository, 'prefix', prefix, 'indices', Partindex, ...
        'suffix', fb_getelements(fidx,2), 'subdir', 'FEATURES', 'globalpath', Repository.Path);
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') && strcmp(FeatureFileLocation, 'RepositoryPath'), return; end;


% Priority 3: local path (fallback)
if ~exist(filename, 'file')
    filename = repos_makefilename(Repository, 'prefix', prefix, 'indices', Partindex, ...
        'suffix', fb_getelements(fidx,2), 'subdir', 'FEATURES');
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') && strcmp(FeatureFileLocation, 'LocalPath'), return; end;
