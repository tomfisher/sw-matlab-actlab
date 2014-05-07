function strout = strcut(strin, varargin)
% function strout = strcut(strin, varargin)
% 
% Cut overlength strings, reformat them
% 
% Copyright 2008 Oliver Amft

[CutLength, CompressStr, ShowBegEnd] = process_options(varargin, ...
    'CutLength', 15, 'CompressStr', '....', 'ShowBegEnd', false);

nocellmode = false;
if ~iscell(strin)
    strin = {strin};
    nocellmode = true;
end;

strout = cell(1, length(strin));
for i = 1:length(strin)
    strlen = length(strin{i});
    if strlen < CutLength, CutLength = strlen; end;

    strout{i} = strin{i}(1:CutLength);

    if strlen > CutLength, strout{i} = [ strout{i}, CompressStr ]; end;
end;

if ShowBegEnd, error('This festure is not yet supported.'); end;

if nocellmode, strout = strout{1}; end;