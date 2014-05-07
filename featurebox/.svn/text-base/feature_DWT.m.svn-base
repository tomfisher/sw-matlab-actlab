function thisfeature = feature_DWT(rdata, N, varargin)
%[EXPERIMENTAL] function thisfeature = feature_DWT(rdata, N, varargin)
%
% N - decomposition levels

% Changelog:
% 2009/02/13: N is now determined by default by the signal length (mk)

% Process variable input arguments
[fname wname] = process_options(varargin, 'fname', 'energy', 'wname', 'db1');

% Check maximum level decomposition
Nmax = wmaxlev(length(rdata), wname);

% Determine decomposition level
if isempty(N)
    N = 1:Nmax;
else
    % if min(N) > Nmax, N = ; end;
    if  Nmax < max(N), N = min(N):Nmax; end;
end;

% Multi-level discrete wavelet decomposition
[c l] = wavedec(rdata, max(N), wname);

% Extract detail coefficients
Cd = detcoef(c, l, N, 'cells');
    

switch (lower(fname))
    
    % rms = norm(x) / sqrt(length(x)) = sqrt(sum(x.^2) / length(x))
    case { 'rms' }        
        % rms of approximation coefs
        Ra = sqrt(sum(c(1:l(1)).^2) ./ length(l(1)));
        % Euclidean distance
        Cdnorm = cellfun(@norm, Cd);
        % rms of detail coefs
        Rd = Cdnorm ./ sqrt(cellfun(@length, Cd));
        thisfeature = [Ra Rd];
        
        
    % Energy of 1-D wavelet decomposition (c.f. MATLAB 'wenergy')
    %  Returns Ea, which is the percentage of energy corresponding to
    %  the approximation and Ed, which is the vector containing
    %  the percentages of energy corresponding to the details. 
    case { 'energy' }
        E = sum(c.^2);
        Ea = sum(c(1:l(1)).^2);
        % Euclidean distance
        Cdnorm = cellfun(@norm, Cd);
        Ed = Cdnorm.^2;
        thisfeature = [E Ea Ed];
    
        
    % Std deviation of 1-D wavelet decomposition
    case { 'std' }
        thisfeature = cellfun(@std, Cd);
            
        
    % Std deviation of 1-D wavelet decomposition (c.f. MATLAB 'wnoisest')
    %  Returns estimates of the detail coefficients' standard deviation 
    %  for levels contained in the input vector S. The estimator used 
    %  is Median Absolute Deviation / 0.6745, well suited for zero 
    %  mean Gaussian white noise in the de-noising 1-D model.
    case { 'stdgwn' }
        Cdmag = cellfun(@abs, Cd, 'UniformOutput', 0);
        thisfeature = cellfun(@median, Cdmag)/0.6745;                

        
    otherwise;        
        % Error message
        ...
end;