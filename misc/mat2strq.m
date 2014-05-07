function ostr = mat2strq(istr)
% function ostr = mat2strq(istr)
% 
% mat2str() wrapper to remove quotes. Needed with char input for mat2str in Matba versions 2007a.
% 
% Copyright 2007 Oliver Amft

if ischar(istr)
    ostr = regexprep(mat2str(istr), '''', ''); 
else
    ostr = mat2str(istr);
end;
