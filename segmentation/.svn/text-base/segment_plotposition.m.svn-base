function [fhandle maxxval] = segment_plotposition(varargin)


% get max scale value
maxxval = []; plotcount = nargin;
for list = 1:nargin
    if iscell(varargin{list}), error('\n%s: Will not work on cell lists!', mfilename); end;
    if isnumeric(varargin{list})
        maxxval = [maxxval max(varargin{list}(:,2))];
    else
        plotcount = list-1;
        break;
    end;
end;
maxxval = max(maxxval);
[style fhandle] = process_options(varargin(plotcount+1:end), ...
    'style', 'b-', 'fhandle', 0);

if fhandle == 0, fhandle = figure; else figure(fhandle); end;
yscaler = 0.1;
ylim([0 (yscaler*plotcount +(yscaler/2))]);    % depend on segment lists!
hold on;


for list = 1:plotcount
    segment_plotmark(1:maxxval, varargin{list}, 'segment', 'yr', [yscaler*list yscaler*list], 'width', 2, 'style', style); %, 'xscale', maxxval);
end;

ylabel('Categories');
tlpos = yscaler:yscaler:yscaler*plotcount;
tlstr = {}; format = '%u';
for tli = 1:plotcount
    tlstr = {tlstr{:} num2str(tli, format)};
end;
plotfmt(1, 'yt', tlpos, 'ytl', tlstr);
