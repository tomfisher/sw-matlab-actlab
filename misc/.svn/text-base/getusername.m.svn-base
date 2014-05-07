function UserName = getusername

[ret UserName] = system('echo $USER');
if ret, UserName = 'Default'; end;      % ret ~= 0 means that there was an error

if strcmpi(UserName, 'default')
    t = str2cell(fileparts(pwd), filesep);
    if length(t)<2 || (~strcmpi(t{1}, 'home')), 
        UserName = 'Default'; % if top level dir is not home, guess we not not know where we are
    else
        UserName = t{2};
    end;      
end;
    
UserName =  regexprep(UserName, '[\x01-\x1F]', '');     % strip any non-printable chars
