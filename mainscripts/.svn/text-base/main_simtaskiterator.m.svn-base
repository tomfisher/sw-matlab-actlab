% main_simtaskiterator
% 
% To be called from: main_allsim, main_simsweep, main_simbatch
% 
% See also: main_allsim, main_simsweep, main_simbatch
% 
% Copyright 2007-2008 Oliver Amft
% 
% requires:
JobList;
Partlist;
fidx;
allsim_StartTime;

if ~exist('allsim_stopafterjob','var'), allsim_stopafterjob = inf; end;

for allsim_task = 1:length(JobList)
	% break out if configonly is set
	if (allsim_task > allsim_stopafterjob), break; end;  % stop after task nr in allsim_stopafterjob

	fprintf('\n%s: Partlist: %s.', mfilename, mat2str(Partlist));
	fprintf('\n%s: Launch task %s (%s)...', mfilename, JobList{allsim_task}, datestr(now));
	fprintf('\n');

	if ~test(JobList{allsim_task})
		fprintf('\n');
		elog = errorprinter(lasterror, 'MsgOffset', 3, 'verbose', 1);  % last two not useful
		allsim_StopTime = clock;
		fprintf('\n');
		fprintf('\n%s: Runtime: %s', mfilename, my_time2str(my_timedim(etime(allsim_StopTime, allsim_StartTime), 'sec', 'hr')) );

		email(allsim_myemailaddress, [tasktitle ' FAILED.'], 'message', elog);
		error('\n%s: Sim: %s, task %s failed!', mfilename, fidx, JobList{allsim_task});
	end;
    fprintf('\n');
end; % for allsim_task

