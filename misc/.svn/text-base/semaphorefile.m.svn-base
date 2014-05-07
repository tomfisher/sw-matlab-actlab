function [success jobdesc_read] = semaphorefile(filename, jobdesc, varargin)
% function [success jobdesc_read] = semaphorefile(filename, jobdesc, varargin)
% 
% Operations to check, set and remove a semaphore file. This is used to avoid race
% conditions in parallelised code.
% 
% Copyright 2008 Oliver Amft


[operation setdelay verbose] = process_options(varargin, 'operation', 'exists', 'setdelay', 3, 'verbose', 1);
success = false;  jobdesc_read = '';
[fpath fname] = fileparts(filename); filename = fullfile(fpath, [fname '.mat']);

switch lower(operation)
	case 'set'		% set: check if exists, then write it and check if correctly set
		if isempty(jobdesc), error('Parameter jobdesc is empty.'); end;
		
		[semaphoreset jobdesc_read] = semaphorefile(filename, '', 'operation', 'exists', 'verbose', verbose);
		if (semaphoreset)
			if (verbose), fprintf('\n%s: Semaphore already set by job %s.', mfilename, jobdesc_read); end;
			success = false;
			return;
		end;
		
		if (verbose), fprintf('\n%s: Writing lock for file %s...', mfilename, filename); end;
		save(filename, 'jobdesc');
		if (verbose), countdown(setdelay, 'verbose', 0); else pause(setdelay); end;
		[success jobdesc_read] = semaphorefile(filename, jobdesc, 'operation', 'check', 'verbose', verbose);
		
	case 'check'		% check that jobdesc is correct; success: 1=is identical, 0=is not/not existing 
		[success jobdesc_read] = semaphorefile(filename, '', 'operation', 'exists', 'verbose', verbose);
		if (success) && (~strcmp(jobdesc, jobdesc_read))
			if (verbose), fprintf('\n%s: WARNING: Interference detected with job %s.', mfilename, jobdesc_read); end;
			success = false;
		end;
		
	case 'exists'		% report jobdesc and success: 1=exists, 0=does not
		if exist(filename, 'file')
			try
				jobdesc_read = loadin(filename, 'jobdesc');
			catch
				error('Semaphore file %s exists, but is corrupted.', filename);
			end;
			if isempty(jobdesc_read)
				if (verbose), fprintf('\n%s: Semaphore file %s exists, but is jobdesc is empty.', mfilename, filename); end;
				success = false;
			else
				if (verbose), fprintf('\n%s: Semaphore file %s read successfully.', mfilename, filename); end;
				success = true; 
			end;
		else
			if (verbose), fprintf('\n%s: No semaphore file %s found.', mfilename, filename); end;
			success = false;
		end;
		
	case 'rm'		% delete
		if ~semaphorefile(filename, '', 'operation', 'exists', 'verbose', verbose), 
			return; 
		end;
		if ~isempty(jobdesc)
			[success jobdesc_read] = semaphorefile(filename, jobdesc, 'operation', 'check', 'verbose', verbose);
			if ~success
				% if there is a semaphore, but the jobdesc differs, do not remove it!  
				if (verbose), fprintf('\n%s: Semaphore file %s NOT removed.', mfilename, filename); end;
				return;
			end;
		end;
		
		rstate = recycle; recycle('off');
		delete(filename);
		recycle(rstate);
		if (verbose), fprintf('\n%s: Removed semaphore file %s.', mfilename, filename); end;
		success = true;
		
	otherwise
		error('Operation %s not supported.', lower(operation));
end;

