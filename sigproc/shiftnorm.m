function [dout dshift dnorm] = shiftnorm(din, dshift, dnorm)
% function [dout dshift dnorm] = shiftnorm(din, dshift, dnorm)
%
% din for multi-value features (columns):
%   [feature1t0, feature2t0, ...
%    feature1t1, feature2t1, ...
%    ...]
%
dout = [];

for col = 1:size(din, 2)
    if (nargin == 1) % no shift, norm supplied
        dmin = min(din(:,col));
        dshift(col) = (abs(dmin) * (dmin<0));
    end;
    
    dtmp = din(:,col) + dshift(col);

    if (nargin == 1) % no shift, norm supplied
        dnorm(col) = max(dtmp); % sum
    end;
    
    if (round(dnorm(col)) == 0)
        fprintf('\n%s: Norm is zero in column %u.', mfilename, col);
        dout(:,col) = dtmp;
%         dout(:,col) = dtmp * (dtmp < 1);
    else
        dout(:,col) = dtmp / dnorm(col);
    end;
end;
