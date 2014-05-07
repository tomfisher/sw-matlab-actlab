function ok = serial_clearrxbuffer(ph, varargin)
% function ok = serial_clearrxbuffer(ph, varargin)
%
% Empty read buffer
% ...a port nirvana as well ;-)
ok = false;

[CheckTime Timeout verbose] = process_options(varargin, ...
	'checktime', 0.1, 'Timeout', 1, 'verbose', 0);

% verify empty read buffer
while (get(ph, 'BytesAvailable')) && (Timeout > 0)
	if (verbose) 
		fprintf('\n%s: Read buffer for port %u not empty, cleaning up.', mfilename, ph);
	end;
	try	fread(ph, get(ph, 'BytesAvailable'));
	catch return; end;
	pause(CheckTime);
	Timeout = Timeout - CheckTime; % this is a hack!
end;

ok = true;
