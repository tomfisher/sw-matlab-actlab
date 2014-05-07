function thisfeature = feature_HRVBANDS(Pxx, F)
% function thisfeature = feature_HRVBANDS(Pxx, F)
%
% Spectral power of HRV analysis specific frequency bands.
%
% VLF           <= F < 0.04 Hz
% LF  0.04 Hz   <= F < 0.15 Hz
% HF  0.15 Hz   <= F < 0.4 Hz
%

% Compute spectral power ..
deltaF = diff(F(1:2));
feature_VLF = sum(Pxx(F < .04)) * deltaF;
feature_LF = sum(Pxx(F < .15)) * deltaF - feature_VLF;
feature_HF = sum(Pxx(F < .4)) * deltaF - feature_LF - feature_VLF;

% .. and normalise by length
feature_LFnu = feature_LF / (sum(Pxx(F < .4)) * deltaF - feature_VLF + eps) * 100;
feature_HFnu = 100 - feature_LFnu;

feature_LFHFratio = feature_LF / (feature_HF + eps);

thisfeature = [feature_VLF feature_LF feature_HF feature_LFnu feature_HFnu feature_LFHFratio];