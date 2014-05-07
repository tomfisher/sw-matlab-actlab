function S = w(str)
% function S = w(str)
% 
% Short version for whos <argument>
% 
% Copyright 2009 Oliver Amft

if ~exist('str', 'var') || isempty(str)
    cmdstr = [ 'whos;' ];
else
    cmdstr = [ 'whos(''' str ''');' ];
end;

if nargout
    S = evalin('caller', cmdstr);
else
     evalin('caller', cmdstr);
end;