function [peakpos peakvals] = feature_naivepeaks(sdata, peakcount)
% function [peakpos peakvals] = feature_naivepeaks(sdata, peakcount)
%
% Find peaks in sdata and return the positions and values
if (exist('peakcount','var')~=1), peakcount = inf; end;

peakpos = [];
for idx = 2:length(sdata)-1
    if (sdata(idx-1)<sdata(idx)) && (sdata(idx+1)<sdata(idx))
        peakpos = [peakpos idx];
    end;
end;

if (peakcount>length(peakpos))
    peakcount = length(peakpos); 
end;

peakcost = sdata(peakpos);

% peakpos1 = [1 peakpos length(sdata)];
% peakcost = [];
% for idx = 2:length(peakpos1)-1
%     peakcost = [peakcost ...
%         sum( [abs(diff(sdata(peakpos1(idx-1):peakpos1(idx)))); abs(diff(sdata(peakpos1(idx):peakpos1(idx+1))))]) ]; 
% end;
% 
% %/(peakpos(idx)-peakpos(idx-1))];
 
[dummy peakrank] = sort(peakcost, 'descend');
peakpos = peakpos(peakrank(1:peakcount));
peakvals = sdata(sort(peakpos));
