function [thisfeature F] = feature_SSKEWNESS(din, varargin)
% function thisfeature = feature_SSKEWNESS(din, varargin)
%
% Spectral Skewness (asymmetry of the spectral distribution around its mean
% which basically equals the 3rd order moment)
%
% 'din' shall be rms-normalised.

% 2007, Martin Kusserow, Wearable Computing Lab, ETH Zurich

fftsize = process_options(varargin, 'fftsize', length(din));

% use 1st order moment so we don't have to compute the fft twice
[mu F] = feature_SCENTROID(din, 'fftsize', fftsize );

f = (1:length(F))';
cm3 = sum( (f - mu).^3 .* F(:)) / (sum(F) + 1e-20);
sigma3 = (sqrt(sum( f.^2 .* F(:)) / (sum(F) + 1e-20) - mu^2))^3;

% compute skewness
thisfeature = cm3 / sigma3;
