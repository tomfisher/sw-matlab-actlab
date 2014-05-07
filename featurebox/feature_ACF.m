function thisfeature = feature_ACF(din, varargin)
%function thisfeature = feature_ACF(din, varargin)
%
% Auto-correlation function
% din should be RMS-nomalised, e.g. using feature_rms.m
%
% (based on MATLABs 'autocorr' function)
% The ACF computation is based on Box, Jenkins, Reinsel, pages 30-34, 188.
% 
% 2007, Martin Kusserow, Wearable Computing Lab, ETH Zurich
% 20081116, oam: modified lags assignment, omit first value since ACF(1) == 1.

[fftsize nrLags] = process_options(varargin, 'fftsize', length(din), 'nrLags', 12 );

% We need at least 24 fft values to return 12 lags. Using this formula we're pretty much on the safe side
fftsize = max(2*2^nextpow2(nrLags), fftsize);

% OAM REVISIT: added windowing
% din = feature_rms(din);
din = din(:) .* hann(length(din));

F    =  fft(din - mean(din) , fftsize);
F    =  F .* conj(F);
ACF  =  ifft(F);

% retain non-negative lags
ACF  =  ACF(1:nrLags+1);         

% normalisation
ACF  =  ACF ./ (ACF(1) + eps); %+ 1e-20);     

% assert row vector
thisfeature  =  real(ACF(2:end)');

