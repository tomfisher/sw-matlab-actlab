function [prunedmetric goodones] = prmetrics_prprune(prmetric, varargin)
% function [prunedmetric goodones] = prmetrics_prprune(prmetric, varargin)
%
% Prune out metric elements that are not distinct.
%
% Functions:
%   eqpoints - remove identical points
%   paretofront - retain pareto front
%
% View results with:
%   prmetrics_prplot(prmetrics_sort(prunedmetric))
%
% Example: prmetrics_prprune(prmetric, 'rmnan', 'idpoints', 'paretofront', 'bestp', 'closepr', 0.05)
% 
% 
% See also: prmetrics_plotpr, prmetrics_getpr
% 
% Superseeds: prmetrics_prunepr
% 
% Copyright 2009-2010 Oliver Amft

verbose = 0;

[prmetric sidx] = prmetrics_sort(prmetric);
[precision recall] = prmetrics_getpr(prmetric);
prlist = [precision recall sidx];  % last column marks original elements

argnr = 1;
while argnr<=length(varargin)
    if isempty(prlist), break; end;
    switch varargin{argnr}
        case 'verbose'
            verbose = varargin{argnr+1};
            if (verbose), fprintf('\n%s: Total initial points: %u', mfilename, length(prmetric)); end;
            argnr = argnr + 1;
            
            
        case 'paretofront'  % find pareto points, keep first
            covered = false( size(prlist,1),1 );
            for i = 1:size(prlist,1)
                covered = covered | ( (prlist(i,1) >= prlist(:,1)) & (prlist(i,2) >= prlist(:,2)) );
                covered(i) = false;
            end;
            prlist(covered,:) = [];
            deleted = sum(covered);
            if (verbose), fprintf('\n%s: Pareto points: %u', mfilename, deleted); end;
            
        case 'idpoints'  % remove identical points from begin and end
            equals = (prlist(1,1)==prlist(:,1)) & (prlist(1,2)==prlist(:,2)); equals(end) = 0;
            prlist(equals,:) = [];
            deleted = sum(equals);
            if (verbose), fprintf('\n%s: Equal points at begin: %u', mfilename, deleted); end;
            equals = (prlist(end,1)==prlist(:,1)) & (prlist(end,2)==prlist(:,2)); equals(end) = 0;
            prlist(equals,:) = [];
            deleted = sum(equals);
            if (verbose), fprintf('\n%s: Equal points at end: %u', mfilename, deleted); end;
            
        case 'closepr'
            PRDelta = varargin{argnr+1};
            covered = [false; normv(diff(prlist(:,1:2),[],1))<PRDelta]; covered(end) = false;
            for i = 1:size(prlist,1)
                if covered(i) 
                    if all(prlist(i,1) > prlist(prlist(i,2)==prlist(:,2),1)), covered(i) = false; end;
                end;
            end;
            prlist(covered,:) = [];
            deleted = sum(covered);
            if (verbose), fprintf('\n%s: Close points: %u', mfilename, deleted); end;
            argnr = argnr + 1;
            
        case 'closeprec'  % remove intermediate support points that are too close to each other
            SupportPDelta = varargin{argnr+1};
            diffs = abs(diff(prlist(:,1:2),[],1)); diffs = [false; sum(diffs,2)<SupportPDelta]; diffs(end) = false;
            prlist(diffs,:) = [];
            deleted = sum(diffs);
            if (verbose), fprintf('\n%s: Intermediate support points (%.3f): %u', mfilename, SupportPDelta, deleted); end;
            argnr = argnr + 1;
            
        case 'closerec'  % remove too close recall points
            RecallPDist = varargin{argnr+1};
            diffs = abs(diff(prlist(:,2))); diffs = [false; sum(diffs,2)<RecallPDist]; diffs(end) = 0;
            prlist(diffs,:) = [];
            deleted = sum(diffs);
            if (verbose), fprintf('\n%s: Close recall points (%.3f): %u', mfilename, RecallPDist, deleted); end;
            argnr = argnr + 1;
            
        case 'rmnan' % remove NAN precision points
            rmpts = isnan(prlist(:,1));
            prlist(rmpts,:) = [];
            deleted = sum(rmpts);
            if (verbose), fprintf('\n%s: NAN precision points: %u', mfilename, deleted); end;
            
        case 'rm00'   % delete 0,0 points
            zeropt = false(length(prmetric),1);
            zeropt(sum(prlist(:,1:2),2)==0) = true;
            zeropt(sum(isnan(prlist(:,1:2)),2)>0) = true;
            prlist(zeropt,:) = [];
            deleted = sum(zeropt);
            if (verbose), fprintf('\n%s: Delete (0,0): %u', mfilename, deleted); end;
            
        case 'bestp'   % remove low precision points for same recall
            covered = false( size(prlist,1),1 );
            for i = 1:size(prlist,1)
                receq_match = prlist(i,2)==prlist(:,2);
                pmax = max(prlist(receq_match,1));
                covered(receq_match) = prlist(receq_match,1)<pmax;
            end;
            covered(end) = false;
            prlist(covered,:) = [];
            deleted = sum(covered);
%             i = 1;  deleted = 0;
%             while (i < size(prlist,1))
%                 pall = find(prlist(i,2)==prlist(:,2));
%                 [dummy pkeep] = max(prlist(pall,1));
%                 pall(pkeep) = [];
% 
%                 deleted = deleted + length(pall);
%                 prlist(pall,:) = [];
%                 i = i + 1;
%             end;
            if (verbose), fprintf('\n%s: Low precision points: %u', mfilename, deleted); end;
            
            
            
        otherwise
            error(['Command "' lower(varargin{argnr}) '" not recognised.']);
%             argnr = argnr - 1; % anticipate default increase
    end; % switch
    argnr = argnr + 1; % default behaviour: every command has NO argument
end; % while arg

if ~isempty(prlist)
    % OAM REVISIT: revert to unsorted list?
    goodones = false(1, length(prmetric));
    goodones(prlist(:,3)) = true;
    prunedmetric = prmetric(goodones);
else
    prunedmetric = [];
end;
if ~any(goodones==1), fprintf('\n%s: Warning: No good metrics retained.', mfilename); end;

if (verbose), fprintf('\n%s: Total points kept: %u', mfilename, length(prunedmetric)); end;
