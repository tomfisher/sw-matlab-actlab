function mergedassoc = crnt_mergeassoc(varargin)
% function mergedassoc = crnt_mergedassoc(varargin)
% 
% Combine channel associations from different sources according to data fusion 
% as performed by crnt_timemerge.
% 
% Call example:
%   crnt_mergeassoc(Template_AssocXSENS, Template_AssocMTS, Template_AssocESLMAG2, ...)
% 
% See also:
%   main_crnt_mergestreams, crnt_timemerge
% 
% Copyright 2008 Oliver Amft


% Sensor associations created e.g. by main_crnt_mergestreams, crnt_timemerge
mergedassoc = [];
for i = 1:length(varargin)
    mergedassoc = [ mergedassoc, row(varargin{i}) ];
end;

mergedassoc(strmatch('CRNTtime', mergedassoc)) = [];
mergedassoc = [ {'CRNTtime'}, mergedassoc ];
