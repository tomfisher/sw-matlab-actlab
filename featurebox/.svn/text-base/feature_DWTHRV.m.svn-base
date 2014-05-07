function thisfeature = feature_DWTHRV(rdata, fs, varargin)
%
%
%

wname = process_options(varargin, 'wname', 'db1');

% Wavelet center frequency
fc = centfrq(wname);
% Pseudo-frequency fa [.04 .4] Hz
fa_LF = [.04 .15];
fa_HF = [.15 .4];
% Scales
a_LF = 1./fa_LF*fc*fs;
a_HF = 1./fa_HF*fc*fs;
% Check signal length for decomposition
maxlv = wmaxlev(length(rdata), wname);
lv = ceil(log2(max(a_LF)));
% Ensure at least >1 sample left at highest decomposition level
if (maxlv < lv),
    % Error message, signal too short for HRV analysis
    ...
        return;
end;

% Compute scales for the HRV bands
dwtscales_LF = ceil(log2(min(a_LF))):ceil(log2(max(a_LF)));
dwtscales_HF = ceil(log2(min(a_HF))):ceil(log2(max(a_HF)));
% Determine overlap scale
if length(dwtscales_LF) > length(dwtscales_HF)
    % Shrink LF
    dwtscales_LF = setdiff(dwtscales_LF,intersect(dwtscales_HF,dwtscales_LF));
else
    % Shrink HF
    dwtscales_HF = setdiff(dwtscales_HF,intersect(dwtscales_HF,dwtscales_LF));
end;
dwtscales = union(dwtscales_HF,dwtscales_LF);

% Compute wavelet spectral power [E Ea Ed]
thisfeature = feature_DWT(rdata, dwtscales, 'wname', wname, 'fname', 'energy');

% HRV band energy extraction
E_VLF = thisfeature(2);
[notused1 idx notused2] = intersect(dwtscales, dwtscales_LF);
E_LF = sum(thisfeature(idx+2));
[notused1 idx notused2] = intersect(dwtscales, dwtscales_HF);
E_HF = sum(thisfeature(idx+2));
E_LFnu = E_LF / (E_LF + E_HF);
E_HFnu = E_HF / (E_LF + E_HF);
Er = E_LF / E_HF;

thisfeature = [E_VLF E_LF E_HF E_LFnu E_HFnu Er];