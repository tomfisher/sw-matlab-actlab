function filenames = repos_getfilegroup(basefile, varargin)
% function filenames = repos_getfilegroup(basefile, varargin)
%
% Find files belonging to a group. (Based on cla_getlabelgroupfiles) 
%
% Calling variants:
% => return basefile if exist
%  cla_labelgroupfiles('DATA/labels/CLA_1.mat')
% => return all relevant files, including basefile
%  cla_labelgroupfiles('DATA/labels/CLA_1.mat','*') 
% => return filename for LabelGroup "SwallowClasses" if exist. 
%   cla_labelgroupfiles('DATA/labels/CLA_1.mat','SwallowClasses') 
% 
% Returns {} if no file was found.
% 
% Copyright 2006-2008 Oliver Amft

[FileGroup DefaultFile UseDefaultFile] = process_options(varargin, ...
    'FileGroup', '', 'DefaultFile', basefile, 'UseDefaultFile', false);

if (~exist('FileGroup','var')), FileGroup = ''; end;
filenames = {};

% return basefile, if existing
if isempty(FileGroup) 
    if (exist(basefile, 'file')), filenames{end+1} = basefile; end;
    return;
end;

% look for FileGroup files
[pathstr,name,ext,versn] = fileparts(basefile);
searchpattern = fullfile(pathstr,[name,'_',FileGroup,ext]);

% search for files and store result in filenames cell array
fdir = dir(searchpattern);
for i = 1:length(fdir)
    thisfile = fullfile(pathstr, fdir(i).name);
    if ~exist(thisfile, 'file'), continue; end;

    filenames{end+1} = thisfile;
end;

% include basefile, if all files requested OR DefaultFile is set and
% nothing was found before.
if (strcmp(FileGroup, '*')) || ( (~isempty(DefaultFile)) && (UseDefaultFile) && isempty(filenames) )
    if (exist(basefile, 'file')), filenames{end+1} = basefile; end;
end;
