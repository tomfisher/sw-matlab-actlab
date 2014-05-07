function [outval found] = repos_getfield(Repository, Partindex, fieldname, system, verbose)
% function [outval found] = repos_getfield(Repository, Partindex, fieldname, system, verbose)
%
% Only RepEntry.System is permitted to be accessed directly. All other
% fields in Repository.RepEntries shall be accessed via this function.
%
% Copyright 2006-2009 Oliver Amft
found = true;

if ~exist('system','var') || isempty(system), system = repos_getsystems(Repository, 1); end;
if iscell(system),  system = system{1};  end;
%     if length(system)==1,
%         system = system{1};
%     else
%         error('Only one system supported at a time.');
%     end;
if ~exist('verbose', 'var'), verbose = 0; end;

try
    if isstruct(Repository.RepEntries(Partindex).(fieldname))
        if isfield(Repository.RepEntries(Partindex).(fieldname), system)
            outval = Repository.RepEntries(Partindex).(fieldname).(system);
        else
            % use ALL field if no specific match is found
            outval = Repository.RepEntries(Partindex).(fieldname).ALL;
        end;
    else
        % use entry directly if it contains no structure
        outval = Repository.RepEntries(Partindex).(fieldname);
    end;
catch
    if (verbose)
        fprintf('\n%s: Field not found: RepEntries(%u).%s.%s', ...
            mfilename, Partindex, fieldname, cell2str(system,','));
        fprintf('\n%s: Fallback field not found : RepEntries(%u).%s.%s', ...
            mfilename, Partindex, fieldname, 'ALL');
    end;
    outval = [];  found = false;
end;