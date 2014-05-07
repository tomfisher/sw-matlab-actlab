function [thisfeature fdata fdata_squared] = feature_ROLLOFF(din, varargin)
% function [thisfeature fdata fdata_squared] = feature_ROLLOFF(din, varargin)
%
% Spectral rolloff point
% 'din' shall be rms-normalised.
%
% optinal parameters:
% RolloffFactor     - Rolloff factor, default: 0.9
% 
% Copyright 2006 Oliver Amft

% MK REVISIT: Optional parameter for N-point fft (assert spectral resolution)
[RolloffFactor fftsize] = process_options(varargin,  'RolloffFactor', 0.95, 'fftsize', length(din));

[fdata fdata_squared] = feature_fft(din, fftsize);

cummulativePower = 0;
for i = 1:length(fdata)
    cummulativePower = cummulativePower + fdata_squared(i);
    if cummulativePower >= RolloffFactor * sum(fdata_squared);
        break;
    end;
end
thisfeature = i;