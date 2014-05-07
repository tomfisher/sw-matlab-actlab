function ok = marker_player_playnancy(fh, drawerobj, playrange_r, splot, playerselect)
% function ok = marker_player_playnancy(fh, drawerobj, playrange_r, splot, playerselect)
%
% Player method for displaying motion using the Nancy VRML aviatar.
%
% 
% Copyright 2007 Oliver Amft
% 
% Requires code NOT included in MARKER toolbox due to licensing issues.

ok = false;

Repository = drawerobj.disp(splot).playerdata(playerselect).Repository;
Partindex = drawerobj.disp(splot).playerdata(playerselect).Partindex;

% get sample rate
[dummy sps] = xsens_getdata(Repository, Partindex, 'Range', [1 2]);

% adapt play section boundaries
playrange_r = ceil(playrange_r * sps/drawerobj.disp(splot).sfreq);
playrange_r(:,1) = playrange_r(:,1)-ceil(sps/drawerobj.disp(splot).sfreq)+1;

% load and play this section
nancy_range(Repository, Partindex, playrange_r);
