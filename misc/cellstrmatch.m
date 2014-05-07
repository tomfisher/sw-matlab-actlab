function matches = cellstrmatch(cellstr, STRS, exact, varargin)
% function matches = cellstrmatch(cellstr, STRS, exact, varargin)
%
% Process strmatch() on a cell array STRS. Returns list of matches wrt STRS.
% 
% Options:
%       AllHits                - True: Returns a list of all X all hits. Default: False
%       ReturnZeros     - Default: True
% 
% Example:
%       cellstrmatch({'hn', 'hmmm', 'hn'},  {'huhu', 'haha', 'hm', 'hn'})
%   ans = [ 4   0   4 ]
% 
% See also: strmatch
% 
% Copyright 2007-2008 Oliver Amft

% OAM REVISIT: Changed behaviour, 2009/03/24

[AllHits ReturnZeros IgnoreNonStrings] = process_options(varargin, 'AllHits', false, 'ReturnZeros', true, 'IgnoreNonStrings', false);

matches = 0;
if ~AllHits
    %matches = zeros( length(STRS), 1);
    matches = zeros( length(cellstr), 1);
% else
%     % matches could be a result of multiple hits in STRS
%     matches = zeros( max(length(cellstr), length(STRS)), 1);
end;

if IgnoreNonStrings
    for i = 1:length(STRS)
        if ~ischar(STRS{i}), STRS{i} = ''; end;
    end;
end;

nextpos = 1;
for i = 1:length(cellstr)
    if (nargin<3) || isempty(exact) % stupid, but this is how MATLAB is checking it
        thismatch = strmatch(cellstr{i}, STRS);
    else
        thismatch = strmatch(cellstr{i}, STRS, exact);
    end;
    
    if ~isempty(thismatch)
        if ~AllHits, thismatch = thismatch(1); end;
        
        % copy to results vector
        matches(nextpos:nextpos+length(thismatch)-1) = thismatch; 
    end;

    % need to maintain pointer for const array
    if ~AllHits, nextpos = nextpos+1;
    else nextpos = nextpos+length(thismatch); end;
end;

% remove zeros from list
if (ReturnZeros == false), matches(matches==0) = []; end;
    
% remove trailing positions
if (AllHits == false) && (nextpos < length(matches))
    matches(nextpos:end) = [];
end;

matches = col(matches);