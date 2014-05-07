function PathStruct = modifypath(varargin)
% function PathStruct = modifypath(varargin)
% 
% Modify Matlab path environment
% 
% Supported modes:
% suspend - remove paths that match PathString, create PathStruct (string)
% remove - same as suspend
% restore - restore paths from PathStruct parameter (string) 
% 
% Suspend entries with voicebox and lit/matlab/netlab from path:
%   PathStruct = modifypath('Mode', 'suspend', 'PathString', {'voicebox', 'netlab'});
% Restore them:
%   modifypath('Mode', 'restore', 'PathStruct', PathStruct);
% 
% Warning: Successive 'suspend' operations change path variable and may
% change the path ordering when not restored in LIFO style. Check current
% setting with matlabpath.m
%
% Copyright 2007 Oliver Amft

[Mode PathStruct PathString Test HideNameConflict] = process_options(varargin, ...
	'Mode', 'suspend', 'PathStruct', {}, 'PathString', '', 'Test', false, 'HideNameConflict', false);

if ~iscell(PathString), PathString = {PathString}; end;
		
% fetch current path settings
currpaths = str2cellf(path, pathsep);

switch lower(Mode)
	case {'suspend', 'remove', 'rm'}
		if isempty(PathString), error('Mode requires PathString parameter.'); end;
		idx = 1; rmpos = [];
		for i = 1:length(PathString)
			matchpos = find(~isemptycell(strfind(currpaths, PathString{i})));
			for j = matchpos
				PathStruct(idx).Mode = Mode;
				PathStruct(idx).Path = currpaths{j};
				PathStruct(idx).Pos = j;
				rmpos(idx) = j; idx = idx + 1;
				if (Test), 
					fprintf('\n%s: Suspend path ''%s'' at pos %u', mfilename, PathStruct(idx-1).Path, PathStruct(idx-1).Pos); 
				end;
			end; % for j
		end; % for i
		
		currpaths(rmpos) = [];  % remove path entries

		% activate new path config
		if (~Test), path(cell2str(currpaths, pathsep));  end;
		
	case 'restore'
		if isempty(PathStruct), warning('MATLAB:modifypath', 'Mode requires PathStruct parameter, stopping.'); return; end;
		for i = 1:length(PathStruct)
			% check whether entry exist already, refuse if so
			% not needed: path => matlabpath() will check, warn and omit entry
			
			% check where to put entry
			if isempty(PathStruct(i).Pos) || abs(PathStruct(i).Pos) > length(currpaths)
				thispos = length(currpaths)+1;
				currpaths{thispos} = PathStruct(i).Path;
			else
				thispos = PathStruct(i).Pos;
				currpaths(thispos+1:end+1) = currpaths(thispos:end); % make space
				currpaths{thispos} = PathStruct(i).Path;  % insert entry
			end;
			if (Test),
				fprintf('\n%s: Restore path ''%s'' at pos %u', mfilename, PathStruct(i).Path, thispos);
			end;
		end; % for i
		
		% activate new path config
		if HideNameConflict, w = warning('query', 'MATLAB:dispatcher:nameConflict'); warning('off', 'MATLAB:dispatcher:nameConflict'); end;
		if (~Test), path(cell2str(currpaths, pathsep));  end;
		if HideNameConflict, warning(w); end;
		PathStruct = [];
end;