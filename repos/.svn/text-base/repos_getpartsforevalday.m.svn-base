function FoundPIs = repos_getpartsforevalday(Repository, Partlist, varargin)
% function FoundPIs = repos_getpartsforevalday(Repository, Partlist, varargin)
%
% Find parts from Partlist for specific evaluation day
%
% Options:
%   SearchDate: search for eval day, e.g.: SearchDate = 'Y=1975, M=8, D=16'
%   SubjectList: specify subject (default: all)
%
% See also: repos_getrecdate
%
% Copyright 2008-2009 Oliver Amft
%
% some implicit assumptions here:
% 1. Partlist is continous, no interleaving of sessions
% 2. Date can be correctly infered (e.g. keylabels are correct and existing!)

[SearchDate SubjectList verbose] = process_options(varargin, ...
    'SearchDate', [], 'SubjectList', {}, 'verbose', 1);

if ~iscell(SubjectList), SubjectList = { SubjectList }; end;
if isemptycell(SubjectList), SubjectList = repos_getsubjects(Repository, Partlist); end;

FoundPIs = repos_getpartsforsubject(Repository, Partlist, SubjectList);

% returns format: [ YYYY MM DD hh mm ss ]
dnumarray = datevec(repos_getrecdate(Repository, FoundPIs));  

% year = dnumarray(:,1); month = dnumarray(:,2);  day = dnumarray(:,3);
% date = year*1e4 + month*1e2 + day;  % formar: YYYYMMDD

% process search string
SearchDate(SearchDate==' ') = [];
searchtokens = str2cellf(SearchDate, ',');
for st = 1:length(searchtokens)
    sfields = str2cellf(searchtokens{st}, '=');
    if length(sfields)~=2,
        if verbose, fprintf('\n%s: WARNING: Could not interpret search phrase at position %u.', mfilename, st); end;
    end;

    switch upper(sfields{1})
        case {'YEAR', 'Y'}  % year
            matches = dnumarray(:,1)==str2double(sfields{2});
        case {'MONTH', 'M'}  % month
            matches = dnumarray(:,2)==str2double(sfields{2});
        case {'DAY', 'D'}  %day
            matches = dnumarray(:,3)==str2double(sfields{2});
        case {'DATE', 'YYYYMMDD'}  % search for year, month, day, format: YYYYMMDD
            matches = ( (dnumarray(:,1)==str2double(sfields{2}(1:4))) & ...
                (dnumarray(:,2)==str2double(sfields{2}(5:6))) & (dnumarray(:,3)==str2double(sfields{2}(7:8))) );
        otherwise
            if verbose, fprintf('\n%s: WARNING: Search phrase not supported at position %u.', mfilename, st); end;
            matches = true(1, size(dnumarray,1));
    end;
    FoundPIs = FoundPIs(matches);
    dnumarray = dnumarray(matches);
end; % for st