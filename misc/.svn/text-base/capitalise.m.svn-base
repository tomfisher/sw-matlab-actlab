function outstr = capitalise(instr)
% function outstr = capitalise(instr)
% 
% Capitalise strings. Strings can be normal or cell array.
% 
% Copyright 2008 Oliver Amft

if iscell(instr)
	outstr = cell(1, length(instr));
	for i = 1:length(instr)
		outstr{i} = makecap(instr{i});
	end;
else
	outstr = makecap(instr);
end;

function os = makecap(is)
switch length(is)
	case 0
		os = [];
	case 1
		os = upper(is);
	otherwise
		os = [ upper(is(1)) lower(is(2:end)) ];
end;