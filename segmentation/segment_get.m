function data = segment_get(buffer, seg, dim)
% function data = segment_get(buffer, seg, dim)
%
% Return data segment from the supplied buffer
% 
% Copyright 2004 Oliver Amft

% OAM REVISIT: 
% Variable 'dim' has been added: check whether buffer data is in columns for old scripts.
% However nowhere used!
%
% Extend to strict/relaxed operation mode


if ~exist('dim','var'), dim = 1; end;
if size(buffer,2)>1, buffer = col(buffer); end;

if isempty(seg), data = []; return; end;

if (segment_size(seg) <= length(buffer))
    buffer = shiftdim(buffer, dim-1);
    
	if seg(2)>length(buffer), seg(2) = length(buffer); end;
    data = buffer(seg(1) : seg(2),:);

else

    % OAM REVISIT: This is bogus, incorrect requests should get [] answer
    % => check SWAB-routines calls
    data = buffer(:,dim);
    %     warning('Segment request is oversized.');
end;
