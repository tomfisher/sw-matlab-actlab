function thisfeature = feature_ZCR(rdata)
% function thisfeature = feature_ZCR(rdata)
%
% Zero crossing rate
% 'data' should be rms-normalised.
% 
% Copyright 2006 Oliver Amft
% 
% 2008/01/28: Optimised code, Oliver

% thisfeature = 0;
% for i = 1:length(rdata) - 1
%     thisfeature = thisfeature + ((rdata(i) * rdata(i+1)) < 0);
% end;

thisfeature = sum(abs(diff(sign(rdata))))/2;
thisfeature = thisfeature / length(rdata);
