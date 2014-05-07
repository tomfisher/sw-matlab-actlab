function [cost, coef] = calc_cost(buffer, seg1, seg2, method, maxcost)
% calc_cost: cost function wrapper for segmentation methods
% buffer:           data buffer to operate on
% seg1, seg2:       segment definitions
% method:           define operation mode
% maxcost:          max cost for merge (needed for some methods)

% (c) 2004 Oliver Amft, ETH Zurich, oam@ife.ee.ethz.ch
% Belongs to SWAB algorithm code.
% This implementation is a MODIFIED version based on the original concept of:
%
% Keogh, E.; Chu, S.; Hart, D. & Pazzani, M. An online algorithm for segmenting 
% time series Proceedings of the IEEE International Conference on Data Mining, 2001, 289-296

if (~exist('method')) method = 'LR_SS'; end;

% often needed stuff
merged = segment_add(seg1, seg2);
if (segment_size(merged) < 2) error('Segment smaller than 2 points!'); end;
data = segment_get(buffer, merged);
coef = polyfit([1:length(data)]', data, 1);

residual = data(:) -  (coef(1) * ([1:length(data)]') + coef(2)); 

switch upper(method)
    case 'LR_SS' % Linear regression sum of squares
        cost = sum(residual.^2);
        
    case 'LR_RE' % Linear regression residual error
        cost = sum(abs(residual));

    case 'LR_LINF' % Linear regression L inf measure (furthest point)
        cost = max(abs(residual));
        
    case {'SIM_SLOPE', 'SIM_SLP'} % Slope segment similarity 
        data1 = segment_get(buffer, seg1); data2 = segment_get(buffer, seg2);
        coef1 = polyfit([1:length(data1)]', data1, 1);
        coef2 = polyfit([1:length(data2)]', data2, 1);
        cost = abs(coef1(1)-coef2(1)); % slope similarity
        coef = [coef1(1) coef2(1)];
        
    case 'SIM_RSLP' % Relative slope segment similarity 
        data1 = segment_get(buffer, seg1); data2 = segment_get(buffer, seg2);
        coef1 = polyfit([1:length(data1)]', data1, 1);
        coef2 = polyfit([1:length(data2)]', data2, 1);
        cost = 1;
        slope1 = coef1(1); slope2 = coef2(1);
        if (abs(slope1)/maxcost > abs(slope2)) && ...
                (abs(slope1)*maxcost < abs(slope2)) && ...
                (sign(slope1) == sign(slope2))
            cost = 0; 
        end;


    case 'SIM_WSLP' % Weighted slope segment similarity
        data1 = segment_get(buffer, seg1); data2 = segment_get(buffer, seg2);
        coef1 = polyfit([1:length(data1)]', data1, 1);
        coef2 = polyfit([1:length(data2)]', data2, 1);
        cost = abs((coef1(1)*length(data1)-coef2(1)*length(data2))/length(data));
        coef = [coef1(1) coef2(1)];

    case 'SIM_TRIPLE' % Delete points in a cont. line (cost = deviation)
        data1 = segment_get(buffer, seg1); data2 = segment_get(buffer, seg2);
        cost = max([abs(data1(1) - data1(end)) abs(data2(end) - data1(end))]);
%         cost = abs(mean([data1(1) data2(end)]) - data1(end));

    otherwise
        error('No operation method specified.');
end;

return;