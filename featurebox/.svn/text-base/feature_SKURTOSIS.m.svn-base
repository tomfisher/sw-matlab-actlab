function [thisfeature F] = feature_SKURTOSIS(din, varargin)
% function thisfeature = feature_SKURTOSIS(din, varargin)
%
% Spectral Kurtosis (flatness of the spectral distribution around its mean
% which basically equals the 4th order moment)
%
% 'din' should be rms-normalised.

% 2007, Martin Kusserow, Wearable Computing Lab, ETH Zurich

fftsize = process_options(varargin, 'fftsize', length(din));

% use 1st order moment so we don't have to compute the fft twice
[mu F] = feature_SCENTROID(din, 'fftsize', fftsize );

f = (1:length(F))';
cm4 = sum( (f - mu).^4 .* F(:)) / (sum(F) + 1e-20);
sigma4 = (sum( f.^2 .* F(:)) / (sum(F) + 1e-20) - mu^2)^2;

% compute skewness
thisfeature = cm4 / sigma4;
