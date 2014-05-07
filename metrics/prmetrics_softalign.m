function prmetric = prmetrics_softalign(sections_REF, sections_EVAL, varargin)
% function prmetric = prmetrics_softalign(sections_REF, sections_EVAL, varargin)
%
% Create a PR performance metric struct from section lists, using soft alignment technique.
% 
% This code is based on: 
%   Amft and Troester, Artificial Intelligence in Medicine, 2008, 42, 121-136
%
% Parameters: 
%   sections_REF  - ground truth
%   sections_EVAL - evaluation segmentation (may be a cell list)
%
% Options:
%   Jitter - soft alignment segment jitter (test for any overlap: set to zero)
%   LabelConfThres  - omit ref and eval sections below confidence threshold
%   Greylist  - ignore eval sections that overlap with Greylist entries
% 
% sections_* should be vectors of style:
%   [beg1 end1; beg2 end2; ... begN endN]
% if LabelConfThres and/or Greylist is used sections_* should be vectors of style:
%   [beg1 end1 ignore ignore ignore confidence; ... begN endN ignore ignore ignore confidenceN]
% 
% Example:
% 
% prmetrics_softalign([100 200; 1000 3000], [1 99; 20 200; 199 201; 2000 2100; 2150 3000])
% 
% ans = 
% 
%       relevant: 2
%      retrieved: 5
%     recognised: 1
%         misses: 1
%           hits: 2
%      deletions: 1
%     insertions: 4
%         recall: 0.5000
%      precision: 0.2000
%       accuracy: 0.5000
%              f: 0.2857
% 
% See also: prmetrics_fromsegments.m, prmetrics_mkstruct.m, prmetrics_countoverlap.m
% 
% Copyright 2005-2010 Oliver Amft

[Jitter, LabelConfThres MaxLabelConfLimit, Greylist] = process_options(varargin, ...
	'Jitter', 0.5, 'LabelConfThres', 0, 'MaxLabelConfLimit', inf, 'Greylist', []);

% support of multiple eval lists (separate evauations)
if iscell(sections_EVAL)
    listcnt = length(sections_EVAL);
else
    listcnt = 1;
    sections_EVAL = {sections_EVAL};
end;

% find ref sections to delete
if LabelConfThres > 0
	if size(sections_REF,2)<6, error('\n%s: No confidence information found!', mfilename); end;
	rm_sections_REF = sections_REF( sections_REF(:,6)<LabelConfThres, : );
	sections_REF( sections_REF(:,6)<LabelConfThres, : ) = [];
else
	rm_sections_REF = [];
end;
if MaxLabelConfLimit < inf
	if size(sections_REF,2)<6, error('\n%s: No confidence information found!', mfilename); end;
        rm_sections_REF = [rm_sections_REF; sections_REF( sections_REF(:,6)>MaxLabelConfLimit, : )];
	sections_REF( sections_REF(:,6)>MaxLabelConfLimit, : ) = [];
end;


% check overlaps with greylist
if ~isempty(Greylist)
	if (prmetrics_countoverlap(sections_REF, Greylist)>0)
		warning('prmetrics_softalign:Greylist', 'Detected overlap of REF list with Greylist!');
	end;
end;

if ~isempty(sections_REF) && ...
        ( any(diff(sections_REF(:,1))<=0) || any(diff(sections_REF(:,2))<=0) ), 
    error('Non-continuous sections_REF. Stop.'); 
end;

% parse all eval results
for list = 1:listcnt
    if ~isempty(sections_EVAL{list}) && ...
            ( any(diff(sections_EVAL{list}(:,1))<=0) || any(diff(sections_EVAL{list}(:,2))<=0) )
        error('Non-continuous sections_EVAL{%u}. Stop.', list); 
    end;
    
	% remove sections from eval iff in/overlap with rm_sections_REF
	rm_ovs1 = prmetrics_countoverlap(sections_EVAL{list}, rm_sections_REF) > 0; % overlaps with rm_sections_REF
	rm_ovs2 = prmetrics_countoverlap(sections_EVAL{list}, sections_REF) == 0; % NOT overlap with sections_REF
	sections_EVAL{list}(rm_ovs1 & rm_ovs2,:) = [];  % excude sections

	% remove sections from eval if overlap with Greylist
	rm_ovs = prmetrics_countoverlap(sections_EVAL{list}, Greylist) > 0; 
	sections_EVAL{list}(rm_ovs,:) = [];
	
	% compute metrics
    matchlist = prmetrics_countoverlap(sections_REF, sections_EVAL{list}, Jitter);
    matches = find(matchlist > 0);
    
    % When jitter is large, segments from EVAL may overlap with more than
    % one REF segment satisfying the jitter requirement (the segment fits in
	% between two GT labels). Generally jitter should be decreased in this
	% case. This is a shortcomming of the method.
	% Here stupid results (insertions<0) are prevented by limiting the 
	% number of recognised to the number of retrieved segments.
    if (length(matches) > size(sections_EVAL{list},1)) 
		if (Jitter < inf)
			fprintf('\n%s: Limiting multiple GT matches: matches=%u, retrieved=%u, Jitter=%0.1f.', ...
				mfilename, length(matches), size(sections_EVAL{list},1), Jitter);
			fprintf('\n%s: Probable reason is a large value for variable Jitter', mfilename);
		end;
        matches = matches(1:size(sections_EVAL{list},1)); 
    end;

    recognised = length(matches);
    retrieved = size(sections_EVAL{list},1);
    relevant = size(sections_REF,1);

    misses = find(matchlist==0);
    hits = matches;

    prmetric(list) = prmetrics_mkstruct(relevant, retrieved, recognised, misses, hits);
end; % for list