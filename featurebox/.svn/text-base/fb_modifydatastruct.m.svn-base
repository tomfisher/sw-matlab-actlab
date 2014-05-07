function [DataStruct varargout] = fb_modifydatastruct(DataStruct, varargin)
% function [DataStruct varargout] = fb_modifydatastruct(DataStruct, varargin)
% 
% Add field to a DataStruct. Parameter 1: name, parameter 2: value
% 
% See also: fb_createdatastruct, fb_createdummystruct
% 
% Copyright 2006-2007 Oliver Amft

for ds = 1:length(DataStruct)
    for i = 1:2:size(varargin,2)
        DataStruct(ds).(varargin{i}) = varargin{i+1};
        varargout(i:i+1) = varargin(i:i+1);
    end;
end;