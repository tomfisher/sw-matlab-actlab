function [thisfeature fdata fdata_squared] = feature_BWIDTH(din, varargin)
% function [thisfeature fdata fdata_squared] = feature_BWIDTH(din)
%
% Signal bandwidth
% 'din' shall be rms-normalised.
% 
% Copyright 2006-2008 Oliver Amft

% MK REVISIT: Optional parameter for N-point fft (assert spectral resolution)
fftsize = process_options(varargin, 'fftsize', length(din));

[fdata fdata_squared] = feature_fft(din, fftsize);

% center of mass/gravity
cg = sum( (1:length(fdata))' .* fdata(:)) / sum(fdata);

thisfeature = sum( (( (1:length(fdata))' - cg).^2) .* (fdata_squared(:)) );

thisfeature = sqrt(thisfeature / sum(fdata_squared));
