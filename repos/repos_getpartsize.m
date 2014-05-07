function [partsizelist found] = repos_getpartsize(Repository, Partlist, varargin)
% function [partsizelist found] = repos_getpartsize(Repository, Partlist, varargin)
%
% Retrieve part size (from MARKER file) and correct it according to alignment: 
%       1. begin offset (alignshift), 
%       2. sampling alignment (alignsps), 
%       3. determine shortes dataset (minimum)
% 
% Superseds cla_getpartsize
%
% Example: 
%   >> repos_getpartsize(Repository, [39 40])
%   ans =
%       205830       24319
%
% Optional parameters:
%   OffsetMode = true: return a cumulative size list of the length eq. to Partlist, first element 0
%   RawMode = true: return raw part size (NOT adapted acc. to CLA info    
% 
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getlabellist, repos_getclasses
% 
% Copyright 2008-2009 Oliver Amft

[Offsetmode, Rawmode, SampleRate, verbose] = process_options(varargin, ...
    'OffsetMode', false, 'RawMode', false, 'SampleRate', 0, 'verbose', 0);

if Rawmode && length(Partlist)>1, error('In Rawmode one part at a time is supported only.'); end;

if ~Rawmode,   partsizelist = nan(1, length(Partlist)); end;

% loop for all parts
for partnr = 1:length(Partlist)
    Partindex = Partlist(partnr);
    
    [filename detected] = repos_findlabelfile(Repository, Partindex);
    [part_markerfile detected] = marker_load_markerfile(filename, 0);

    if isempty(part_markerfile) || ~strmatch('partsize', detected, 'exact')
        [partsize detected] = repos_getfield(Repository, Partindex, 'partsize');
        if ~detected
            fprintf('\n%s: WARNING: Partsize not found for part %u.', mfilename, Partindex);
            partsize = 0;
        end;
    else
        partsize = part_markerfile.partsize;
    end;
    
    if Rawmode,  partsizelist = partsize;  break;   end;
 
       
    [alignshift alignsps alignrate plottypes found] = repos_getalignment(Repository, Partindex);

    partsize = ceil((partsize - alignshift) .* alignrate);
    %partoffset = ceil(alignshift .* alignrate);

    
    if (SampleRate > 0)
        markersps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
        fresample = SampleRate./markersps;
        partsize = ceil(partsize .* fresample);
        %partsize = segment_resample(partsize, markersps, SampleRate);
        %partoffset = ceil(partoffset .* fresample);
    end;

    partsizelist(partnr) = min(partsize);
end; % for segidx

% if (verbose) && (SampleRate > 0), fprintf('\n%s: Resampling to %u...', mfilename, SampleRate); end;

% convert to offsets, if requested
if ~Rawmode
    if Offsetmode,  partsizelist = cumsum([0 partsizelist]);  end;
end;

found = 1;
if isnan(partsizelist),   found = 0;  end;
