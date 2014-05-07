function thisfeature = feature_FFTHRV(rdata, fs, varargin)
%function thisfeature = feature_FFTHRV(rdata, fs, varargin)
%
%
%

fftsize = process_options(varargin, 'fftsize', bitshift(fs,7));
swstep = ceil(fftsize/2); 
sw = window(@hanning, fftsize);

[Pxx F] = pwelch(rdata, sw, swstep, fftsize, fs);
% Half the power as one-side PSD estimate contains total power of the input
% signal. Refer to help pwelch for more details.
Pxx = Pxx / 2;

% HRV band energy extraction
thisfeature = feature_HRVBANDS(Pxx, F);