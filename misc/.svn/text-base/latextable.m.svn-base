function latextable(matrix, varargin)
% function latextable(matrix, varargin)
% 
% Set latex table
% 
% RowMode, ColumnMode:
%   $ = number mode, put '$' around each element
% 

% Copyright 2007 Oliver Amft, ETH Zurich
% see also: on matrix2latex, version 1.1 (May 09, 2004) by  M. Koehler


[tabRows tabCols] = size(matrix); % data only rows/cols

[RowLabels ColumnLabels RowMode ColumnMode RowFormat ColumnFormat ...
	Filename FullTable Alignment TextSize LineTerm ...
	AddDummyRow AddDummyColumn] = process_options(varargin, ...
	'RowLabels', '', 'ColumnLabels', '', 'RowMode', '', 'ColumnMode', 'v$', 'RowFormat', '', 'ColumnFormat', '%u', ...
	'Filename', '', 'FullTable', false, 'Alignment', '', 'TextSize', '', 'LineTerm', '\n', ...
	'AddDummyRow', 0, 'AddDummyColumn', 0);


% convert matrix to cell array (table)
if isnumeric(matrix),  matrix = num2cell(matrix); end;


if (AddDummyRow)
	matrix = [num2cell(zeros(AddDummyRow, tabCols)); matrix];
	[tabRows tabCols] = size(matrix); % data only rows/cols
end;
if (AddDummyColumn)
	matrix = [num2cell(zeros(tabRows, AddDummyColumn)) matrix];
	[tabRows tabCols] = size(matrix); % data only rows/cols
end;

% use row labels, if provided
nLabelCols = size(RowLabels,1);  
if isnumeric(RowLabels), RowLabels = cellstr(num2str(RowLabels(:))); end;
if ~iscell(RowLabels), RowLabels = cellstr(num2str(RowLabels)); end;
RowLabels = expandparam(RowLabels, tabRows); 
nCols = tabCols + nLabelCols;  % total rows/cols including labels


% use column labels, if provided
nLabelRows = size(ColumnLabels,1); 
if isnumeric(ColumnLabels), ColumnLabels = cellstr(num2str(ColumnLabels(:))); end;
if ~iscell(ColumnLabels), ColumnLabels = cellstr(num2str(ColumnLabels)); end;
ColumnLabels = expandparam(ColumnLabels, tabCols); 
nRows = tabRows + nLabelRows;  % total rows/cols including labels


% display rules for rows and columns
% if (nLabelRows) && (length(RowMode)<nRows), adjust4rowlabels = true; else adjust4rowlabels = false; end;
RowMode = convertparam(RowMode, nRows);
	
% if (nLabelCols) && (length(ColumnMode)<nRows), adjust4collabels = true; else adjust4collabels = false; end;
ColumnMode = convertparam(ColumnMode, nCols);



% formatting rules for rows and columns
if (~isempty(RowFormat) && ~isempty(ColumnFormat)), 
	fprintf('\n%s: RowFormat and ColumnFormat cannot be used in parallel.', mfilename); 
	fprintf('\n%s: By default ColumnFormat is set, reset when RowFormat should be used.', mfilename);
	error('RowFormat');
end;
RowFormat = convertparam(RowFormat, nRows);
ColumnFormat = convertparam(ColumnFormat, nCols);



Alignment = convertparam(Alignment, nRows);



% add ColumnLabels, RowLabels
if (nLabelRows), matrix = [ ColumnLabels; matrix ]; end;
if (nLabelCols), 
	if (nLabelRows), matrix = [ [{''} RowLabels]' matrix ]; 
	else matrix = [ RowLabels' matrix ]; end;
end;

% order of execution: dumps, post-dump formating
AllModes = 'vasbi$<ne';
ignorecol = false(1, nCols);
% replace each element in the matrix with a string
for r = 1:nRows
	for c = 1:nCols
		thisMode = unique([ RowMode{r} ColumnMode{c} ]);
		thisFormat = [ RowFormat{r} ColumnFormat{c} ];

		for i = 1:length(AllModes)
			cmd = thisMode(strfind(thisMode, AllModes(i)));
			switch cmd
				case 'v'  % dump value
					if isnan(matrix{r, c}), matrix{r, c} = ''; end;
					matrix{r, c} = num2str(matrix{r, c}, thisFormat);
				case 'a'  % auto format
					if isnan(matrix{r, c}), matrix{r, c} = ''; end;					
					matrix{r, c} = num2str(matrix{r, c});
				case 's'  % string
					% nothing to do :-)
					if ~ischar(matrix{r, c}), matrix{r, c} = num2str(matrix{r, c}); end;
				case 'e'  % empty
					matrix{r, c} = '';
					
					
					% post-dump formatting
				case 'n'  % replace NaN by '---'
					if isnan(matrix{r, c}), matrix{r, c} = '---'; end;
					if ischar(matrix{r, c}) && (~isempty(strfind(matrix{r, c}, 'NaN')))
						matrix{r, c} = '---'; 
					end;
					
				case '$'  % add '$' 
                    if (nLabelRows) && (r==1), continue; end;
					if ~isempty(matrix{r, c}), matrix{r, c} = [ '$' matrix{r, c} '$' ]; end;
				case 'b'  % set in bold
					if ~isempty(matrix{r, c}), matrix{r, c} = [ '\textbf{' matrix{r, c} '}' ]; end;
				case 'i'  % set in italics
					if ~isempty(matrix{r, c}), matrix{r, c} = [ '\textit{' matrix{r, c} '}' ]; end;
				case '<' % append to previous column
					if ~isempty(matrix{r, c})
						matrix{r, c-1} = [ matrix{r, c-1} '~' matrix{r, c} ];
						matrix{r, c} = '';
					end;
					ignorecol(c) = true;
			end;
		end; % for i
		
	end; % for c
end; % for r



% write to file, if filename provided
if isempty(Filename), 
	fid = 1; 
else
	fid = fopen(Filename, 'w');
end;


% define alternate text size
if (~isempty(TextSize)),  fprintf(fid, '\\begin{%s}', TextSize); end;


% create header, if a full table
if FullTable
	fprintf(fid, '\\begin{tabular}{|');
	for i=1:nCols, 	fprintf(fid, '%s|', Alignment{i}); end;
	fprintf(fid, ['}' LineTerm]);

	printf(fid, ['\\hline' LineTerm]);
end;
fprintf(fid, '\n');



% print out the table
for r = 1:nRows
	for c = 1:nCols-1
		if (c==1), colsep = ''; else colsep = '&'; end;
		if ~ignorecol(c), 	fprintf(fid, ' %s %s  ', colsep, matrix{r, c});  end;
	end

	fprintf(fid, '  %s  \\\\', matrix{r, nCols});
	fprintf(fid, LineTerm);

	% hline after header rows
	if (r == nLabelRows) && (nLabelRows > 0)
		fprintf(fid, '\\hline\\hline');
		fprintf(fid, LineTerm);
	end;
end


% close table, if FullTable mode
if FullTable
	fprintf(fid, '\\end{tabular}\r\n');

	if(~isempty(TextSize)),  fprintf(fid, '\\end{%s}', TextSize); end;
end;


% close file
if ~isempty(Filename), 	fclose(fid); end;

end

% ------------- THE END ------------------


% expand a parameter to the number of requested elements
function oparam = expandparam(iparam, nelements)
if length(iparam)<nelements, 
	if length(iparam)>1, 
		%fprintf('\n%s: %s', mfilename, iparam);  %% can cause Matlab crash
		fprintf('\n%s: expected=%u, actual=%u', mfilename, nelements, length(iparam)); 
		error('Parameter size is neither one nor table size!'); 
	end;
	iparam = repmat(iparam, 1, nelements); 
end;
oparam = iparam;
end

function oparam = convertparam(iparam, nelements)
if isnumeric(iparam), iparam = cellstr(num2str(iparam(:))); end;
if ~iscell(iparam), iparam = cellstr(num2str(iparam)); end;
oparam = expandparam(iparam, nelements);
end