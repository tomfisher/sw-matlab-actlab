function [dist found] = xsens_getdist(Repository, Partindex, varargin)
% function [dist found] = xsens_getdist(Repository, Partindex, varargin)
%
% fetch distance features from file
% 
% Copyright 2005 Oliver Amft

filename = repos_makefilename(Repository, 'indices', Partindex, 'prefix', 'DIST', 'subdir', 'DIST');

[Range SampleRate verbose] = process_options(varargin, 'Range', [1 inf], 'SampleRate', 0, 'verbose', 1);

if ~exist(filename,'file')
    if verbose, fprintf('\n%s: Warning: Distance information not available (File: %s).', mfilename, filename); end;
    dist = [];
    found = false;
else
    load(filename, 'distanceLLA', 'distanceRLA', 'sps');
    dist = [ col(distanceRLA)  col(distanceLLA) ];
    found = true;

    if SampleRate>0
      if verbose, fprintf('\n%s: Resampling from %.1fHz to %.1fHz...', mfilename, sps, SampleRate); end;
      [p q] = rat(SampleRate/sps);
      dist = resample(dist, p, q);
    end;

    if (Range(2)-Range(1)) < inf
        dist = dist(Range(1):Range(2), :);
    end;
end;
