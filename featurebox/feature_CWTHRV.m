function thisfeature = feature_CWTHRV(rdata, fs, varargin)
%
%
%

[wname cwtres] = process_options(varargin, 'wname', 'gaus4', 'cwtres', 64);

% Wavelet center frequency
fc = centfrq(wname);
% Linear mode distribution
N = cwtres; a = fc / 0.04 * fs; b = fc / 0.4 * fs; scal = a:(b-a)/(N-1):b;
frq = scal2frq(scal, wname, 1/fs);

% CWT power
thisfeature = feature_CWT(rdata, scal, 'wname', wname, 'fname', 'energy');

% HRV band energy extraction
thisfeature = feature_HRVBANDS(thisfeature, frq);