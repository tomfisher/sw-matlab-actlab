% main_reposcleanout
% 
% Move files that belong to Partlist from repository to some other place.
% 
% requires
Partlist;

VERSION = 'V001';
fprintf('\n%s: %s', mfilename, VERSION);

initdata;

% ------------------------------------------------------------------------
%% Configuration
% ------------------------------------------------------------------------
if (exist('DumpDir','var') ~=1) DumpDir = 'D:\Oli\to_backup\reposbackup'; end;
if (~exist(DumpDir, 'dir'))
    fprintf('\n%s: Creating backup directory: %s', mfilename, DumpDir);
    mkdir(DumpDir);
end;

if (exist('YesDoWrite','var') ~=1) YesDoWrite = false; end;
fprintf('\n%s: YesDoWrite: %s', mfilename, mat2str(YesDoWrite));

% ------------------------------------------------------------------------
%% Find files and move em
% ------------------------------------------------------------------------
for partnr = 1:length(Partlist)
	Partindex = Partlist(partnr);
    fprintf('\n\n%s: Porcessing part %u...', mfilename, Partindex);

    partfiles = repos_findfilesforpart(Repository, Partindex, 'PathMode', 'reposrelative');
    partbasedir = repos_findfilesforpart(Repository, Partindex, 'PathMode', 'repospath');
    
    % move files for part individually
    for f = 1:size(partfiles,1)
        [fpathstr,fname,fext] = fileparts(partfiles(f,:));
        backupdir = [DumpDir filesep fpathstr];
        backupfile = [backupdir filesep fname fext];
        sourcefile = [partbasedir filesep partfiles(f,:)];
        
        if (~exist(backupdir, 'dir'))  mkdir(backupdir); end;
        
        fprintf('\n%s: Moving file... \n  from: %s \n    to: %s', mfilename, sourcefile, backupfile);
        if YesDoWrite
            [ok emessage] = movefile(sourcefile, backupfile);
            if ~ok
                fprintf('\n%s: Error while moving, stopping.', mfilename);
                fprintf('\n%s: Error message:', mfilename);
                emessage
                error('Stop.');
            end;
        end;
        
    end; % for f 
end; % for partnr 

fprintf('\n');
if (YesDoWrite)
    fprintf('\n%s: Setting YesDoWrite to false.', mfilename);
    YesDoWrite = false;
else
    fprintf('\n%s: Simulated only, use YesDoWrite = true to really write.', mfilename);
end;
fprintf('\n%s: Done.\n', mfilename);
