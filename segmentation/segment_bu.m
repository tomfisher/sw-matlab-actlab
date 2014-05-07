function [SegTS, MergeTS, mergecost] = segment_bu(buffer, maxcost, initTS, costmethod, verbose)
% function [SegTS, MergeTS, mergecost] = segment_bu(buffer, maxcost, initTS, costmethod, verbose)
%
% bottom-up segmentation
%
% buffer:       data area to segment
% maxcost:     max merging cost threshold
% initTS:       initial segmentation (for multistage operation)
% SegTS:        cell aray with segment indexes for the buffer supplied
%
%
% example SWABConfig:
%     costmethod = 'LR_SS';     
%     maxcost = 30;
%     initTS = [];

% (c) 2004 Oliver Amft, ETH Zurich, oam@ife.ee.ethz.ch
% Belongs to SWAB algorithm code.
% This implementation is a MODIFIED version based on the original concept of:
%
% Keogh, E.; Chu, S.; Hart, D. & Pazzani, M. An online algorithm for segmenting 
% time series Proceedings of the IEEE International Conference on Data Mining, 2001, 289-296

mframe_counter = 0;      % real counter (do not change)
% Demos:
% ts=XData.Eul{3}.theta(10500:11400); seg=segment_bu(ts, 30, [], 'LR_SS',1);

if (exist('verbose')~=1) verbose = 0; end;

% run on initial/predefined segmentation
if ((exist('initTS')~=1) || (size(initTS,1)==0))   %(~exist('initTS'))
    % cost function mode
    if (~exist('costmethod')) costmethod = 'LR_SS'; end;

    % account for even/odd buffer sizes
    segcount = ceil(length(buffer)/2);

    % create initial fine-grained segmentation
    SegTS = [];
    for index=1:segcount
        SegTS(index,:) = [index*2-1 index*2];
    end;

    % adapt last segment for odd buffer sizes
    if (rem(length(buffer),2)) SegTS(end,2) = SegTS(end,1); end;
else
    % run on pre-segmentation
    segcount = size(initTS,1);
    SegTS = initTS;
    if (~exist('costmethod')) costmethod = 'SIM_SLOPE'; end;
end;

% determine cost of merging neighboring segments
for index=1:segcount-1
    mergecost(index) = calc_cost(buffer, SegTS(index,:), SegTS(index+1,:), costmethod, maxcost);
end;

% fall through, if this is a bouncing buffer 
% (segment_size(initTS(1,:)) >= buffer
if (segcount == 1) mergecost = maxcost; end;

MergeTS = [];

% scan for cheapest segment to merge
while min(mergecost) < maxcost
    % find cheapest segment, exclude last (merge from left to right)
    [dummy index] = min(mergecost); clear dummy;
    % merge with right neighbor
    MergeTS = [MergeTS; SegTS(index,:)];
    SegTS(index,:) = segment_add(SegTS(index,:), SegTS(index+1,:));
    % reorganise segment list
    SegTS = [SegTS(1:index,:); SegTS(index+2:end,:)];
    segcount = segcount - 1;
    if (segcount > index)
        % delete old segment from mergecost vector
        mergecost = [mergecost(1:index) mergecost(index+2:end)];
        % update merge cost vector for current position
        mergecost(index) = calc_cost(buffer, SegTS(index,:), SegTS(index+1,:), costmethod, maxcost);
    else
        % delete old segment from mergecost vector (last segment)
        mergecost = [mergecost(1:index-1)];
    end;
    if (index > 1)
        % update merge cost vector for left neighbor
        mergecost(index-1) = calc_cost(buffer, SegTS(index-1,:), SegTS(index,:), costmethod, maxcost);
    end;
    if (verbose) 
        if (mframe_counter == 0) 
            fh=figure('Position', [198   636   830   286]);
        end;

        if (rem(mframe_counter, 100) == 0) | (min(mergecost) > maxcost)
%             subplot(2,1,1); 
            clf; cla;
            segment_plote(buffer, SegTS);
            plotfmt(gcf, 'yl', 'Motion parameter', 'xl', 'Samples', 'xtl', '');
            plotfmt(gcf, 'ti', ['Interation ' mat2str(mframe_counter)]);
            %             plotfmt(gcf, 'fs', 14);
            
            % paper formattings:
            cmap=gray(2+2); cmap=cmap(2:end-1,:);
            plotfmt(gcf, 'ytl', '', 'lc', 'k', 'lw', 1); %, 'lm', 'x');
%             plotfmt(gcf, 'lm', 'o', 'lw', 1, 'MarkerEdgeColor', cmap(1,:)); 
            plotfmt(gcf, 'MarkerSize', 10, 'MarkerEdgeColor', [0.2 0.2 0.2]);
            %             plotfmt(gcf, 'MarkerSize', 10, 'MarkerFaceColor', [1 1 1]);
            %             plotfmt(gcf, 'lapr');

            drawnow; hold off;
%             subplot(2,1,2);
%             if (length(mergecost)) plot([1:length(mergecost)], mergecost, 'b.'); end;
%             plotfmt(gca, 'yl', 'Merge cost', 'xl', 'Segments', 'fs', 14);
%             drawnow;
            fprintf('\n%s: iteration:%u, segments:%u', mfilename, mframe_counter, size(SegTS,1));
%             plotfmt(fh, 'prtif', ['segment_bu' mat2str(mframe_counter)]);
        end;
        
        mframe_counter = mframe_counter + 1;
    end;
end;

if (verbose) 
    fprintf('\n%s: method: %s, mincost: %f, segments: %u', ...
        mfilename, costmethod, min(mergecost), segcount);
    fprintf('\nDone.\n\n');
end;
