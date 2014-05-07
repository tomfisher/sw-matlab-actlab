function datasize = fb_getdatasize(DataStruct, varargin)
% function datasize = fb_getdatasize(DataStruct, varargin)
% 
% Determine data size, useful for dynamic load mode
% 
% Copyright 2006-2007 Oliver Amft

SampleRate = process_options(varargin, 'SampleRate', 0);

datasize = zeros(1, length(DataStruct));
for i = 1:length(DataStruct)
    datasize(i) = size(DataStruct(i).Data,1);
    
    if (SampleRate > 0)
        datasize(i) = floor(datasize(i) * SampleRate / DataStruct(i).SampleRate);
    end;
end;


% if length(DataStruct)>1
%     fprintf('\n%s: WARNING: More than one DataStruct supplied.', mfilename);
% end;