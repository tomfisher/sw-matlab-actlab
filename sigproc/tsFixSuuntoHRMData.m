function [Tinterp RRinterp Xinterp seqNoInterp] = tsFixSuuntoHRMData(RR, X, Ts, seqNoX, nSeqNo, fs, varargin)
%function [Tinterp RRinterp Xinterp seqNoInterp] = tsFixSuuntoHRMData(RR, X, Ts, seqNoX, nSeqNo, fs, varargin)
%
% Requires:
%   Ts          - time vector [s]
%   seqNo       - sequence numbers
%   nSeqNo    - number of sequence numbers

% ChangeLog:
% (mk) 20090716
% + Improved overrun detection
% + Hybrid interpolation with threshold: Below 5s spline, above
%   5s pchip (linear) to preserve monotony and avoid overshoots of
%   spline, below cubic spline
% + Bugfix by adding proper ms scaling of Tn (mk)
% + Added 'verbose' varargin to output data padding stats

[verbose, minLinInterpGapSize] = process_options(varargin, 'verbose', false, 'minLinInterpGapSize', 5);

% Compute sequence number differences in terms of pakets
dSeqNo = mod(diff(seqNoX), nSeqNo);

% Redundant samples share the same sequence number
selector = dSeqNo > 0;
% Discard redundant samples
dSeqNo = dSeqNo(selector);
X = X(logical([1; selector(:)]), :);
Ts = Ts(logical([1; selector(:)]));
RR = RR(logical([1; selector(:)]));

% Time differences of pakets
dTs = diff(Ts);
% Time after which timer overrun occurs
maxSeqTs = 2^16 / 1000;

% We might be out by 1 with the initial N, so find N that minimises the
% error Err
N = floor(dTs / maxSeqTs);
selector = find(N);
for i = selector(:)'
    thisN = [ N(i)-1 N(i) N(i)+1 ];
    Err = abs(dTs(i) - (thisN * maxSeqTs + (RR(i+1) / 1000))  );
    [val pos] = min(Err);
    N(i) = thisN(pos);
end;

% Offset due to overrun (dTs > 65536ms)
N = cumsum(N * maxSeqTs); % Consider N missing periods
Tn = [0; N(:)] * 1000; % Convert to ms

% Time vector of RR intervals, start at 0s
Trr = (cumsum(RR) + Tn - RR(1)) / 1000;

% Thresholding of values
threshold = .8;
[Tfilt X] = glitchFilter(Trr, [RR X], threshold);

% Time vector of interpolation data
Tinterp = (0:1/fs:Tfilt(end))';

% Data interpolation 'spline'
Xinterp_spline = interp1(Tfilt, X, Tinterp(:), 'spline');
Tinterp_spline = Tinterp;

% Delete spline interpolation gaps larger than 5s and interpolate again by
% linear/pchip interpolation
selector = find(diff(Tfilt) > minLinInterpGapSize);
for i = selector(:)'
    T = quant([Tfilt(i) Tfilt(i+1)], 1/fs);
    Z = double(ismember(Tinterp_spline(:), T));
    % MK REVISIT: Analyse this ..
    if sum(Z) ~= 2, 
        fprintf('\n\tMK REVISIT: Not a valid interval!');
        continue;
    end;
    interval = find(Z,1,'first'):find(Z,1,'last');
    Xinterp_spline(interval,:) = [];
    Tinterp_spline(interval) = [];
end;
% Depending on the monotony, computing resources .. could also be linear
Xinterp = interp1(Tinterp_spline, Xinterp_spline, Tinterp(:), 'pchip');
%Xinterp = interp1(Tinterp_spline, Xinterp_spline, Tinterp(:), 'linear');

% Select relevant data channels
RRinterp = Xinterp(:,1);
Xinterp = Xinterp(:,2:end);

% Data statistics
debit = sum(dSeqNo) + 1;
actual = length(Trr);
missing = debit - actual;
dSeqNo = dSeqNo - 1;

% MK REVISIT
if verbose
    fprintf('\n\tMessage stats (data):\tDebit: %10d (100.00%%),\tActual: %10d (%6.2f%%),\tMissing: %10d (%6.2f%%)', ...
        debit, actual, actual/debit*100, missing, missing/debit*100);
    % Burst if more than 20 beats got lost
    fprintf('\n\tError stats         :\tBurst: %10d (%6.2f%%),\tSingle: %10d (%6.2f%%)', ...
        sum(dSeqNo(dSeqNo > 20)), sum(dSeqNo(dSeqNo > 20))/(missing+eps) * 100, sum(dSeqNo(dSeqNo < 21)), sum(dSeqNo((dSeqNo < 21)))/(missing+eps) * 100);
end;



% Sequence number vector of interpolated data
%seqNoInterp = mod(1:size(RRinterp,1), nSeqNo)'; % this is correct
% Abuse seqNoInterp for data loss count of activities
% Find nearest integer of T (approximation!)
Trr(1) = [];
T = quant(Trr(:), 1/fs);
T(end) = Tinterp(end);
Z = double(ismember(Tinterp(:), T));
n = sum(Z);
Z(Z==1) = dSeqNo(1:n);
seqNoInterp = Z;


% End of file