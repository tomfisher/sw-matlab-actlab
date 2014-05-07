function thisfeature = feature_fRSA(rdata, fs, varargin)
% [TESTING] Estimation of breathing rate from Respiratory Sinus Arrhythmia (RSA)
%
% Requires:
%  'rdata' - data vector (should be detrended)
%  'fs'    - data vector sampling rate
%
% Based on paper:
%
% "Estimation of Breathing Rate from Respiratory Sinus Arrhythmia"
% by Axel Schaefer and Karl W. Kratky
% Annals of Biomedical Engineering, Vol. 36, No. 3, March 2oo8, pp. 476-485
%
% (c) 2oo8, Martin Kusserow, Wearable Computing Lab, ETH Zurich

% ChangeLog:
% 20090309 - Changed fdesign with 'butter' to F3dB notation

% Set parameters
[method filterorder lowfreq highfreq DEBUG SHOWPLOT peak_thres] = process_options(varargin, ...
    'method', 'counting', ...
    'filterorder', 10, ...
    'lowfreq', .1, ...
    'highfreq', .5, ...
    'debug', false, ...
    'showplot', false, ...
    'peak_thres', .5);
    


%% STEP (2) - Bandpass filter the interpolated RR signal

% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.

% Construct an FDESIGN object and call its BUTTER method.
% (mk) fixed warning of Fc-design in R2008b
%h  = fdesign.bandpass('N,Fc1,Fc2', filterorder, lowfreq, highfreq, fs);
h  = fdesign.bandpass('N,F3dB1,F3dB2', filterorder, lowfreq, highfreq, fs);
Hd = design(h, 'butter');

% % Show filter
% fvtool(Hd);

% % THIS SOMEHOW DOESN'T REALLY WORK ANYMORE!!!
% % Construct Butterworth band-pass 0.1-0.5 Hz
% data = feature_filter(signal, 'type', 'butter', 'order', filterorder, 'mode', 'bp', ...
%     'sps', sps, 'lowfrq', lowfreq, 'highfrq', highfreq);

% Execute the filter and compute RSA respiration signal
data = filter(Hd, rdata);


%% STEP (3) - Determine maxima and minima

% First determine mean and standard deviation to get the params for the
% hillcliming algorthm

% How fast can breathing change? ~5sec? Take it as window! No overlap!

mu = mean(data);
sigma = std(data);
[peakpos, peakmag] = hillClimbing(data, sigma * peak_thres, sigma * peak_thres);
[valleypos, valleymag] = hillClimbing(-data, sigma * peak_thres, sigma * peak_thres);

% Detect zero crossings (offset error?)
zcrpos = find(((data(1:end-1) .* data(2:end)) < 0));

% Plot result
if SHOWPLOT
    figure;
    plot(data); hold on;
    plot(peakpos, peakmag, 'ro');
    plot(valleypos, -valleymag, 'g*');
    plot(zcrpos, data(zcrpos), 'k+');
end;




%% STEP (4) - Calculate vertical differences of subsequent local extrema

% Create matrix of local extrema and flag type
extrema = [ ...
    peakpos(:) ones(length(peakpos), 1); ...
    valleypos(:) zeros(length(valleypos), 1)];

% Order extrema by their position, i.e. column 1
extrema = sortrows(extrema, 1);

% Check for subsequent extrema of the same type
selector = diff(extrema(:,2)) == 0;
candidates = extrema(selector, :);

% % Plot the situation for manual inspection
% plot(candidates(:,1), data(candidates(:,1)), 'm*');

% What is the error ratio?
error_ratio = size(candidates,1)/size(extrema,1) * 100;

% How many doubles do we have?
if DEBUG
    fprintf('\nDetected %d invalid local extrema points (%.2f%%).', ...
        size(candidates,1), error_ratio);
end;

% Handle invalid extrema pairs

% Deletion since we count on subsequent median filter to take care of this
if error_ratio < 5
    extrema(selector,:) = [];
end;
% Something else 
...

% Do we addionally have to check the number of zero crossings?
...
    
% Calculate vertical differences of subsequent local extrema
selector = extrema(:,1);
dmag_extrema = abs(diff(data(selector)));
Q3 = quantile(dmag_extrema, .75);
% Originally .2 * Q3 -> test this
threshold = .1 * Q3;





%% STEP (5) - Find invalid extrema pairs

cnt = 0;

% Threshold the local extrema pairs
while (min(dmag_extrema) <= threshold)
    
    % Delete extrema pair below threshold
    [val pos] = min(dmag_extrema);
    extrema(pos:pos+1,:) = [];
    
    % Update extrema after deletion
    selector = extrema(:,1);
    dmag_extrema = abs(diff(data(selector)));   
    
    cnt = cnt + 1;
end;

cnt_ratio = cnt/size(dmag_extrema,1) * 100;

if DEBUG
    fprintf('\nDeleted %d invalid local extrema pairs (%.2f%%).', ...
        cnt, cnt_ratio);
end;



%% STEP (6) - Compute average breathing rate

% Respiratory cycle is the time between adjacent NN minima points
selector = extrema(extrema(:,2) == 0, 1);
thisfeature = [mean(1.0 ./ (diff(selector) / fs)) error_ratio cnt_ratio];





% End of file
