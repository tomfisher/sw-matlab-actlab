function [cindex cvalue] = findnearestval(value, valuelist, varargin)
% function [closestval value] = findnearestval(value, valuelist, varargin)
%
% Find index of the element with the closest distance to value
% 
% Copyright 2007 Oliver Amft

cindex = []; cvalue = [];
if isempty(value) || isempty(valuelist)
    return;
end;

UseSides = process_options(varargin, 'UseSides', 'both');

diffs = valuelist - value;

switch lower(UseSides)
    case 'both' % consider both sides of value in valuelist
        [cvalue cindex] = min(abs(diffs));
        
    case 'lower' % consider only smaller elements in valuelist
        [cvalue cindex] = max(diffs(diffs<=0));
        
    otherwise
        error('Parameter UseSides=%s not supported', lower(UseSides));
end;
