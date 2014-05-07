function tokens = fb_getelements(Feature, element, seperator)
% function tokens = fb_getelements(Feature, element, seperator)
% 
% Tokenize feature string (one feature), individual elemens are returned in a cell array.
% Default separation sign is '_'. 
% 
% See also: fb_composefstring
% 
% Copyright 2007-2010 Oliver Amft

if iscell(Feature), error('Parameter Feature may not be a cell by itself.'); end;
if ~exist('element','var'), element = []; end;
if ~exist('seperator','var'), seperator = '_'; end;

tokens = str2cellf(Feature, seperator);

if ~isempty(element)
    if length(tokens)<element, error('Requested element %u does not exist in feature tokens.', element); end;
    tokens = cell2str(tokens(element), '');
end;