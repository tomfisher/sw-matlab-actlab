function DataStruct = fb_createdatastruct( ...
    Name, Data, Repository, Partlist, DTable, FeatureString, SampleRate, BaseRate, varargin)
% function DataStruct = fb_createdatastruct( ...
%     Name, Data, Repository, Partlist, DTable, FeatureString, SampleRate, BaseRate, varargin)
% 
% See also: fb_modifydatastruct, fb_createdummystruct
% 
% Copyright 2006-2007 Oliver Amft

% [Name Data Range DTable FeatureString BaseRate SampleRate] = ...
%     process_options(varargin, ...
%     'Name', 'noname', 'Data', [], 'Range', [1 inf], 'DTable', '', ...
%     'FeatureString', {}, 'BaseRate', 0, 'SampleRate', 0);
[Range] = process_options(varargin, 'Range', [1 size(Data,1)]);

%DataStruct.seglist = SegList;
DataStruct.Name = Name;
DataStruct.Data = Data;
DataStruct.Repository = Repository;
DataStruct.Partlist = Partlist;
DataStruct.Range = Range;
DataStruct.DTable = DTable;
DataStruct.FeatureString = FeatureString;
DataStruct.BaseRate = BaseRate;
DataStruct.SampleRate = SampleRate;

% DataStruct.swsize = 512;
% DataStruct.swstep = 512;

