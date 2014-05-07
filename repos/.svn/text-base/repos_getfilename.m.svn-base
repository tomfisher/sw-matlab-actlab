function [filename basedir] = repos_getfilename(Repository, Partindex, DataType, varargin)
% function [filename basedir] = repos_getfilename(Repository, Partindex, DataType, varargin)
% 
% Get complete file path and name for Partindex
% 
% Copyright 2006-2008 Oliver Amft

if ~exist('DataType', 'var'), DataType = ''; end;

[GlobalPath] = process_options(varargin, ...
    'GlobalPath', Repository.Path);

basedir = '';

% make sure that there is a file (i.e. DataType is available for Partindex)
filename = repos_getfield(Repository, Partindex, 'File', DataType);
if isempty(filename), return; end;

% shortcut filename
if (filename(1) ~= filesep) 
    % default case: combine filename
    filename = fullfile(GlobalPath, ...
        repos_getfield(Repository, Partindex, 'Dir', DataType), ...
        repos_getfield(Repository, Partindex, 'File', DataType));

    basedir = GlobalPath;
else
    % alternative: absolute filename specified
    if ispc
        error('Absolute filenames not supported under Windows.');
    end;
end;

