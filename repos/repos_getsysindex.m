function outval = repos_getsysindex(Repository, Partindex, System)
% function outval = repos_getsysindex(Repository, Partindex, System)
%
% Return index of system from systems string 'System'
% 
% See also: repos_getsysfromsensor, repos_getsystems
% 
% Copyright 2007 Oliver Amft
outval = [];
if ~exist('System', 'var'), return; end;

outval = strmatch(System, repos_getsystems(Repository,Partindex));
