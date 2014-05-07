function [dout count] = mkclipping( din, limit)
% function [dout count] = mkclipping( din, limit)
%
% Threshold data after centering at the limit given. If no limit is defined
% limit is set to 3x std(din). din is a matrix whos columns equal
% variables and rows observations
% [obs1_v1, ... obs1_vn; 
%  obs2_v1, ... obs2_vn; ... ], 
% thus limit has to be provided per row.
% 
% [dout count] = clipping( ... ) additionally gives the count of how many
% times clipping has been performed per row.
%

% MK 20061226 REVISITED: Recoded in matrix expression
% MK 20070110 BUGFIX: Proper data centering and comments
% MK 20070111 REVISITED: Added input variable check



if ~exist('limit')
    limit = 3 * std(din);
end;

if size(din,1) == 1 || ~sum(limit)
    dout = din;
    count = zeros(1, size(din,2));
    return;
end;

if (size(limit,2) ~= size(din,2))
    error('Number of columns must agree.' );
end;

% number of observations
nobs = size(din,1);

% extend limit to matrix dimensions
lmat = repmat(limit(:)', nobs, 1);

% mean matrix of din
mmat = repmat(mean(din), nobs, 1);

% determine values to clip
cmat = lmat < (abs(din - mmat));

% perform clipping
dout = (sign(din) .* cmat .* (lmat + abs(mmat))) + (~cmat .* din);
count = sum(cmat);


% % % % % END OF FILE