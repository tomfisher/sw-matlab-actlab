function segment_ploteye(data, seglist)
% function segment_ploteye(data, seglist)
%
% segment_ploteye: plot segments as eye diagram

hold on;
for (seg = 1:size(seglist, 1))
    plot(data(seglist(seg,1):seglist(seg,2)));
end;
