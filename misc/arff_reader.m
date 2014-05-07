function [Data DTable SPS] = arff_reader(filename, varargin)
% function [Data DTable SPS] = arff_reader(filename, varargin)
% 
% Read ARFF file format
% 
% Copyright 2009 Oiver Amft
SPS = [];

if exist(filename,'file')~=2
    % Double printout needed sich error message is caught by try-embedded code.
    fprintf('\n%s: File does not exist: %s\n', mfilename, filename);
    error('File does not exist.');
end;

[Rows, AttributeTag TimeStampCol verbose] = process_options(varargin, ...
    'rows', [1 inf], 'AttributeTag', '@Attribute', 'TimeStampCol', [], 'verbose', 0);

Rows = Rows -1;

if (Rows(2) == inf)
    Rows(2) = -2; % Result will be -1; textscan will read the whole file
end;

% determine 
fid = fopen(filename);
DTable = [];  dummy = '';
while ~strcmp(dummy, '@Data')
    dummy = fgetl(fid);
    if length(dummy)>= length(AttributeTag) && ~isempty(findstr(dummy, AttributeTag))
        DTable = [DTable { dummy(findstr(dummy, AttributeTag)+length(AttributeTag)+1:end) }]; 
    end;
end;


fpos = ftell(fid); dummy = fgetl(fid); fseek(fid, fpos, -1);
maxcols = length(sscanf(dummy, '%f,', inf));


% generate reading mask for textscan()
readmask = repmat('%f,', 1, maxcols); readmask(end) = [];

if maxcols ~= length(DTable)
    fprintf('\n%s: ARFF file has inconsistencies: %s\n', mfilename, filename);
    error('ARFF file has inconsistencies.');
end;
    

% read data file
%dummy = textscan(fid, readmask, rows(2)-rows(1)+1, 'headerlines', rows(1), 'headercolumns', cols(1) );
dummy = textscan(fid, readmask, Rows(2)-Rows(1)+1, 'headerlines', Rows(1) );
fclose(fid);

Data = cell2mat(dummy);

% derive SPS
if ~isempty(TimeStampCol)
    error('Not implemented.');
end;
