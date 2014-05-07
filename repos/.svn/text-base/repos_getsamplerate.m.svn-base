function orgsps = repos_getsamplerate(Repository, Partlist, DataType, varargin)
% function orgsps = repos_getsamplerate(Repository, Partlist, DataType, varargin)
%
% Determine original sample rate for specified DataType (stream) using 
% repos_prepdata() by loading a tiny piece of data.
% 
% Copyright 2007 Oliver Amft

[alignment Range verbose] = process_options(varargin, ...
    'alignment', false, 'Range', [1 10], 'verbose', 0);

[dummyData, dummyDTable, orgsps] = repos_prepdata(Repository, Partlist(1), DataType, ...
    'Range', Range, 'alignment', alignment, 'verbose', verbose);
