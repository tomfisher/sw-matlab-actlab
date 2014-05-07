function ok = purge(Mode)
% function ok = purge(Mode)
% 
% Issue the cleanup/refresh commands in the callers workspace (short form)

% (c) 2007 Oliver Amft, ETH Zurich

if (exist('Mode', 'var')~=1), Mode = 'clean'; end;

ok = true;

switch lower(Mode)
    case {'clean', 'clear'}
        try
            evalin('caller', 'clear all; close all;');
        catch
            ok = false;
        end;
    
    case {'clearbase'}
        try
            evalin('base', 'clear all; close all;');
        catch
            ok = false;
        end;
    
    case {'update', 'rehash'}
        rehash pathreset;
        rehash toolboxreset;
        rehash toolboxcache;
end;

if (nargout == 0), clear ok; end;
