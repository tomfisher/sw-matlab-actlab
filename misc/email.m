function ok = email(address, subject, varargin)
% function ok = email(address, subject, varargin)
%
% Send a mail using Java subsystem or cmd line mail service
% 
% Copyright 2006-2009 Oliver Amft

ok = false;
if isempty(address), fprintf('\n%s: No email address found to send message, stop.', mfilename); return; end;

[message attachmentfiles useJavaMail verbose ] = process_options(varargin, ...
    'message', '', 'attachmentfiles', {}, 'useJavaMail', false, 'verbose', 0);

if ~iscell(attachmentfiles), attachmentfiles = {attachmentfiles}; end;

if ( usejava('jvm') && useJavaMail )
    % Matlab implementation requires JAVA
    setpref('Internet','SMTP_Server','mail');
    sendmail(address, subject, message, attachmentfiles);
	
else

    if useJavaMail, warning('email:useJavaMail', 'Could not send mail using JVM. Falling back to CLI.'); end;
    if ispc, error('Not supported.'); end;
    
	[r s] = system('which mail');
	if isempty(s), fprintf('\n%s: No email service available.', mfilename); return; end;
	
    %echo "test" | mail -s testsubject oam@ife.ee.ethz.ch
    %echo "test" | mail -s "testsubject2" oam@ife.ee.ethz.ch
    
    message = regexprep(message, '"', '''');  % need to replace " sign in text (shell issue)
    
    mailcommand = [ 'echo "' message '" | mail' ' -s "' subject '"' ];
    if ~isempty(attachmentfiles)
        for i = length(attachmentfiles)
            mailcommand = [ mailcommand ' -a ' attachmentfiles{i} ];
        end;
    end;
    mailcommand = [ mailcommand ' ' address ];
    
    if (verbose), fprintf('\n%s: Mail command: %s', mfilename, mailcommand); end;
    
    r = system(mailcommand);
    if isempty(r) || r==0
        ok = true; 
    else
        fprintf('\n%s: Failed, system response:', mfilename);
        disp(r);
    end;
end;