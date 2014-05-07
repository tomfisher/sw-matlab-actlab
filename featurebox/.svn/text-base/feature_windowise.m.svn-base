function wdata = feature_windowise(sdata, windowfcn)
% function wdata = feature_windowise(sdata, windowfcn)
% 
% Helper to apply windowing function to cutted data slices
% 
% Copyright 2008 Oliver Amft

if ~exist('windowfcn','var') || isempty(windowfcn), windowfcn = @hann; end;

% OAM REVISIT: Hack
% windowfcn = @hamming;

wdata = sdata .* windowfcn(length(sdata));