function ostr = leadingtrailingspaces(istr, varargin)
% function ostr = leadingtrailingspaces(istr, varargin)
% 
% Remove leading and/or trailling spaces from string

mode = process_options(varargin, 'mode', 'lt');

if isempty(istr), ostr = istr; return; end;

if any(mode=='l')
	if (istr(1)==' '), istr(1:find(istr ~= ' ',1)-1) = []; end;
end;

if any(mode=='t')
	if (istr(end)==' '),
		istr= fliplr(istr);
		istr(1:find(istr ~= ' ',1)-1) = [];
		istr = fliplr(istr);
	end;
end;

ostr = istr;