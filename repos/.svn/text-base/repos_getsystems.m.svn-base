function outval = repos_getsystems(Repository, Partindex, SysSel)
% function outval = repos_getsystems(Repository, Partindex, SysSel)
%
% Return cell list of systems strings, when System is selected with SysSel,
% return a string only.
%
% Examples:
% repos_getsystems(Repository, 101)
%       ans = 'EMG'    'WAV'
% repos_getsystems(Repository, 101, 2)
%         ans = WAV
% 
% See also: repos_getsysfromsensor, repos_getsysindex
% 
% Copyright 2006 Oliver Amft
if ~exist('SysSel','var'), SysSel = []; end;

outval = [];
if ~test('Repository.RepEntries(Partindex).Systems')
    return; 
end;

if iscell(Repository.RepEntries(Partindex).Systems)
    if isempty(SysSel)
        outval = Repository.RepEntries(Partindex).Systems;
    else
        if SysSel <= length(Repository.RepEntries(Partindex).Systems)
            outval = Repository.RepEntries(Partindex).Systems{SysSel};
        end;
    end;
else
    outval = {Repository.RepEntries(Partindex).Systems};
end;
