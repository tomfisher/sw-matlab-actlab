% main_tb_gensymbols.m
%
% Write list of class names in order of appearance. Used by ESParser.
%
% requires: 
seglist;
Classlist;
SimSetID;

% ------------------------------------------------------------------------
% write labels as text to file
% ------------------------------------------------------------------------


[fdir fname fext] = fileparts(dbfilename(Repository, 'prefix', 'LABELSYM', 'suffix', SimSetID, 'subdir', 'parser'));
filename = fullfile(fdir, [fname '.txt']);
if exist(filename, 'file') delete(filename); end;

fprintf('\n%s: Write label file: %s', mfilename, filename);
filewrite('c s', filename, ...
    ['# File generated with ' mfilename ', at ' datestr(now)], '', ...
    ['# SimSetID: ' SimSetID]);
filewrite('a pv', filename, ...
    '# classes', length(thisTargetClasses), 'int', ...
    '# TargetClasses', mat2str(thisTargetClasses), 'string', ...
    '# Partlist', mat2str(Partlist), 'string', ...
    '# Classlist', cell2str(Classlist, ', '), 'string');
filewrite('a s', filename, '# Begin of symbol sequence');

for i = 1:size(seglist,1)
    filewrite('a s', filename, Classlist{seglist(i, 4)});
end; % for i

filewrite('a s', filename, '# End of symbol sequence', '');

fprintf('\n%s: Done.\n', mfilename);