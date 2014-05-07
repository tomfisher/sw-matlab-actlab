function [idx e] = segment_findsimilar(SegList, CmpList, varargin)
% function [idx e] = segment_findsimilar(SegList, CmpList, varargin)
%
% Find most similar segment (considers columns 1,2) in CmpList. If multiple
% identical segments are found, returns first hit only.
%
% idx - contains most similar index in CmpList with respect to SegList. 
% e - is an error measure of begin and end differences normalised by the
%       respective section in SegList.
%
% See also: segment_findequals.m, segment_findidentical.m
% 
% Copyright 2008 Oliver Amft

idx = zeros(size(SegList,1), 1);   e = zeros(size(SegList,1), 1);

for i = 1:size(SegList,1)
	% find differences of begin and end
	bdiff = abs(SegList(i,1)-CmpList(:,1));  	ediff = abs(SegList(i,2)-CmpList(:,2));
	% best one is closest for begin and end
	tdiff = (bdiff + ediff)/2;
	% result is minimum
	[e(i) idx(i)] = min(tdiff);
end; % for i

e = e ./ segment_size(SegList);