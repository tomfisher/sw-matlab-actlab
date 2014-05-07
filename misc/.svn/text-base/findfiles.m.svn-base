function files = findfiles(searchpattern, varargin)
% function files = findfiles(searchpattern, varargin)
% 
% Find files/directories using search pattern
%
% Options:
% ftype - Specify file/dir/all to return
% 
% Copyright 2007 Oliver Amft

% OAM REVISIT: outcome from cla_getlabelgroupfiles.m endevours

[ftype recursive notfoundmode returnmode] = process_options(varargin, ...
	'ftype', 'f', 'recursive', false, 'notfoundmode', 'ignore', 'returnmode', 'all');

[pathstr,name,ext,versn] = fileparts(searchpattern);

% search for files and store result in filenames cell array
fdir = dir(searchpattern);
files = {};

% process content of current directory
for i = 1:length(fdir)
	ismatch = false;
	thisfile = fullfile(pathstr, fdir(i).name);
	switch lower(ftype)
		case {'*', 'all'}
			ismatch = true;
		case {'f', 'file'}
			if (~fdir(i).isdir) && exist(thisfile, 'file')
				ismatch = true;
			end;
		case {'d', 'dir'}
			if fdir(i).isdir && exist(thisfile, 'dir'),  
				ismatch = true;
			end;
		otherwise
			error('ftype not supported.');
	end; % switch lower(ftype)

	if ismatch, files = {files{:} fullfile(pathstr, fdir(i).name)}; end;
end;

if recursive
	fdir = dir(fullfile(pathstr, '*'));
	for i = 1:length(fdir)
		if fdir(i).isdir && ~strcmp(fdir(i).name, '.') && ~strcmp(fdir(i).name, '..')
			% continue recursively
			thisfiles = findfiles(fullfile(pathstr, fdir(i).name, [name ext]), ...
				'ftype', ftype, 'recursive', true, 'notfoundmode', notfoundmode, 'returnmode', returnmode);
			files = {files{:} thisfiles{:}};
		end;
	end;
end; % if recursive


% handle notfoundmode
if isempty(files) 
	switch lower(notfoundmode)
		case 'raiseerror'
			fprintf('\n%s: Search pattern: %s', searchpattern);
			error('No file found that matched search.');
		case {'ignore', 'empty'}
			% nothing to do here
		otherwise
	end;
end;

% handle returnmode
switch lower(returnmode)
	case 'all'
	case 'first'
		if ~isempty(files),  files = files{1}; end;
end;