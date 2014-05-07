function data = readtextfilecols(filename, cols, rows)
% function data = readtextfilecols(filename, cols, rows)
%
% Read a text file, data values in rows and columns. Paramters start at 1.
%
% Example: read all lines from text file huhu.txt, columns 1 to 10:
%       data = readtextfilecols('huhu.txt', [1 inf], [1 10]
% 
% Copyright 2006-2008 Oliver Amft

% OAM REVISIT
% Todo: Column number detection
% Exact max. number of columns must be provided in cols parameter!

if exist(filename,'file')~=2
    % Double printout needed sich error message is caught by try embedded code.
    fprintf('\n%s: File does not exist: %s\n', mfilename, filename);
    error('File does not exist.');
end;

% return lines in file (instances)
if (nargin<2)
    [r s] = system(['wc -l ' filename]);
    data = str2num(strtok(s));
    return;
end;


if (~exist('rows','var')) || isempty(rows), rows = [1 inf]; end;
if (~exist('cols','var')) || isempty(cols), cols = [1 inf]; end;

rows = rows -1;

if (rows(2) == inf)
    rows(2) = -2; % Result will be -1; textscan will read the whole file
end;


% Automatic column detection
fid = fopen(filename);

% skip over comment lines ('#'), if any
commentlines = 0;
dummy = fgetl(fid); 
while dummy(1) == '#'
    dummy = fgetl(fid); 
    commentlines = commentlines +1; % count comment lines
end;
fclose(fid);

if(dummy < 0)
	data = [];
	return;
end;

% get individual columns and check whether these can be interpreted to be numericals
% TODO: guess delimiter
c = str2cellf(dummy, 9); % assume tabs ('\t') here

maxcols2 = length(sscanf(dummy, '%f', inf));
maxcols = length(c);
if (maxcols2>maxcols), error('Columns estimate inaccurate. Maybe no tabs used as delimiter?'); end;

c_isnum = false(1, maxcols);
for i = 1:maxcols, c_isnum(i) = isnumeric_str(c{i}); end;

% check column numbers...
if (cols(2) == inf), cols(2) = maxcols; end;
if (max(cols) > maxcols), error('Requested columns not available.'); end;
rows = rows + commentlines;


% generate reading mask for textscan()
% readmask = repmat('%f ', 1, maxcols);
% readmask = repmat('%f32 ', 1, maxcols);
readmask = '';
for i = 1:maxcols
    if c_isnum(i), readmask = [ readmask, '%f ' ]; end;
    if ~c_isnum(i), readmask = [ readmask, '%s ' ]; end;
end;


% read data file
fid = fopen(filename);
%dummy = textscan(fid, readmask, rows(2)-rows(1)+1, 'headerlines', rows(1), 'headercolumns', cols(1) );
dummy = textscan(fid, readmask, rows(2)-rows(1)+1, 'headerlines', rows(1) );
fclose(fid);

if ~all(c_isnum), fprintf('\n%s: WARNING: There are non-numerical columns in the data, setting to zero.', mfilename); end;

%data = cell2mat(dummy(c_isnum));
% Replace non-numerical columns with zero. This will maintain column order as the caller may expect.
for i = 1:maxcols
    if ~c_isnum(i), dummy{i} = zeros( size(dummy{i},1) ,1); end;
end;
data = cell2mat(dummy);

% data = cell2array(dummy,0);

% remove columns
% data = data(:,cols(1):cols(2));

