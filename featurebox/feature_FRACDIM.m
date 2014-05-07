function thisfeature = feature_FRACDIM(rdata)
%function thisfeature = feature_FRACDIM(rdata)
%
% NOTE: The function directly operates on the input data. If rdata is an
% interpolated RR interval time series box sizes refer to the number of
% sample points. If rdata is an unevenly sampled RR interval series box
% sizes refer to the number of consecutive beats.
%
% Implementation based on paper: IYENGAR 1996 "Age-related alterations in
% the fractal scaling of cardiac interbeat interval dynamics"
%
% 2oo9 Martin Kusserow, Wearable Computing Lab, ETH Zurich
% Revision 1.0 20090128 (mk)

% Box sizes (assuming interpolated time series by default)
nmax = 3000;
l = length(rdata);
a = (floor(l/2) < nmax) * floor(l/2) + (floor(l/2) > nmax) * nmax;

boxsize = ceil(10.^(.6:.08:log10(a)));
Fn = zeros(length(boxsize),1);

% Mean of RR intervals
mu = mean(rdata);
% Integrate RR intervals (corrected by RR interval mean)
y = cumsum(rdata - mu);

for n = boxsize
    
    % Devide signal into boxes of equal length 'boxsize' with no overlap
    [yb,rem] = buffer(y, n);
    % Detrend by best linear fit
    yd = detrend(yb);
    % Compute rms of integrated and detrended signal
    Fn(boxsize==n) = sqrt(sum(sum(yd.^2))/length(yb(:)));
%     % Compute the scaling exponent alpha
%     alpha(n) = log10(Fn) / log10(n);
end;

[m R x0 G] = regress2lines(log10(boxsize(:)),log10(Fn));
%alpha = log10(Fn) ./ log10(boxsize(:));

alpha_s = m(1);
alpha_l = m(3);

% Compute the final feature
thisfeature = [alpha_s alpha_l boxsize(x0)];