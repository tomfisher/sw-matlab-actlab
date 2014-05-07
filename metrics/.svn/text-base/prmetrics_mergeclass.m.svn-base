function NMetrics = prmetrics_mergeclass(varargin)
% function NMetrics = prmetrics_mergeclass(varargin)
%
% Merge classes in a PR performance metric struct
% The merge can be preformed in 2 ways (mutually exclusive):
%   1. Merge set of single structs, e.g. prmetrics_mergeclass(p1,p2...)
%   2. Merge ONE multistruct, e.g. prmetrics_mergeclass(multi)
% 
% Copyright 2006 Oliver Amft

if nargin > 1
    NMetrics = varargin{1};
    mcount = nargin;
    multistruct = false;
else
    NMetrics = varargin{1}(1);
    mcount = length(varargin{1});
    multistruct = true;
end;

for vidx = 2:mcount
    coffs = length(NMetrics.relevant);
    if (multistruct)
        OMetrics = varargin{1}(vidx);
    else
        OMetrics = varargin{vidx};
    end;

    for cidx = 1:length(OMetrics.relevant)
        NMetrics.relevant(cidx+coffs) = OMetrics.relevant(cidx);
        NMetrics.retrieved(cidx+coffs) = OMetrics.retrieved(cidx);
        NMetrics.recognised(cidx+coffs) = OMetrics.recognised(cidx);
        NMetrics.misses = [];
        NMetrics.hits = [];
    end;
end;

NMetrics = prmetrics_update(NMetrics);
