function ret = getfields(structlist, fields)
% function ret = getfields(structlist, fields)
% 
% Get multiple fields from a struct converted into a matrix.
% 
% See also: getfield
% 
% Copyright 2009 Oliver Amft

ret = nan(length(structlist), length(fields));
for i = 1:length(structlist)
    for j = 1:length(fields)
        try ret(i,j) = structlist(i).(fields{j});
        catch fprintf('\n%s: WARNING: Could not get field %s.', mfilename, fields{j}); break; end;
    end;
end;