% main_simbatch
%
% This is an alternate frontend for main_allsim. Not yet clear, how to
% generalise this code.  Works for ONE subject only.
%
% Procedure:
% - initialise allsim_jobspec
% - run this script
%
% see also: main_allsim, main_simsweep

keep('fidx', 'allsim_*');
clear allsim_stopafterjob;

allsim_batchmode = true;
allsim_dontwait = true;

if ~exist('fidx', 'var'), fidx = 'unknown'; end;
initdata; allsim_jobspec;
if ~exist('JobList', 'var'), error('Variable JobList not found. Probably fidx setting is not defined in allsim_jobspec.'); end;
if ~exist('allsim_iteratejobs', 'var'),  allsim_iteratejobs = length(JobList);  end;
if ~exist('allsim_stopafterjob', 'var') || (allsim_stopafterjob> min(allsim_iteratejobs)-1)
    allsim_stopafterjob = min(allsim_iteratejobs)-1;
end;

if ~exist('allsim_batchinit', 'var'), allsim_batchinit = ''; end;
if ~exist('allsim_batchcommands', 'var'), allsim_batchcommands = { '' }; warning('MATLAB:main_simbatch', 'Batch commands not found.'); end;
if ~exist('allsim_batchlog', 'var'), allsim_batchlog = ''; end;


% OAM REVISIT: hack to initialise environment
% sets var 'SubjectList'
main_allsim;



VERSION = 'V010';
fprintf('\n%s: %s', mfilename, VERSION);

eval(allsim_batchinit);
allsim_batchfilename = fullfile('DATA', 'LOG', ['simbatch_' strrep(tasktitle,' ','_') '.log']);
fprintf('\n%s: Logging to: %s', mfilename, allsim_batchfilename);
filewrite('c s', allsim_batchfilename, ...
    ['# Log file: ' tasktitle], ...
    ['# File created with ' mfilename ', version ' VERSION ' at ' datestr(now)], ...
    '# Copyright 2008 Oliver Amft, amft@ieee.org', '');

JobList = JobList(allsim_iteratejobs);  % reduce JobList to useful ones
allsim_stopafterjob = max(allsim_iteratejobs);

% loop for batch jobs
clear LogMsg;  estr = '';
for allsim_batchcmd = 1:length(allsim_batchcommands)
    fprintf('\n%s: Running batch commands: %s', mfilename, allsim_batchcommands{allsim_batchcmd});
    eval( allsim_batchcommands{allsim_batchcmd} );
    if exist('LogMsg','var')
        filewrite('a s', allsim_batchfilename, ['# ' LogMsg]);
        clear LogMsg;
    end;

    try
        %main_simtaskiterator;


        % -- (mk) Commands to process more than one subject ---------------
        for subjectnr = 1:length(SubjectList)
            Subject = SubjectList{subjectnr};
            fidxel = fb_getelements(fidx);
            SimSetID = [Subject fidxel{2:end}];

            fprintf('\n%s: Subject: %s  SimSetID: %s', mfilename, Subject, SimSetID);

            % (mk) Added 'daysvalidation' mode
            %if (strcmpi('intrasubject', UserMode))
            switch lower(UserMode)
                case {'intrasubject', 'daysvalidation'}
                    Partlist = repos_getpartsforsubject(Repository, Parts, Subject);
                    
                otherwise
                    ...
            end;
        
            if isempty(Partlist), continue; end;


            main_simtaskiterator;
        end; % for subjectnr

    catch
        estr = errorprinter(lasterror);  fprintf(estr);
        filewrite('a s', allsim_batchfilename, ' ', ' ', estr);
        break;
    end;

    filewrite('a s', allsim_batchfilename, ['# ' datestr(now)]);
    if isempty(allsim_batchlog), str = ''; else str = eval( allsim_batchlog );   end;
    if isempty(str), str = repmat(' ',1,4); end;
    filewrite('a pv', allsim_batchfilename, num2str(allsim_batchcmd, 'R%u'), str(3:end), 'string');
end; % for allsim_task

if isempty(estr)
    % all fine
    str = '';
    str = strappend( str, sprintf('\n%s: All jobs completed: %s', mfilename, fidx) );
    email_subject = [tasktitle ' DONE.'];
else
    % error
    str = estr;
    str = strappend( str, sprintf('\n%s: Job error: %s', mfilename, fidx) );
    email_subject = [tasktitle ' FAILED.'];
end;

% fprintf('\n%s: Jobs completed: %s', mfilename, fidx);
% filewrite('a s', allsim_batchfilename, ' ', sprintf('# Jobs completed: %s', fidx), ' ', ' ');
%
% %email('oam@ife.ee.ethz.ch', [tasktitle ' DONE.']);
allsim_StopTime = clock;
% fprintf('\n%s: Start: %s', mfilename, datestr(allsim_StartTime));  filewrite('a s', allsim_batchfilename, sprintf('# Start: %s', datestr(allsim_StartTime)));
% fprintf('\n%s: Stop: %s', mfilename, datestr(allsim_StopTime));  filewrite('a s', allsim_batchfilename, sprintf('# Stop: %s', datestr(allsim_StopTime)));
% fprintf('  runtime: %s', my_time2str(my_timedim(etime(allsim_StopTime, allsim_StartTime), 'sec', 'hr')) );
filewrite('a s', allsim_batchfilename, ' ', sprintf('# runtime: %s', my_time2str(my_timedim(etime(allsim_StopTime, allsim_StartTime), 'sec', 'hr')) ));

str = strappend( str, sprintf('\n%s: Start: %s', mfilename, datestr(allsim_StartTime)) );
str = strappend( str, sprintf('\n%s: Stop: %s', mfilename, datestr(allsim_StopTime)) );
str = strappend( str, sprintf('  runtime: %s', my_time2str(my_timedim(etime(allsim_StopTime, allsim_StartTime), 'sec', 'hr')) ) );
str = strappend( str, sprintf('\n%s: Session CPU time: %s', mfilename, my_time2str(my_timedim(cputime, 'sec', 'hr'), 'ShowDays', false) ) );
str = strappend( str, sprintf('\n\n') );
fprintf(str);

email(allsim_myemailaddress, email_subject, 'message', str);
fprintf('\n\n');
