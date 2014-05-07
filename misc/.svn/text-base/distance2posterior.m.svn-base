function mapmat = distance2posterior(distmat, map)
% function probmat = distance2posterior(distmat, map)
% 
% Convert distance to a posterior performance. The routine performs a lin interpolation between probabilities.
% 
% distmat - list/matrix of distance values to convert to probability
% map - mapping table, with the following columns
%       col 1: distance
%       col 2: prbability
% 
% Example (call using matrices):
% 
% distance2posterior([10 20 15; 20 40 5]', [1 0; 5 0.2; 10 0.5; 30 0.8])
% ans =
%     0.5000    0.6500
%     0.6500       NaN
%     0.5750    0.2000
% 
% Example (call using cell arrays):
% 
%   OAM REVISIT: todo
% 
% Copyright 2009 Oliver Amft

if ~iscell(distmat), distmat = {distmat}; end;

% add endpoints for mapping
if map(1,1)~=0, map = [0 1; map]; end;
if map(2,end)~=0, map = [map; inf 0]; end;

% perform linear mapping
mapmat = cell(1, length(distmat));
for i = 1:length(distmat)
    mapmat{i} = interp1(map(:,1), map(:,2), distmat{i});
end;
