function [thisfeature rms] = feature_rms(sdata, enable)
% function [thisfeature rms] = feature_rms(sdata, enable)
%
% Root mean square normalisation
% 
% Copyright 2006-2008 Oliver Amft

rms = sqrt(sum(sdata.^2,1) / size(sdata,1));
rms = rms + eps*(rms==0);   % prevent div by zero if signal is zero

% enable controls if rms is applied to sdata
if ~exist('enable','var') || (enable == true)
	thisfeature = sdata ./ rms;
else
	thisfeature = sdata;
end;
