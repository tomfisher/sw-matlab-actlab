function [Ty Y seqNoY] = tsFixData(X, Ts, seqNoX, nSeqNo, fs, varargin)
%function [Ty Y seqNoY] = tsFixData(X, Ts, seqNoX, nSeqNo, fs, varargin)
%
% Requires:
%   Ts          - time vector [s]
%   seqNoX       - sequence numbers
%   nSeqNo    - max. sequence number

% ChangeLog:
% (mk) 20090716 : Added 'verbose' varargin to output data padding stats


[verbose] = process_options(varargin, 'verbose', false);

% Compute sequence number differences in terms of pakets
dSeqNo = mod(diff(seqNoX), nSeqNo);

% Discard redundant samples, i.e. same sequence number
%selector = (dSeqNo > 0) | ((diff(Ts) > nSeqNo/fs/2) & (dSeqNo == 0));
selector = dSeqNo > 0;


dSeqNo = dSeqNo(selector);
X = X(logical([1; selector(:)]), :);
Ts = Ts(logical([1; selector(:)]));

% Detect overruns
dTs = diff(Ts);
N = floor(dTs * fs/nSeqNo) * nSeqNo;

% Calculate data time vector [s]
dSeqNo = N(:) + dSeqNo(:);
T = [0; 1/fs * cumsum(dSeqNo(:))];

% Time vector of interpolated data
Ty = (0:1/fs:T(end))';
% Interpolation
Y = interp1q(T, X, Ty(:));

% % Sequence number vector of interpolated data
% seqNoY = mod(1:size(Y,1), nSeqNo)';

% Data statistics
debit = length(Ty);
actual = length(T);
missing = debit - actual;
dSeqNo = dSeqNo - 1;

% MK REVISIT
if verbose
    fprintf('\n\tMessage stats (data):\tDebit: %10d (100.00%%),\tActual: %10d (%6.2f%%),\tMissing: %10d (%6.2f%%)', ...
        debit, actual, actual/debit*100, missing, missing/debit*100);
    
    fprintf('\n\tError stats         :\tBurst: %10d (%6.2f%%),\tSingle: %10d (%6.2f%%)', ...
        sum(dSeqNo(dSeqNo > 255)), sum(dSeqNo(dSeqNo > 255))/(missing+eps) * 100, sum(dSeqNo(dSeqNo < 256)), sum(dSeqNo((dSeqNo < 256)))/(missing+eps) * 100);
end;

% Make sure to have the same precision (should be anyway like that!)
T = quant(T, 1/fs);
Ty = quant(Ty, 1/fs);

% Abuse of seqNoY for packet error counter
Z = double(ismember(Ty,T));
Z(Z == 1) = [dSeqNo(:); 0];
seqNoY = Z(:);

% % MK REVISIT: Does this work?
% if verbose
%     nBins = max(dSeqNo);
%     H = hist(dSeqNo(dSeqNo > 1), nBins);
%     fprintf('\tDistribution of missing\t: %d (%3.2f%%),\t %d (%3.2f%%),\t: %d (%3.2f%%),  \n', ...
%         debit, actual, actual/debit*100, missing, missing/debit*100);
% end;


% End of file