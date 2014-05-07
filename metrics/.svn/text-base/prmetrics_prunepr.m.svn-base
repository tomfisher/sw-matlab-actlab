function [prunedmetric goodones] = prmetrics_prunepr(prmetric, varargin)
% function [prunedmetric goodones] = prmetrics_prunepr(prmetric, varargin)
%
% Prune out metric elements that are not distinct.
%
% Options:
%   Enable - Selectivly enable methods (Default: all on)
%   SupportPDelta - Min. summed PR-distance between points
%   RecallPDist - Min. distance between recall points
%
% View results with:
%   prmetrics_plotpr('view', [], prmetrics_sort(prunedmetric))
%
% See also: prmetrics_plotpr, prmetrics_getpr
% 
% Copyright 2008 Oliver Amft
warning('Superseeded by prmetrics_prprune.');

methods = 8;  % nr of available pruning steps

[Enable SupportPDelta RecallPDist verbose] = process_options(varargin, ...
	'Enable', true(1, methods), 'SupportPDelta', 0.005, 'RecallPDist', 0, 'verbose', 1);

% only iff Enable=0
if (length(Enable)==1) && (Enable==0), Enable = repmat(Enable, 1, methods); end;

if any(Enable>1)
	% interpret as numeric, convert to one-hot
	tmp = false(1, methods);
	tmp(Enable) = true;
	Enable = tmp;
end;

[precision recall] = prmetrics_getpr(prmetric);
prlist = [precision recall col(1:length(prmetric))];  % last column marks original elements

if (verbose), fprintf('\n%s: Total initial points: %u', mfilename, length(prmetric)); end;




% find pareto points, keep first
if Enable(2)
	i = 1;  deleted = 0;
	while (i < size(prlist,1))
		covered = (prlist(i,1) >= prlist(:,1)) & (prlist(i,2) >= prlist(:,2));
		covered(1) = false; %covered(end) = false;
		covered(i) = false;

		deleted = deleted + sum(covered);
		prlist(covered,:) = [];
		i = i + 1;
	end;
	if (verbose), fprintf('\n%s: Pareto points: %u', mfilename, deleted); end;
end;

% remove equal points from begin and end (not visible anyway)
if Enable(3)
	equals = (prlist(1,1)==prlist(:,1)) & (prlist(1,2)==prlist(:,2)); equals(end) = 0;
	prlist(equals,:) = [];
	deleted = sum(equals);
	if (verbose), fprintf('\n%s: Equal points at begin: %u', mfilename, deleted); end;
end;
if Enable(4)
	equals = (prlist(end,1)==prlist(:,1)) & (prlist(end,2)==prlist(:,2)); equals(end) = 0;
	prlist(equals,:) = [];
	deleted = sum(equals);
	if (verbose), fprintf('\n%s: Equal points at end: %u', mfilename, deleted); end;
end;

% remove intermediate support points that are too close to each other
if Enable(5)
	diffs = abs(diff(prlist(:,1:2),[],1)); diffs = [false; sum(diffs,2)<SupportPDelta]; diffs(end) = false;
	prlist(diffs,:) = [];
	deleted = sum(diffs);
	if (verbose), fprintf('\n%s: Intermediate support points (%.3f): %u', mfilename, SupportPDelta, deleted); end;
end;

% remove low precision points for same recall
if Enable(6)
	i = 1;  deleted = 0;
	while (i < size(prlist,1))
		pall = find(prlist(i,2)==prlist(:,2));
		[dummy pkeep] = max(prlist(pall,1));
		pall(pkeep) = [];

		deleted = deleted + length(pall);
		prlist(pall,:) = [];
		i = i + 1;
	end;
	if (verbose), fprintf('\n%s: Low precision points: %u', mfilename, deleted); end;
end;

% remove too close recall points
if Enable(7)
	diffs = abs(diff(prlist(:,2))); diffs = [false; sum(diffs,2)<RecallPDist]; diffs(end) = 0;
	prlist(diffs,:) = [];
	deleted = sum(diffs);
	if (verbose), fprintf('\n%s: Close recall points (%.3f): %u', mfilename, RecallPDist, deleted); end;
end;

% remove NAN precision points
if Enable(8)
	rmpts = isnan(prlist(:,1));
	prlist(rmpts,:) = [];
	deleted = sum(rmpts);
	if (verbose), fprintf('\n%s: NAN precision points: %u', mfilename, deleted); end;
end;

% delete 0,0 points
if Enable(1)
	zeropt = false(length(prmetric),1);
	zeropt(sum(prlist(:,1:2),2)==0) = true;
	zeropt(sum(isnan(prlist(:,1:2)),2)>0) = true;
	prlist(zeropt,:) = [];
	deleted = sum(zeropt);
	if (verbose), fprintf('\n%s: Delete (0,0): %u', mfilename, deleted); end;
%     prlist = [1 0 1; prlist];
end;

goodones = false(1, length(prmetric));
goodones(prlist(:,3)) = true;

prunedmetric = prmetric(goodones);
if (verbose), fprintf('\n%s: Total points kept: %u', mfilename, length(prunedmetric)); end;
