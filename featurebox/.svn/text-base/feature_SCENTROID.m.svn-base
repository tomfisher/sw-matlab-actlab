function [thisfeature fdata] = feature_SCENTROID(din, varargin)
% function [thisfeature fdata] = feature_SCENTROID(din, varargin)
%
% spectral center of mass | centroid
% 'din' shall be rms-normalised.

% (c) 2006 Oliver Amft, Wearable Computing Lab., ETH Zurich

% mk revisit: Optional parameter for N-point fft (assert spectral resolution)
fftsize = process_options(varargin, 'fftsize', length(din));

% feature_fft returns spectrum until fs/2
fdata = feature_fft(din, fftsize);

f = (1:length(fdata))';
thisfeature = sum( f .* fdata(:)) / (sum(fdata) + 1e-20);