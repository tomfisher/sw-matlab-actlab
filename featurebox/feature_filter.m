function thisfeature = feature_filter(sdata, varargin)
% function thisfeature = feature_filter(sdata, varargin)
%
% Generic filtering routine
% 
% Copyright 2007 Oliver Amft

[Type, Order, Mode, F1, F2, SPS, Lowfrq, Highfrq] = ...
    process_options(varargin, ...
    'type', 'butter', 'order', 4, 'mode', 'bandpass', ...
    'f1', 0, 'f2', 0, ...
    'sps', 44100, 'lowfrq', 25, 'highfrq', 4410);

if (Highfrq > (SPS/2)), Highfrq = SPS/2; end;

% if not configured, determine filter params here
if (F1 == 0) && (F2 == 0)
    F1 = Lowfrq/SPS;
    F2 = Highfrq/SPS;
%     F1 = Lowfrq/SPS/2;
%     F2 = Highfrq/SPS/2;
end;

switch lower(Mode)
    case {'bandpass', 'bp'}
        Wn = [F1 F2];
    case {'lowpass', 'lp'}
        Wn = F1;
    otherwise
        error('Filter mode not supported.');
end;

switch lower(Type)
    case 'butter' % digital Butterworth
        [b, a] = butter(Order, Wn);

    case {'fir', 'fir1'} % window-based FIR implementation
        b = fir1(Order, Wn, window(@hamming, Order+1) );
        a = 1;

    otherwise
        error('Filter type not supported.');
end;

thisfeature = filter(b, a, sdata);
