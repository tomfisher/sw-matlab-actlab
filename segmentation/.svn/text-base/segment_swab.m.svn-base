function SegTS = segment_swab(datapipe, SWABConfig, varargin)
% function SegTS = segment_swab(datapipe, SWABConfig, varargin)
% old: function [SegTS] = segment_swab(datapipe, buffersize, maxcost, method, InitTS, verbose)
%
% SWAB segmentation
% datapipe:         data, artificially online
%
% SWABConfig fields:
% maxcost           cost limit(s) for segmentation (list)
% method            cost calculation procedure(s) (list)
%
% optional params:
% maxbuffer         observation buffer size
% InitTS            initial segmentation (preliminary support!)
% verbose           default=1
% MinBUSegs         minimum number of segments in BU buffer
% swrone_*          Parameter set to configure initial segment guessing
%
% segmentation lists format
% [segbeg1 segend1; segbeg2 segend2; ... segbegN segendN; ]
%
%
% Example SWABConfig:
%
%   SWABConfig(1).method = 'LR_SS';     SWABConfig(1).maxcost = 30; % 1st level
%   SWABConfig(2).method = 'SIM_RSLP';  SWABConfig(2).maxcost = 0.1; % 2nd level
% 
% Copyright 2004-2006 Oliver Amft
% 
% Belongs to SWAB algorithm code.
% This implementation is a MODIFIED version based on the original concept of:
%
% Keogh, E.; Chu, S.; Hart, D. & Pazzani, M. An online algorithm for segmenting 
% time series Proceedings of the IEEE International Conference on Data Mining, 2001, 289-296

[maxbuffer, InitTS, verbose, MinBUSegs, ...
    swrone_stepsize, swrone_nosegs, swrone_maxcost, swrone_method] = process_options(varargin, ...
    'maxbuffer', 500, 'InitTS', [], 'verbose', 1, 'MinBUSegs', 5, ...
    'swrone_stepsize', 50, 'swrone_nosegs', 1, ...
    'swrone_maxcost', SWABConfig(1).maxcost, 'swrone_method', SWABConfig(1).method);


buffersize = maxbuffer;

if (exist('InitTS','var')~=1), InitTS = []; end;

if (exist('verbose','var')~=1), verbose = 1; end;
if (verbose>2), figure; end;
segcount = 1; SegTS = []; StartTime = clock;

% imitate online processing, begin with filled buffer
srange = [1 buffersize]; InitTSovlist = [];
if ~isempty(InitTS)
    InitTSovlist = segment_findincluded(srange, InitTS);
    srange = [InitTS(InitTSovlist(1),1) InitTS(InitTSovlist(end),2)];
end;

sbuffer = segment_get(datapipe, srange);
newseg = []; progress = 0;

if (verbose) 
    fprintf('\n%s: SWAB Segmentation: Stages: %u, Buffer: %u, Data: %u...', ...
        mfilename, length(SWABConfig), buffersize, length(datapipe)); 
end;

while ~isempty(sbuffer)
    % check for pre-segmentation
    if isempty(InitTS)
        SegBU = [];
    else
        InitTSovlist = segment_findincluded(srange, InitTS);
        SegBU = InitTS(InitTSovlist,:)-srange(1)+1;
        if isempty(SegBU) 
            fprintf('\n%s: InitTS empty at %u:%u (stage %u: maxcost=%.3f, method=%s)', ...
                mfilename, srange(1), srange(2), stage, SWABConfig(stage).maxcost, SWABConfig(stage).method);
        end;
    end;

    % bottom-up segmentation on current buffer
    buinfo = [];
    for stage = 1:length(SWABConfig)
        SegBU = segment_bu(sbuffer, SWABConfig(stage).maxcost, SegBU, SWABConfig(stage).method);

        buinfo(stage) = size(SegBU,1); % save segment count ineach stage
        if (size(SegBU,1) == 1), break; end;
    end;
    if (size(SegBU,1) == 1)
        fprintf('\n%s: Buffer bounced at %u:%u (stage %u: maxcost=%.3f, method=%s)', ...
            mfilename, srange(1), srange(2), stage, SWABConfig(stage).maxcost, SWABConfig(stage).method);
    end;

    %bu_segs_s1 = buinfo(1); % segments after 1st stage

    % indicate progress
    if (verbose) && (srange(2)/length(datapipe)>progress)
        fprintf('\n  progress %.1f%%, buffer: %u', progress*100, segment_size(srange));
        progress = progress + 0.1;
        for stage=1:length(buinfo), fprintf(', stage %u:%u', stage, buinfo(stage)); end;
        if (verbose>2), segment_plot(sbuffer, SegBU); end;
        fprintf(', srange: %u-%u', srange(1), srange(2));
        fprintf('  CPU: %.0fs', etime(clock, StartTime));
    end;


    % check if done, exit by flushing remaining segments from buffer
    if (length(datapipe) <= srange(2))
        % all data already processed, flush buffer
        if (verbose), fprintf('\n%s: Finalise, flush all segments (%u)...', ...
                mfilename, size(SegBU,1)); end;
        
        for i=1:size(SegBU,1)
            SegTS(segcount,:) = SegBU(i,:) + srange(1) - 1;
            segcount = segcount + 1;
        end;
        srange = []; bu_flush = size(SegBU,1);
        break; % this is a hack, exit gracefully
    end;
    
    % not done yet, remove at least 1 segments from BU buffer
    bu_flush = size(SegBU,1) - MinBUSegs+1;
    if (bu_flush < 1), bu_flush = 1; end;
    for i = 1:bu_flush
        % add first segment found to the result, adapt segment indices
        SegTS(segcount,:) = SegBU(i,:) + srange(1) - 1;
        segcount = segcount + 1;
    end; % for

    % adapt BU buffer: remove segment that are in the result
    srange = segment_sub(srange, [SegBU(1,1) SegBU(bu_flush,2)] );

    if (verbose), fprintf('\n%s: Flush %u segments (was: %u) ', ...
            mfilename, bu_flush, size(SegBU,1)); end;

    % add LR-segments to srange as long as 
    % 1. buffersize*2 is not exceeded
    % 2. segment count is smaller than MinBUSegs
    bu_segs = size(SegBU,1)-bu_flush;

    while (segment_size(srange) < (buffersize*2)-swrone_stepsize) && (bu_segs <= MinBUSegs)
        % gess a new segment
        newseg = segment_swab_guess(datapipe, srange, InitTS, InitTSovlist, ...
            swrone_stepsize, swrone_nosegs, swrone_maxcost, swrone_method);

        if (~isempty(newseg)) && (segment_size(newseg(1,:)))
            % more data available

            if (segment_size(segment_add(srange, newseg(1,:))) < (buffersize*2))
                srange = segment_add(srange, newseg(1,:));
                %bu_segs = bu_segs + 1;
                if (verbose>1), fprintf('\n%s: Added new data segment: %u:%u (length: %u, segments: %u)', ...
                        mfilename, newseg(1,1), newseg(1,2), segment_size(newseg(1,:)), bu_segs); end;
            else
                % if newseg is too large, add most we are allowed to fill buffersize
                %if (segment_size(srange) == 0)
                srange(2) = srange(1) + buffersize*2-1;
                %bu_segs = bu_segs + 1;

                fprintf('\n%s: Buffer dispersed at %u:%u, newseg was %u:%u (segments: %u)', ...
                    mfilename, srange(1), srange(2), newseg(1,1), newseg(1,2), bu_segs);
            end;
        else
            % end of data (most likely) or swrone failed
            if (verbose>1), fprintf('\n%s: End of data, %u:%u (length: %u)', ...
                    mfilename, srange(1), srange(2), segment_size(srange)); end;
            break;
        end;
    end; % while 

    if (verbose>1), fprintf('\n%s: ::: Buffer for next segment_bu: %u:%u (length: %u)', ...
            mfilename, srange(1), srange(2), segment_size(srange)); end;
    sbuffer = segment_get(datapipe, srange);
end;

if (verbose)
    fprintf('\n%s: SWAB summary:\n  %u segment(s) from %u samples', ...
        mfilename, size(SegTS,1), length(datapipe));
    fprintf(' (CPU: %.0fs)\n\n', etime(clock, StartTime));
    
    %     segment_plot(t, bu)
end;



function newseg = segment_swab_guess(datapipe, srange, InitTS, InitTSovlist, ...
    swrone_stepsize, swrone_nosegs, swrone_maxcost, swrone_method)
% - guess a new segment -------------------------------------
if isempty(InitTS)
    % w/o InitTS: Use LR to estimate a segment
    % segment_swrone(buffer, startptr, buffersize, maxseg, maxerror, costmethod)
    %newseg = segment_swrone(datapipe, srange(2)+1, 50, 1, 30, 'LR_SS');
    newseg = segment_swrone(datapipe, srange(2)+1, swrone_stepsize, swrone_nosegs, swrone_maxcost, swrone_method);
else
    % % w InitTS: Use the next provided by InitTS
    if (InitTSovlist(end) < size(InitTS,1));
        newseg = InitTS(InitTSovlist(end)+1,:)-srange(1)+1;
    else
        newseg = [];
    end;
end;
