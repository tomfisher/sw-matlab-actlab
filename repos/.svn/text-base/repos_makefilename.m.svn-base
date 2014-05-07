function [filename fileexists] = repos_makefilename(dummy, varargin)
% function [filename fileexists] = repos_makefilename(dummy, varargin)
%
% build a file name: "DATA/<dir>/<prefix>_<indices>_<suffix>.mat"
% example:
%  repos_makefilename([], 'indices', 1, 'prefix', 'LAB', 'suffix', 'cla', 'subdir', 'labels')
%  return: DATA/LABEL/LAB_1_cla.mat
% 
% See also: dbfilename
% 
% Copyright 2005-2009 Oliver Amft
% 20080614: revised to work with >=R2007a, mat2str() method

[indices, prefix, suffix, subdir, globalpath catsep itemsep extension] = process_options(varargin, ...
    'indices', [], 'prefix', '', 'suffix', '', ...
    'subdir', '', 'globalpath', 'DATA', ...
    'catsep', '_', 'itemsep', '-', 'extension', 'mat');

% create list
indices_str = regexprep(mat2strq(indices), ' ', itemsep);
indices_str = regexprep(indices_str, '[', '');
indices_str = regexprep(indices_str, ']', '');

% build filename
filename = [];
if (~isempty(prefix)), filename = [filename prefix]; end;

if (~isempty(indices_str)) 
    if (~isempty(filename)), filename = [filename catsep]; end;
    filename = [filename indices_str]; 
end;
if (~isempty(suffix)) 
    if (~isempty(filename)), filename = [filename catsep]; end;
    filename = [filename suffix]; 
end;

filename = [filename '.' extension];
filename = fullfile(globalpath, subdir, filename);

fileexists = exist(filename, 'file');