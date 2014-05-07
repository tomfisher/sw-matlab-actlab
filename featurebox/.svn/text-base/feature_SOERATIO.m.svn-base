function thisfeature = feature_SOERATIO(din, varargin)
% function thisfeature = feature_SOERATIO(din, varargin)
%
% Odd to even harmonic energy ratio.
%
% 'data' should be rms-normalised.

% 2007, Martin Kusserow, Wearable Computing Lab, ETH Zurich

fftsize = process_options(varargin, 'fftsize', length(din));

% We need at least 3 fft values returned by feature_fft. Since it only
% returns samples up to fs/2, we need an fftsize of at least 6. Using 8
% we're safe.
fftsize = max(8, fftsize);

F = feature_fft(din, fftsize);

% MATLAB indices start at 1, hence first odd harmonic is at index 2 while
% first even harmonic is at index 3.
thisfeature = sum(F(2:2:end).^2)/sum(F(3:2:end).^2);