function [index sidx] = findlongestmatch(LookupTable, Query, varargin)
% function [index sidx] = findlongestmatch(LookupTable, Query, varargin)
% 
% Find longest match for Query in LookupTable.
%
% Parameters:
% wildcard          Set table wildcard value, default: 0
% permitoversize    Allow oversized request to return (best) match,
%                   default: true
% returnlist        List of return values; default: table rows

[lookup_entries longest_lookup] = size(LookupTable);
query_length = length(Query);


[wildcard permitoversize returnlist] = process_options(varargin, ...
    'wildcard', 0, 'permitoversize', true, 'returnlist', []);

% do not search if Query is oversizes for table
if (query_length > longest_lookup) && (~permitoversize)
    index = [];
    return;
end;

% order LookupTable longest entry first
for i = 1:lookup_entries
    wcorder(i) = length(find(LookupTable(i,:) == wildcard));
end;
[dummy sidx] = sort(wcorder);
sortedlookuptable = LookupTable(sidx,:);

% use table row if no return value list is provided
if isempty(returnlist) 
    returnlist = 1:lookup_entries; 
end;
returnlist = returnlist(sidx,:);

% perform longest match search (slow!)
for (index = 1:lookup_entries)

    found = true;
    for e = 1:longest_lookup
        if (sortedlookuptable(index, e) == wildcard) break; end;
        
        if (e > query_length) found = false; break; end;

        if (sortedlookuptable(index, e) ~= Query(e)) found = false; break; end;
%         if (e == query_length) 
    end;
    
    if (found) break; end;
end;

index = returnlist(index);

if (~found) index = []; end;
