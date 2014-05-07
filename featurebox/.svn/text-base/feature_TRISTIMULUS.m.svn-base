function thisfeature = feature_TRISTIMULUS(din, varargin)
% function thisfeature = feature_TRISTIMULUS(din, varargin)
%
% Spectral Tristimulus T1, T2 and T3
%
% 'data' should be rms-normalised.

% 2007, Martin Kusserow, Wearable Computing Lab, ETH Zurich
% Pollard et al. 1982

fftsize = process_options(varargin, 'fftsize', length(din));

% We need at least 6 fft values returned by feature_fft. Since it only
% returns samples up to fs/2, we need an fftsize of at least 12. Using 32
% we're safe.
fftsize = max(32, fftsize);

F = feature_fft(din, fftsize);

% MATLAB indices start at 1, hence first harmonic is at 2!
sF = sum(F(2:end));
if (sF==0), error('here'); end;

T1 = F(2)/sF;
T2 = sum(F(3:5))/sF;
T3 = sum(F(6:end))/sF;

thisfeature = [T1 T2 T3];
