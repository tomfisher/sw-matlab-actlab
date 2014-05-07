function [filename filexists] = findmarkerdatafile(Repository, Partindex, varargin)
% function [filename filexists] = findmarkerdatafile(Repository, Partindex, varargin)
%
% Find best place to store/load MARKERDATA file considering MarkerFileLocation

[MarkerFileLocation filename verbose] = process_options(varargin, 'MarkerFileLocation', '*', 'filename', '', 'verbose', 0);


% look in DATA/MARKERDATA subdir of current directory
if ~exist(filename, 'file')
	filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'subdir', 'MARKERDATA');
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') || strcmp(MarkerFileLocation, 'LocalPath'), return; end;


% look in MARKERDATA subdir of global repository directory
if ~exist(filename, 'file')
	filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'subdir', 'MARKERDATA', 'globalpath', Repository.Path);
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') || strcmp(MarkerFileLocation, 'RepositoryPath'), return; end;


% look in <datasetdir>/MARKERDATA subdir of global repository directory
if ~exist(filename, 'file')
    filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'subdir', repos_getfield(Repository, Partindex, 'Dir'), 'globalpath', Repository.Path);
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') || strcmp(MarkerFileLocation, 'RepositoryFilePath'), return; end;


% look in current directory
if ~exist(filename, 'file')
	filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKERDATA', 'globalpath', '');
end;
filexists = exist(filename,'file');
if exist(fileparts(filename),'dir') || strcmp(MarkerFileLocation, 'CurrentPath'), return; end;

