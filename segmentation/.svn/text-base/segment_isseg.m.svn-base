function [isseg] = segment_isseg(seg, buffer)
% segment_isseg: determine whether supplied segment could be valid

isseg = true; % yes we think the best ;-)


if isempty(seg)
    isseg = false;
    return;
end;
if (segment_size(seg) <= 0)
    isseg = false;
    return;
end;


if (nargin > 1)

    % check boudaries of buffer
    if (seg(2) > length(buffer))
        isseg = false;
        return;
    end;
    
end;
