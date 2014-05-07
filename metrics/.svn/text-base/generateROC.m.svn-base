function [fpr, tpr, AUC] = generateROC(score, classlabel)
% [fpr, tpr, AUC] = generateROC(score, classlabel);
%   Returns the 'false positive rate' and 'true positive rate'
%       of a scoring classifier.
%   Returns 'Area under the ROC curve, AUC'
%   If no output argument is given, the ROC curve is plotted.
%
%   INPUT
%       score is the probability of an instance belonging to the positive class [dim = 1xN]
%       classlabel is the ground truth (1 = positive class, 0 = negative class) [dim = 1xN]
%
%   The algorithm is taken from Tom Fawcett; "ROC Graphes: Notes
%   and Practical Considerations for Researchers", March 2004, page 13 + 16
% 
% Copyright 2005 Mathias Staeger, Oliver Amft, Wearable Computing Lab, ETH Zurich

if ( ~(isvector(score) & isvector(classlabel) & (length(score) == length(classlabel))) )
    error('wrong input format');
end

if ( (max(classlabel)>1) | (min(classlabel)<0) )
    error('wrong classlabel: 1 = positive class, 0 = negative class');
end

% correct dimension [1xN] so that fliplr works
if (size(score,2) == 1)
    score = score.';
end
if (size(classlabel,2) == 1)
    classlabel = classlabel.';
end

%%% sort input in descening order
[scoreSorted, ind] = sort(score);
scoreSorted = fliplr(scoreSorted);
classlabelSorted = fliplr(classlabel(ind));

N = length(classlabel(find(classlabel==0)));   % number of Negatives
P = length(classlabel(find(classlabel==1)));   % number of Positives
FP = 0;
TP = 0;
R = [];
AUC = 0;
fprev = 2;  % actually +infinity, since max(score) = 1 this is enough

for i = 1:length(scoreSorted)
    if (scoreSorted(i) ~= fprev)
        R = [R; FP, TP];
        fprev = scoreSorted(i);
        if (size(R,1)>=2)
            AUC = AUC + trapezoidArea(R(end,1),R(end-1,1), R(end,2),R(end-1,2));
        end
    end
    if (classlabelSorted(i) == 1)       %% if it is a positive example
        TP = TP+1;
    else
        FP = FP+1;
    end
end
R = [R; FP, TP];
AUC = AUC + trapezoidArea(R(end,1),R(end-1,1), R(end,2),R(end-1,2));
AUC = AUC/(P*N);                        %% scale from PxN onto the unit square

fpr = R(:,1)./N;
tpr = R(:,2)./P;

if (nargout == 0)
    figure
    plot(fpr,tpr, 'LineWidth', 3);
    grid on; axis square;
    xlabel('False positive rate'); ylabel('True positive rate');
    text(0.4, 0.15, sprintf('AUC = %0.5g', AUC), 'FontSize', 12, 'FontWeight', 'Bold')
end


% ------------------------
function ar = trapezoidArea(x1, x2, y1, y2);
    %% height = x2-x1
    %% base   = y1 and y2
    ar = abs(x2-x1) * (y1+y2)/2;
