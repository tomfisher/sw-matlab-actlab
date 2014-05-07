% main_compareclafiles
% 
% compare CLA files

% Partlist = 75:318
% dir1 = 'labels'
% dir2 = 'martinlabels'

Partlist;
dir1;
dir2;

initdata;

for Partindex  = Partlist
	if any(isemptycell(repos_getsystems(Repository, Partindex))), continue; end;
	
	fprintf('\n%s: Check PI %u...', mfilename, Partindex);
	file1 = dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', dir1);
	file2 = dbfilename(Repository, 'indices', Partindex, 'prefix', 'CLA', 'subdir', dir2);
	if (~exist(file1, 'file')) && (~exist(file2, 'file')), fprintf(' both files missing.'); continue; end;
	if ~exist(file1, 'file'), fprintf(' file 1 missing.'); continue; end;
	if ~exist(file2, 'file'), fprintf(' file 2 missing.'); continue; end;
	
	
	isequal = marker_cmpclafiles(file1, file2, 'verbose', 0);
	if isequal, fprintf(' OK');  end;
end;

fprintf('\n');
