function NMetric = prmetrics_skewsweep(OMetric, Steps)
% function NMetric = prmetrics_skewsweep(OMetric, Steps)
%
% Sweep through a PR metric 2-class result

if (exist('Steps')~=1) Steps = 5; end;

NMetric = [];
if isempty(OMetric) return; end;
if length(OMetric.relevant) ~= 2
    error('Procedure works on 2-class problems only!');
end;

% 1. add class 2
for i = 1:Steps+1
    relevant = OMetric.relevant(1) + round(OMetric.relevant(2)*(i-1)/Steps);
    retrieved = OMetric.retrieved(1) + round(OMetric.retrieved(2)*(i-1)/Steps);
    recognised = OMetric.recognised(1) + round(OMetric.recognised(2)*(i-1)/Steps);
    NMetric = [NMetric prmetrics_mkstruct(relevant, retrieved, recognised)];
end;


% 2. sub class 1
for i = Steps:-1:1
    relevant = OMetric.relevant(2) + round(OMetric.relevant(1)*(i-1)/Steps);
    retrieved = OMetric.retrieved(2) + round(OMetric.retrieved(1)*(i-1)/Steps);
    recognised = OMetric.recognised(2) + round(OMetric.recognised(1)*(i-1)/Steps);
    NMetric = [NMetric prmetrics_mkstruct(relevant, retrieved, recognised)];
end;

% prmetrics_plotpr('view', [], prmetrics_sort(NMetric))