function [filename fileexists] = repos_findlabelfile(Repository, Partindex, varargin)
% function [filename fileexists] = repos_findlabelfile(Repository, Partindex, varargin)
% 
% Search at different places for labeling file
% 
% See also: repos_findfilesforpart
% 
% Copyright 2009 Oliver Amft


% labelfile as specified in Repository structure
filename = repos_getfield(Repository, Partindex, 'labelfile', [], 0);
fileexists = exist(filename, 'file');
if (fileexists), return; end;

% DATA/labels/MARKER_<Partindex>.mat
[filename fileexists] = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKER', 'subdir', 'labels');
if (fileexists), return; end;

% DATA/labels/CLA_<Partindex>.mat
[filename fileexists] = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', 'labels');
if (fileexists), return; end;

% ./MARKER_<Partindex>.mat
[filename fileexists] = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKER');
if (fileexists), return; end;


% set defaults
fileexists = false;
[filename found] = repos_getfield(Repository, Partindex, 'labelfile', [], 0);
if (found), return; end;

filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'MARKER', 'subdir', 'labels');
