function [thisfeature fdata fdata_squared] = feature_BANDS(din, varargin)
% function [thisfeature fdata fdata_squared] = feature_BANDS(din, varargin)
%
% Band energy
% din should be RMS-nomalised, e.g. using feature_rms.m
%
% optional parameters:
% nbands       - number of bands, default: 4
% bandsplit    - 'logarithmic' or 'linear'
% 
% Copyright 2006 Oliver Amft

% MK REVISIT: Optional parameter for N-point fft (assert spectral resolution)
[nrBands, BandType, fftsize] = process_options(varargin, ...
    'nrBands', 4, 'BandType', 'logarithmic', 'fftsize', length(din));

% din = feature_rms(din);
% din = din(:) .* hann(length(din));

[fdata fdata_squared] = feature_fft(din, fftsize);

% total power - equ. feature_power()
ptot = sum(fdata_squared);

switch BandType
    case {'logarithmic', 'log'}
        bands = floor((2.^(-nrBands:0)) * length(fdata));
    case {'linear', 'lin'}
        bands = floor(( (0:nrBands) / nrBands) * length(fdata));
    otherwise
        error('%s: Unknown bandsplitting %s', mfilename, bandsplitting);
end;

band_energy = zeros(nrBands,1);
for i = 1:nrBands
    signal_band =  fdata(bands(i)+1 : bands(i+1));
    band_energy(i) = sum(signal_band .* signal_band);
end
thisfeature = band_energy ./ ptot;

thisfeature = thisfeature(:)';