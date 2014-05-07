function commonidx = segment_findidentical(seglist, varargin)
% function commonidx = segment_findidentical(seglist, varargin)
%
% Find identical segments in a list, return all identicals except LAST one.
% This can be used to remove identical segments, but leaving one copy.
%
% WARNING: This code assumes segments are sorted!
% 
% Example:
%   segment_findidentical([1 5; 1 5;1 10;1 10; 20 30])
%   ans =
%      1
%      3
%
% See also: segment_findequals.m
% 
% Copyright 2006 Oliver Amft

% seglist = segment_sort(seglist);

% OAM REVISIT: Its a pity that this code returns actual vector numbers instead of a onehot code
commonbeg = (diff(seglist(:,1)) == 0);
commonend = (diff(seglist(:,2)) == 0);
commonsegs = (commonbeg==1) & (commonend==1);
commonidx = find(commonsegs);


% commonbeg = find(diff(seglist(:,1)) == 0);
% commonend = find(diff(seglist(:,2)) == 0);
% commonbegend = commonbeg(commonbeg == commonend);
% commonsegs = commonbegend;

% commonlabel = find(diff(seglist(:,4)) == 0);
% commonsegs = commonbegend(commonbegend == commonlabel);
% 
% commonbegend = find(diff(seglist(commonbeg,2)) == 0);
% commonsegs = commonbeg(commonbegend);
% 
% % check label 
% if (~isempty(commonsegs)) && (size(seglist,2) >= 4)
%     commonseglabel = find(diff(seglist(commonsegs,4)) == 0);
%     commonsegs = commonsegs(commonseglabel);
% end;