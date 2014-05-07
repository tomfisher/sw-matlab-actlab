function [Data orgsps] = toolbox_readfile(DataFile, varargin)
% function [Data orgsps] = toolbox_readfile(DataFile, varargin)
% 
% Read data from toolobox TimestampedLines encoder, which is easy and
% estimate sampling rate, which is hard. Configure your rate ranges in the
% frqbounds list below.
%
% frequency bounds: [lower upper nominal] 

% Copyright 2006 Oliver Amft

frqbounds = [2000 2300 2048; 110 140 128];

[Range Columns verbose] = process_options(varargin, ...
	'range', [1 inf], 'columns', [1 inf], 'verbose', 0);

% --- read in data ---
% account for timestamp columns
%Data = readtextfilecols(DataFile, Columns, Range);
Data = readtextfilecols(DataFile, [1 2+Columns(2)], Range);
timecols = Data(:, 1:2);
Data = Data(:, 2+Columns(1):2+Columns(2));

if (verbose), fprintf('\n%s: Lines read: %u', mfilename, size(Data,1)); end;

% --- estimate sample rate ---

% TimestampedLinesEncoder: [Sec USec]
%timecols = readtextfilecols(DataFile, [1 2], Range);

timestamps = timecols(:,1)*1e6 + timecols(:,2);
realsps = 1e6/mean(diff(timestamps)) ;

orgsps = frqbounds((isbetween(realsps, frqbounds)==1), 3);
if (verbose), fprintf('\n%s: Estimated sampling rate is: %u', mfilename, orgsps); end;