function [PartLabels LabelIndices] = repos_findlabelsforpart(SegLabels, PartNr, partoffsets, labelbase)
% function [PartLabels LabelIndices] = repos_findlabelsforpart(SegLabels, PartNr, partoffsets, labelbase)
%
% Return labels (segments) for part specified by PartNr from a larger list (SegLabels).
% 
% WARNING: Make sure PartNr is NOT a Partindex but a index refereing to the list in partoffsets.
%
% Parameters:
%       labelbase     Control PartLabels base, default: 'unchanged'
% 
% Copyright 2006-2008 Oliver Amft

PartLabels = []; LabelIndices = [];

if ~exist('labelbase','var'), labelbase = 'unchanged'; end;
if isempty(SegLabels) || isempty(PartNr) || isempty(partoffsets), return; end;
if length(partoffsets)<max(PartNr), error('PartNr and partoffsets do not match.'); end;

PartLabels = [];
for pn = 1:length(PartNr)
	intervall = [partoffsets(PartNr(pn))+1 partoffsets(PartNr(pn)+1)];
    
    % check for labels that exceed intervall boundaries
    if any(xor(isbetween(SegLabels(:,1), intervall), isbetween(SegLabels(:,2), intervall) ))
    %     if ~any(isbetween(SegLabels(:,1), intervall) & isbetween(SegLabels(:,2), intervall))
    %if any(xor(isbetween(intervall(1), SegLabels(:,1:2)), isbetween(intervall(2), SegLabels(:,1:2)) ))
        error('Label exceeds partsize for part=%u.', PartNr(pn) );
    end;

    % segment list w/o cells
	LabelIndices = segment_findincluded(intervall, SegLabels(:,1:2));
    PartLabels = [ PartLabels; SegLabels(LabelIndices ,:) ];
    
    switch lower(labelbase)
        case 'remove'
            PartLabels = [(PartLabels(:,1:2) - intervall(1)+1)   PartLabels(:,3:end)];
    end;
end;
PartLabels = segment_sort(PartLabels);



% if iscell(SegLabels)
%     % CLA list
% 	PartLabels = cell(1, length(SegLabels));
%     LabelIndices = cell(1, length(SegLabels));
% 	for class = 1:length(SegLabels)
% 		if (isempty(SegLabels{class})), continue; end;
% 		LabelIndices{class} = segment_findincluded(intervall, SegLabels{class}(:,1:2));
% 		PartLabels{class} = SegLabels{class}(LabelIndices ,:);
% 
% 		switch lower(labelbase)
% 			case 'remove'
% 				PartLabels{class} = [(PartLabels{class}(:,1:2) - intervall(1)+1)   PartLabels{class}(:,3:end)];
% 		end;
% 	end; % for class
% else
