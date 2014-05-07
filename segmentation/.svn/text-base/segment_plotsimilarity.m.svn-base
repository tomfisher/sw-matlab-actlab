function [fhandle maxxval] = segment_plotsimilarity(varargin)
% function [fhandle maxxval] = segment_plotsimilarity(varargin)
%
% Plot similarity sections for different classes. Parameter list should
% look as follows: seglist1, segconf1, seglist2, segconf2...

stylelist = {'b-', 'r-', 'g-', 'k-'};

% get max scale value
maxxval = []; plotcount = nargin/2;
for list = 1:plotcount
    if iscell(varargin{list}) error('\n%s: Will not work on cell lists!', mfilename); end;

    if isnumeric(varargin{list}) && rem(list,2)
        maxxval = [maxxval max(varargin{list}(:,2))];
    end;
end;
maxxval = max(maxxval);

fhandle = figure;
hold on;

for list = 1:plotcount
    segment_plotmark(1:maxxval, varargin{list*2-1}, 'similarity', varargin{list*2}, 'width', 2, 'style', stylelist{list});
end;

ylabel('Confidence/Distance');
