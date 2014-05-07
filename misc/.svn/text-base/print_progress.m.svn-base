function prate = print_progress(prate, pval, increment)
% function prate = print_progress(prate, pval, increment)
% 
% prate     variable holding progress share
% pval      actual progress made
% increment update rate (default: 10%)
% 
% usage:
% 
%       prate = 0.1;
%       for ...
%           prate = print_progress(prate, prate/maxloops);
%           ...
% 
% Copyright 2005-2007 Oliver Amft

if ~exist('increment','var'), increment=0.1; end;

if (pval > prate)
    fprintf(' %u%%', round(prate*100));
    prate = prate + increment;
end;
