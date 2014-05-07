function ok = purish
% function ok = purish
% 
% Clean and rehash scripts

% (c) 2007 Oliver Amft, ETH Zurich

%warning('off', 'MATLAB:dispatcher:nameConflict');
ok = purge('clearbase') && purge('rehash');
%warning('on', 'MATLAB:dispatcher:nameConflict');

if (nargout == 0), clear ok; end;