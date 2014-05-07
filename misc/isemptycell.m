function E = isemptycell(C)
% ISEMPTYCELL Apply the isempty function to each element of a cell array
% E = isemptycell(C)
%
% This is equivalent to E = cellfun('isempty', C),
% where cellfun is a function built-in to matlab version 5.3 or newer.

if 1 % all(version('-release') >= 12)
    E = cellfun('isempty', C);
    
    E(isempty(E)) = 1;  % OAM REVISIT
else
    E = zeros(size(C));

    %   for i=1:prod(size(C))
    for i=1:numel(C)
        E(i) = isempty(C{i});
    end
    E = logical(E);
end