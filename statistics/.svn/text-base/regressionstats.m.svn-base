function [R2 F p] = regressionstats(Yhat, Y, RegParams)
% function [R2 F p] = regressionstats(Yhat, Y, RegParams)
% 
% Compute frequent regression analysis statistics. RegParams must be a row
% vector. 
%
% alternative: regress (Statistics Toolbox)

% Copyright 2008 Oliver Amft

Y = col(Y);  Yhat = col(Yhat);
nobs = length(Y);

% based on http://mathworld.wolfram.com/LeastSquaresFitting.html
RegError = Y - Yhat;  % residuals

% OAM REVISIT: How to determine resdeg? Here is a hack!
% % resdeg = nobs - nfeatures;  if (resdeg<0), resdeg = 0; end;  % residuals degrees of freedom
% this is needed to work with regressionloo.m that provides a matrix of params, one row per CV 
resdeg = mean(sum(RegParams~=0,2));  % coefs in the model, deduct intercept?

% % normres = norm(RegError);
% % rmserr = normres ./ sqrt(resdeg);  % RMS error
% rmserr = sqrt( sum(RegError.^2) / nobs-2 );  % alternate RMS error

SSE = sum(RegError.^2);  %  sum of squares error
SSR = sum( (Yhat - mean(Y)).^2 );  %  sum of squares residuals
SST = sum( (Y - mean(Y)).^2 );  %  sum of squares total

R2 = SSR / (SSE + SSR) ;  % R2 statistic, see http://mathworld.wolfram.com/CorrelationCoefficient.html
% R2 = 1- (SSE / SST); % alternate, doesn't work here, why??  
% For general rule of thumb, the R-squared or adjusted R-squared should be
% higher than 0.80 to produce a good linear model.  If your R-squared is
% less than 0.5, it is recommended that you consider another type of model
% rather than a linear model.   

% http://people.revoledu.com/kardi/tutorial/Regression/GoodnessOfFit.html
MSE = SSE / (nobs-resdeg); % mean squared error
MST = SST / (nobs-1); % mean squared total error
MSR = SSR / (resdeg-1);  % mean squared regression

s2 = MSE; % estimate of error variance
F = MSR / s2;  % F statistic
% Comparision of two models: Regression fit and assumption of mean.

p = 1 - fcdf(F, resdeg-1, nobs-resdeg); % significance probability for regression
