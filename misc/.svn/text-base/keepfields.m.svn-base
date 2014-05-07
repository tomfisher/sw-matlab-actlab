function sout = keepfields(sin, names)

if (~iscell(names)), names = {names}; end;

for i = 1:length(names)
    sout.(names{i}) = sin.(names{i});
end
