function [newseg] = segment_sub(seg1, seg2, mode)
% segment_sub: subtract segment seg2 from seg1
%
% mode:         select where to subtract seg2 from seg1 begin/end
% 
% Copyright 2004 Oliver Amft, ETH Zurich, oam@ife.ee.ethz.ch

if (~exist('mode','var')), mode = 'Begin'; end;

switch upper(mode)
    case 'BEGIN'
        newseg(1) = seg1(1) + segment_size(seg2);
        newseg(2) = seg1(2);
    case 'END'
        newseg(1) = seg1(1);
        newseg(2) = seg1(2) - segment_size(seg2);
end;

if (segment_size(newseg) < 0)
    error('segment_sub: Segment boudary error');
end;

return;
