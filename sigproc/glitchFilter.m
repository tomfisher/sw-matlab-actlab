function [Tz Z] = glitchFilter(Tx, X, a, colIdx)
%function [TZ Z] = GLITCHFILTER(X, A)
% 
% *PRELIMINARY*
%
% Simple spike filter for RR data based on poincare plot
%       f(x_{n}) = x_{n+1}, ...
%
% Thus, the parameter A of the linear function y = A*x describes a
% symmetrical threshold to quantify the difference of subsequent values
% with respect to the magnitude.
%
% PARAMETERS:
%   X - time series to filter
%   A - slope describing a symmetric linear threshold function
%       y < a * x and y > 1/a * x
%
% (c) 2oo8 Martin Kusserow, Wearable Computing Lab, ETH Zurich

% ToDo: Do not threshold if past one is above certain time limit.

% Assign default conditionif not otherwise stated
if ~exist('colIdx', 'var'), colIdx = 1; end;

% Plausibility threshold, y = ax
th = abs(log(a));

% Copy over to result vector
Z = X;
Tz = Tx;
faulty = true;
medianSize = 15;
goodList = [];
% figure, plot(Tz, Z(:,colIdx), '-xb'); hold on;

% Delete zero values (mk bugfix, 20081128)
p = Z(:,colIdx) == 0;
Z(p, :) = [];
Tz(p,:) = [];

% How about handling the 5000ms measures? (mk,20081128)
...

while faulty
    
    % zero value handling removed from here (mk,20081128)
    ...
    
    % Compute decision criteria
    dRR = abs(log(Z(2:end, colIdx)) - log(Z(1:end-1, colIdx)));

    % Determine outliers by thresholding
	candidates = find(dRR > th) + 1;
    
    % Values not in the intersection
    candidates = setxor(goodList, candidates);
    
    % Determine next to process or end
    if ~isempty(candidates), faulty = candidates(1);
    else faulty = false; continue; end;
    
    
    % Fuse those that are lower until we get one that is equal
    ...
    
    %  Median filter check
    interval = faulty-(medianSize-1)/2:faulty+(medianSize-1)/2;
    if min(interval) < 1, interval = 1:medianSize;
    elseif max(interval) > size(Z,1), interval = size(Z,1)-medianSize:size(Z,1);
    end;
    if  abs(log(Z(faulty,colIdx)) - log(median(Z(interval,colIdx)))) > th
        
%         plot(Tz(faulty),Z(faulty,colIdx),'or');
        
        % Delete outlier        
        Z(faulty,:) = [];
        Tz(faulty,:) = [];
    else
        % Skip this one
%         plot(Tz(faulty),Z(faulty,colIdx),'og');
                
        goodList = [goodList; faulty];
        continue;
    end;
end;

% End of file