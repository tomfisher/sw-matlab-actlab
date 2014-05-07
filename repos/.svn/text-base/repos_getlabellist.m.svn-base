function [seglist partoffsets SampleRate] = repos_getlabellist(Repository, Partlist, varargin)
% function [seglist partoffsets SampleRate] = repos_getlabellist(Repository, Partlist, varargin)
%
% Read segment list from MARKER file. Uses MARKER toolbox function maker_load_seglist.m
%
% See also:
%   repos_getplottypes, repos_getmarkersps, repos_getpartsize, repos_getlabellist, repos_getclasses
% 
% Superseds: cla_getseglist
% 
% Copyright 2006-2009 Oliver Amft

[partoffsets, SampleRate, verbose] = process_options(varargin, ...
    'partoffsets', 0, 'SampleRate', 0, 'verbose', 0);

if (partoffsets==0)
    partoffsets = repos_getpartsize(Repository, Partlist, 'SampleRate', SampleRate, 'OffsetMode', true);
end;

seglist = [];

for partnr = 1:length(Partlist)
    Partindex = Partlist(partnr);
    
    % search for labeling information
    [filename detected] = repos_findlabelfile(Repository, Partindex);
    [part_seglist detected] = marker_load_labellist(filename, 'auto', 0);

%     if ~detected
%         % last resort: try to load labels from Repository struct
%         if (verbose), fprintf('\n%s: No labeling file was found for PI %u. Trying seglabels field in Repository entry.', mfilename, Partindex); end;
%         [part_seglist detected] = repos_getfield(Repository, Partindex, 'seglabels');
%         % if 'inf' is found in label end, constrain it to available data size
%         correctlabels = part_seglist(:,2) == inf;
%         part_seglist(correctlabels, 2) = partoffsets(partnr+1)-partoffsets(partnr);
%         part_seglist(correctlabels, 3) = segment_size(part_seglist(correctlabels,:));
%     end;
    
    if ~detected
        fprintf('\n%s: No labeling found for part %u.', mfilename, Partindex);
        if (nargout > 1)
            warning('MATLAB:repos_getlabellist', '\n%s: This may be a critical issue since no partoffset is returned', mfilename);
        end;
        continue;
    end;

    if (verbose), fprintf('%u: %u  ', Partindex, partoffsets(partnr+1)); end;

    if isempty(part_seglist), 
        if (verbose), fprintf('\n%s: Label file for PI %u is empty.', mfilename, Partindex);  end; 
        continue; 
    end;
    
    markersps = repos_getmarkersps(Repository, Partindex, 'singlesps', true);

    % resample segment sizes
    if (SampleRate > 0)
        %fresample = SampleRate/markersps; %DataSeg(partlist(segidx)).SFrq
        if (verbose), fprintf('\n%s: Resampling to %u...', mfilename, SampleRate); end;
        part_seglist = segment_resample(part_seglist, markersps, SampleRate);
    end;

    % concatinate to global segment list
    seglist = [seglist;   [part_seglist(:,1:2)+partoffsets(partnr) part_seglist(:,3:end)] ];
end; % for partnr

if (verbose), fprintf('\n'); end;
