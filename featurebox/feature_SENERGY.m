function thisfeature = feature_SENERGY(din, varargin)
% function thisfeature = feature_SENERGY(din)
%
% Total spectral energy
% 'din' will be rms-normalised.

% (c) 2006 Oliver Amft, Wearable Computing Lab., ETH Zurich

% MK REVISIT: Optional parameter for N-point fft (assert spectral resolution)
fftsize = process_options(varargin, 'fftsize', length(din));

din = feature_rms(din);

[dummy fdata_squared] = feature_fft(din, fftsize);

thisfeature = sum(fdata_squared);
