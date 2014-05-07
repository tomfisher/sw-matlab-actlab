function yes = isupper(str, varargin)
% function yes = isupper(str, varargin)
%
% Detect whether upper case chars are in str
yes = false;
upperChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

Mode = process_options(varargin, 'Mode', 'one');

if isempty(str), return; end;

switch lower(Mode)
	case 'one'  % find at least one upper char
		for c = 1:length(upperChars)
			if findstr(str, upperChars(c))
				yes = true;
				break;
			end;
		end;

	case 'all'  % all upper?
		yes = true;
		for c = 1:length(str)
			if isempty(findstr(upperChars, str(c)))
				yes = false;
				break;
			end;
		end;
end;