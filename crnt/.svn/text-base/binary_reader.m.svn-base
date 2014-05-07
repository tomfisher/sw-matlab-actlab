function [data orgsps channels] = binary_reader(DataFile, varargin)
% function [data orgsps channels] = binary_reader(DataFile, varargin)
% 
% Read data from CRNT BinaryEncoder
% 
% For audio data:
%   data = data / double(intmax+1);
% 
% Copyright 2008-2013 Oliver Amft, Marija Milenkovic

% OAM REVISIT:  some parameters not yet supported
[Range Columns StripTimestamp HasHeader NumFormat DoNormalise verbose] = process_options(varargin, ...
	'Range', [1 inf], 'Columns', [1 inf], 'StripTimestamp', false, 'HasHeader', true, 'NumFormat', 'int32', 'DoNormalise', false, 'verbose', 0);

% determine bytes to read per sampe
switch lower(NumFormat)
    case 'int32'
        BytesPerSample = 4; % 4 bytes
        NormaliseFactor = 1/ (2^32 / 2);
    case { 'float', 'float32' }
        BytesPerSample = 4; % 4 bytes
        NormaliseFactor = 1;
    case 'int16'
        BytesPerSample = 2; % 2 bytes
        NormaliseFactor = 1/ (2^16 / 2);
end;


fid = fopen(DataFile, 'r');
if fid < 0
    % Double printout needed since error message is caught by try embedded code.
    fprintf('\n%s: Could not open file: %s', mfilename, DataFile);
    error('File %s not found.', DataFile);
end;

% read in CRNT binary file header
if (HasHeader)
    % int32 nrChannels; int32 writetimestamp;
    headerdata = fread(fid, 2, 'int32');
    channels = headerdata(1); writetimestamp = headerdata(2);
else
    % if no header, create dummy
    channels = 1; writetimestamp = false;
end;

% determine file size and total samples in file
datapos = ftell(fid); fseek(fid, 0, 'eof'); filesize = ftell(fid);
datasize = filesize - datapos;  % exclude header data


% determine if file has correct size (equal number of samples per channel)
if rem(datasize/BytesPerSample, channels)
    fclose(fid); 
    error('File is corrupt.'); 
end;

% OAM REVISIT: extend to multiple channels
if channels > 1, error('This code does not yet support multiple channels.'); end;

% determine reading ranges
Range(1) = Range(1) + datapos/BytesPerSample-1;
if Range(2) == inf, Range(2) = datasize/BytesPerSample; 
else Range(2) = Range(2) + datapos/BytesPerSample-1; end;

% --- read in data ---
% int32 data[];

fseek(fid, Range(1)*BytesPerSample, 'bof');
data = double(fread(fid, Range(2)-Range(1)+1, NumFormat));
% data = double(fread(fid, '*int32'));
% figure; plot(data)
fclose(fid);

if DoNormalise
    data = data .* NormaliseFactor;
end;

if (writetimestamp)
    error('This code does not yet support extracting timestamps.'); 
    % extract timestamp
    % not tested
    timestamp = data(:,1:2);  data(:,1:2) = [];
    orgsps = NaN; % to be implemented
else
    orgsps = [];
end;