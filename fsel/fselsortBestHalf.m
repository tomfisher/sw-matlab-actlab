function [veRank] = fselsortBestHalf( maDataTrain, veLabelTrain, veRank );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
%
% Dummy function for feature sorting. Feature will be taken if rank >.5
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dismiss every feature with a rank < 0.5 and set oterhs to 0
for i=1:length(veRank)
  if ( veRank(i) < 0.5 )
    veRank(i) = 0;
  end
end

