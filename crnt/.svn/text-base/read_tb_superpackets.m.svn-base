function ftext = read_tb_superpackets(filename)
% function ftext = read_tb_superpackets(filename)
%
% read CRN Toolbox superpackets log file
%
% ftext contains a cell array of strings with each column corresponding to
% a column in the file: ftext{1,column} returns the column.


fid = fopen(filename);
if (fid<0) error('Could not open file!'); end;

% determine end of file to break loops
fseek(fid, 0, 'eof'); eofpos = ftell(fid); fseek(fid, 0, 'bof');

% read in file
ftext = textscan(fid, '%u\t%u\t%s\t%f\t%u\t%u\t%u\t%u\t%u\t%u', -1);

fclose(fid);
