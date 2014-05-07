function [Classlist Classnumbers] = repos_getclasses(Repository, Partlist, varargin)
% function [Classlist Classnumbers] = repos_getclasses(Repository, Partlist, varargin)
%
% Determine class string lists (cell array) and corresponding numbers.
% The returned lists are ordered according to supplied Partlist.
% 
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getpartsize, repos_getlabellist, repos_getclasses
% 
% Superseds: cla_getclasses
% 
% Copyright 2006-2008 Oliver Amft

[verbose] = process_options(varargin,  'verbose', 0);

Classlist = {};
RepEntry = Repository.RepEntries;

for partidx = 1:max(size(Partlist))
    Partindex = Partlist(partidx);

    if (~isfield(RepEntry(Partindex), 'ClassAsStr')) || isempty(RepEntry(Partindex).ClassAsStr)
        
        try
            allSegLabels = repos_getlabeling(Repository, Partlist); 
            cseglist = segments2classlabels( length(Repository.Classlist), allSegLabels );

            % walk through labels and select class strings accordingly
            for class = 1:max(size(Repository.Classlist))
                if class > max(size(cseglist)), break; end;
                if ~isempty(cseglist{class})
                    Classlist = {Classlist{:} Repository.Classlist{class}};
                end;
            end; % for class
            
        catch
            fprintf('\n%s: No class labels found for part %u.', mfilename, Partindex);
            continue;
        end;

    else
        Classlist = [Classlist RepEntry(Partindex).ClassAsStr];
    end; % if
end; % for partidx

% reorder class list to reflect repository definition
Classlist = unique(Classlist);
tmp = {};
for class=1:max(size(Repository.Classlist))
    if ~isempty(strmatch(Repository.Classlist{class}, Classlist))
        tmp = {tmp{:} Repository.Classlist{class}};
    end;
end;
Classlist = tmp;


% determine class numbers
Classnumbers = [];
for class=1:max(size(Classlist))
    Classnumbers = [Classnumbers strmatch(Classlist{class}, Repository.Classlist)];
end;