function [fh sh] = segment_plotseglist(varargin)
% function [fh sh] = segment_plotseglist(varargin)
%
% Plot lines indicating segments in a figure. Parameters must provide column 4 as class id. 
% Multiple segment lists are drawn in individual subplots.
% 
% Options:
%       MaxTime  -  max time for all subplots
%       Classlabels - cell array of cells with label strings for each subplot
% 
% Example:  segment_plotseglist([ 10 20 0 1; 15 30 0 2; ]);
% 
% See also: segment_plotposition, segment_plotsimilarity
% 
% Copyright 2005-2008 Oliver Amft

for optionspos = 1:nargin, if ischar(varargin{optionspos}), break; end; end;
if optionspos < nargin, 
    args = varargin(optionspos:end);
    plotcnt = optionspos-1;
else
    args = [];
    plotcnt = nargin;
end;

[MaxTime Classlabels] = process_options(args, 'MaxTime', [], 'Classlabels', cell(1, plotcnt));

fh = figure;  sh = fh;

% open up subplots only if required
if plotcnt>1
    sh = zeros(1, plotcnt); 
    sh(1) = subplot(plotcnt, 1,1); 
end;

for plotnr = 1:plotcnt
    seglist = varargin{plotnr};
    if plotnr > 1, sh(plotnr) = subplot(plotcnt, 1, plotnr); end;
    
    [seglist(:,4) ClassIDs] = cat2counted(seglist(:,4));
    maxclasses = length(ClassIDs);
    pcolor = lines(maxclasses);

    % plot section lines
    for seg = 1:size(seglist,1)
        line(seglist(seg,1:2), repmat(seglist(seg,4),1,2), 'color', pcolor(seglist(seg,4),:), 'linewidth', 3);
    end;

    set(gca, 'YTick', 1:maxclasses);
    set(gca, 'YGrid', 'on');
    if ~isempty(Classlabels{plotnr}),     set(gca, 'yticklabel', Classlabels{plotnr});  end;
    
    ylim([0 maxclasses+1]);
    if ~isempty(MaxTime), xlim([0 MaxTime]); end;
end;
