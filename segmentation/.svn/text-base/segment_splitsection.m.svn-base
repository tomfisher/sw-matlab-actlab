function newlist = segment_splitsection(seglist, cutpoints, varargin)
% function newlist = segment_splitsection(seglist, cutpoints, varargin)
% 
% Split sections according to cutpoints
% 
% Example:
% segment_splitsection([100 200], 110)
% 
% ans =
% 
%    100   110
%    111   200
%    
% Copyright 2010 Oliver Amft

listcols = size(seglist,2);
newlist  = seglist;

[Mode verbose] = process_options(varargin, 'mode', 'absolute', 'verbose', 0);

for i = 1:length(cutpoints)
    % find sections to cut
    
    switch Mode
        case 'absolute'
            % result may be not unique, since cutpos is returned for each section
            n1 = newlist(:,1)<=cutpoints(i);  n2 = newlist(:,2)>cutpoints(i);
            cutpos = find(n1 & n2);  % cutpos = find(isbetween(cutpoints(i), newlist));
            cutpoint_r = cutpoints(i);
        case 'offset'
            % result is unique, e.g. only one cutpos is found since all sizes are added
            % size count is relative, thus for section [100 200] the cutpoint at 50 returns two sections
            csum = cumsum([1; segment_size(newlist)]);
            tlist = offsets2segments(csum-1);
            n1 = tlist(:,1)<=cutpoints(i);  n2 = tlist(:,2)>cutpoints(i);
            cutpos = find(n1 & n2);
            if isempty(cutpos), continue; end;
            cutpoint_r = (cutpoints(i)-csum(cutpos)) + newlist(cutpos,1);
        otherwise
            error('Mode not understood.');
    end;
    
    % cut existing ones to the length, save new sections and insert them later
    news = zeros(length(cutpos), listcols);
    for j = 1:length(cutpos)
        tmp = newlist(cutpos(j),:);
        newlist(cutpos(j),2) = cutpoint_r;
        if listcols>=3, newlist(cutpos(j),3) = segment_size(newlist(cutpos(j),:)); end;
        
        news(j,1:2) = [cutpoint_r+1, tmp(2)]; 
        if listcols>=3, news(j,3) = segment_size(news(j,:)); end;
        if listcols>=4, news(j,4) = tmp(4); end;
    end;
    newlist = [ newlist; news ];
end;

newlist = segment_sort(newlist);