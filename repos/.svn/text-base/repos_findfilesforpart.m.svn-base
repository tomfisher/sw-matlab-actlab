function partfiles = repos_findfilesforpart(Repository, Partindex, varargin)
% function partfiles = repos_findfilesforpart(Repository, Partindex, varargin)
%
% Find files that belong to a Partindex
% 
% WARNING: This function is NOT generic - apply with care.
% 
% Copyright 2007 Oliver Amft

[PathMode Systems verbose] = process_options(varargin, 'PathMode', 'fullpath', ...
	'DataType', repos_getsystems(Repository, Partindex), 'verbose', 0);

partfiles = [];
for sys = 1:length(Systems)
	DataType = Systems{sys};

	[filename reposdir] = repos_getfilename(Repository, Partindex, DataType);

	if isempty(filename)
		fprintf('\n%s: Filename for DataType %s from part %u not available, skip.', mfilename, DataType, Partindex);
		continue;
	end;
	if isempty(reposdir)
		fprintf('\n%s: No BaseDir info available for DataType %s from part %u.', mfilename, DataType, Partindex);
		reposdir = fileparts(filename);
	end;

	% need to adapt filename based on DataType
	thisfile = filename; % default
	switch DataType
		case 'XSENS'
			thisfile = '';
			[thisdir xid] = fileparts(filename);
			try	tmp = ls([thisdir filesep 'MT*' xid '.*']);	catch tmp = [];
			end;

			for i = 1:size(tmp,1)
				if (tmp(1) ~= filesep)
					thisfile = strvcat(thisfile, fullfile(thisdir, tmp(i,:)) );
				else
					thisfile = strvcat(thisfile, tmp(i,:));
				end;
			end;


		case 'WAV'
			if (~exist(filename, 'file'))
				thisfile = '';
				try tmp = ls([filename '-*.wav']); catch tmp = []; end;
				[thisdir] = fileparts(filename);

				for i = 1:size(tmp,1)
					if (tmp(1) ~= filesep)
						thisfile = strvcat(thisfile, fullfile(thisdir, tmp(i,:)) );
					else
						thisfile = strvcat(thisfile, tmp(i,:));
					end;
				end;
			end;

	end; % switch


	switch lower(PathMode)
		case 'fullpath'
			partfiles = strvcat(partfiles, thisfile);

		case 'reposrelative'
			% need to extract filenames again
			for i = 1:size(thisfile)
				filename = strrep(thisfile(i,:), [reposdir filesep], '');
				partfiles = strvcat(partfiles, filename);
			end;

		case 'repospath'
			partfiles = reposdir;
			break;

		otherwise
			error('Unknown PathMode %s.', PathMode);
	end;

end; % for sys

