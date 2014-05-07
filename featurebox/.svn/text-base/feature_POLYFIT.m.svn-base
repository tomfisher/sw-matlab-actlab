function [coef res]=feature_POLYFIT(rdata, degree)
% function [coef res]=feature_POLYFIT(rdata, degree)
% 
% Polynomial curve fitting of slected degree, default: 1
% 
% Copyright 2007 Oliver Amft

if ~exist('degree','var'), degree = 1; end;

rdata = feature_rms(rdata);

coef = polyfit(1:length(rdata), rdata(:)', degree);

residual = rdata(:)' -  (coef(1) * (1:length(rdata)) + coef(2));

res = [mean(residual) var(residual)];