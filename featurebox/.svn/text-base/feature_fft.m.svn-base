function [fdata fdata_squared] = feature_fft(rdata, fftsize)
% function [fdata fdata_squared] = feature_fft(rdata, fftsize)
%
% Signal FFT and FFT*FFT
% 'data' should be rms-normalised.

if (~exist('fftsize','var')), fftsize = length(rdata); end;

% ffdata = fft(rdata(:) .* hanning(length(rdata)), fftsize);
ffdata = fft(rdata(:) .* hann(length(rdata)), fftsize);
fdata = abs(ffdata(1:round(fftsize/2)));

if (nargout > 1)
    fdata_squared = fdata .* fdata;
end;

