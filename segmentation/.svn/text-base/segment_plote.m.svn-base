function segment_plote(data, varargin)
% function segment_plote(data, varargin)
%
% segment_plote: plot data and segmentation points
% embedded function - use segment_plot() for standalone operaton
%
% data      Display data
% [...]     List of segmentation cell arrays
%
% Segmentation cells should have the structure:
% [lowerlimit upperlimit]

% grid on;
plot(data, 'b');
hold on; 
plotstyle = {'kx', 'rx', 'go', 'gx'};

for segindex = 1:length(varargin)
    SegTS=varargin{segindex};
    %     if (segindex == 1) plot(SegTS{1}(1), data(SegTS{1}(1)), plotstyle{segindex}); end;
    segment_plotmark(data, SegTS, 'style', plotstyle{segindex});

    %     if (isempty(SegTS{1})) continue; end;
    %     plot(SegTS{1}(1), data(SegTS{1}(1)), plotstyle{segindex});
    %
    %     for index = 1:size(SegTS,2)
    %         if (SegTS{index}(2)<=length(data))
    %             plot(SegTS{index}(2), data(SegTS{index}(2)), plotstyle{segindex});
    %         end;
    %     end;
end;
hold off; 