function narray = cell2array(carray,missingdata)
% function narray = cell2array(carray,missingdata)
% 
% Convert cell vector of numeric column vectors to numeric array
% Pads incomplete columns with missing data value
% 
% Copyright 2006 Oliver Amft, ETH Zurich

% find number of rows of returned cells
nrows = cellfun('size',carray,1);

% find incomplete columns (with less rows than max rows);
rowpadding = max(nrows) - nrows; % shortfall in rows for each column
incomplete = find(rowpadding > 0);

% pad incomplete 
for i = incomplete
    carray{i} = [ carray{i}; repmat(missingdata, rowpadding(i),1) ];
end
% convert cell array to numeric array
narray = [carray{:}];
