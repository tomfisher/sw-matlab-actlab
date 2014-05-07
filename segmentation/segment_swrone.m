function [SegTS, startptr] = segment_swrone(buffer, startptr, buffersize, maxseg, maxerror, costmethod)
% function [SegTS, startptr] = segment_swrone(buffer, startptr, buffersize, maxseg, maxerror, costmethod)
% 
% segment_swrone: sliding window search for best line, reentrant
% (first maxseg segment returned only)

% (c) 2004 Oliver Amft, ETH Zurich, oam@ife.ee.ethz.ch
% Belongs to SWAB algorithm code.
% This implementation is a MODIFIED version based on the original concept of:
%
% Keogh, E.; Chu, S.; Hart, D. & Pazzani, M. An online algorithm for segmenting 
% time series Proceedings of the IEEE International Conference on Data Mining, 2001, 289-296

if (exist('buffersize','var')~=1), buffersize = 1; end;
if (exist('maxseg','var')~=1), maxseg = 1; end;
if (exist('maxerror','var')~=1), maxerror = 1; end;
if (exist('costmethod','var')~=1), costmethod = 'LR_SS'; end;

verbose = 0;
segcount = 1; SegTS = []; %SegTS(1) = []; % empty segment

% while (length(buffer) > startptr+1) && (segcount <= maxseg)
%     newseg = [startptr startptr+1];
while (length(buffer) > startptr+buffersize) && (segcount <= maxseg)
    newseg = [startptr startptr+buffersize];

    % add data to current segment
    while ((length(buffer) > newseg(2)) && ...
            (calc_cost(buffer, newseg, [0 0], costmethod) < maxerror))

        % buffer finished?
        if (length(buffer) > newseg(2)+buffersize)
            newseg(2) = newseg(2)+buffersize;
        else
            newseg(2) = length(buffer);
        end;

        if (verbose), segment_plot(buffer, {newseg}); end;
    end;

    % new segment found, store it
    if (verbose>1), fprintf('\n%s: add: %u:%u\n', mfilename, newseg{1}(1), newseg{1}(2)); end;
    SegTS(segcount,:) = newseg;
    segcount = segcount + 1;
    startptr = newseg(2) + 1;
end;