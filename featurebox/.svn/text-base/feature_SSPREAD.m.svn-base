function [thisfeature F] = feature_SSPREAD(din, varargin)
% function thisfeature = feature_SSPREAD(din, varargin)
%
% Spectral Spread
% 'din' shall be rms-normalised.

% 2007, Martin Kusserow, Wearable Computing Lab, ETH Zurich

fftsize = process_options(varargin, 'fftsize', length(din));

% use 1st order moment so we don't have to compute the fft twice
[mu F] = feature_SCENTROID(din, 'fftsize', fftsize );

f = (1:length(F))';

% variance = 2nd order moment - 1st order moment squared
thisfeature = sum( f.^2 .* F(:)) / (sum(F) + 1e-20) - mu^2;

% alternative computataion
%thisfeature = sum( (f - mu).^2 .* F(:)) / (sum(F) + 1e-20);
