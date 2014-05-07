function Classnumbers = repos_getclassfornames(Repository, classnames, varargin)
% function Classnumbers = repos_getclassfornames(Repository, classnames, varargin)
%
% Determine class numbers from names. Does not consider a particular RepEntry.
% 
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getpartsize, repos_getlabellist, repos_getclasses,
%   repos_getnamesforclass
% 
% Copyright 2008 Oliver Amft

[ReturnAsCells verbose] = process_options(varargin,  'ReturnAsCells', false, 'verbose', 0);

if ~iscell(classnames), classnames = {classnames}; end;
if ~isfield(Repository, 'Classlist') ||  isempty(Repository.Classlist)
    error('Could not find Classlist field in Repository structure.');
end;

% ideally, this is the fasted way of doing things:
%   Classnumbers = row(cellstrmatch(classnames , Repository.Classlist, 'exact', 'ReturnZeros', true));
% 
% here, we do it individually in order to identify missed ones
Classnumbers = zeros(1, length(classnames));
for i = 1:length(classnames)
    thismatch = strmatch(classnames{i}, Repository.Classlist, 'exact');
    if isempty(thismatch), thismatch = nan; end;
    Classnumbers(i) = thismatch;
end;


if any(isnan(Classnumbers))
    warning('repos:classforname', 'Could not find classnames: %s', cell2str(classnames(isnan(Classnumbers))));
    Classnumbers(isnan(Classnumbers)) = [];
end;

if ReturnAsCells
   Classnumbers  = vec2cells(Classnumbers);
end;