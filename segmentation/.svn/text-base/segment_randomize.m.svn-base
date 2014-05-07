function SegRand = segment_randomize(SegTS, seed)
% function SegRand = segment_randomize(SegTS, seed)
% 
% Reorders segment list randomly using seed when available
% 
% Copyright 2006, 2009 Oliver Amft

if ~exist('seed', 'var'), 
    %seed = randint(1,1,[1 size(SegTS,1)]);
    seed = randi([1 size(SegTS,1)], 1,1);
end;

SegRand = randintrlv(SegTS, seed);
