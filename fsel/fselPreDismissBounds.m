function [veWeight] = fselPreDismissBounds(maData, veWeight, lim_down, lim_up)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
%
% dismissBounds checks if data (observations) of a feature are out of the 
% [lim_down,lim_up] bound. If so, it sets the rank of the feature to zero.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get dimensions of input data matrix
[obs feats] = size( maData );

% check every feature for over or underflow
for i=1:feats
  % underflow  
  if ( min(maData(:,i)) < lim_down  ) 
    fprintf( '[dataClip] Feature %d clipped (underflow)\n', i );
    % disable feature
    veWeight(i) = 0;
  end
  % overflow
  if ( max(maData(:,i)) > lim_up )
    fprintf( '[dataClip] Feature %d clipped (overflow)\n', i );
    % disable feature
    veWeight(i) = 0;
  end
end
