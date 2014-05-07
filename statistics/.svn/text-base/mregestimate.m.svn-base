function [RegEstimate RegError RegParams R2 F p] = mregestimate(XTrain, YTrain, XTest, YTest, varargin)
% function [RegEstimate RegError RegParams R2 F p] = mregestimate(XTrain, YTrain, XTest, YTest, varargin)
% 
% Parameters:
%   Y* - Variable to estimate 
%   X* - Independent variables in columns, one row per element in *Targets
% 
% Options:
%   ModelOrder - Determine model order (degree), values: 1; 0 
%   DoNorm - Centering and scaling (standardise), default: true
%
% Return:
%   RegEstimate - Predicted values (Yhat) for each data point in Y
%   RegError - Residuals for each prediction (RegEstimate-Y)
%   RegParams -  Coefficient values for all columns of Features
% 
% Solves X = F\Y, whether it has or has no solution. If it has no solution,
% the least squares solution is returned (mldivide). 
% (X=RegParams, F=Features, Y=RegEstimate)
% 
% from Matlab help on mldivide:
% Uses mldivide least-squares fit to solve the system of equations FX = Y.
% In other words, X minimizes norm(F*X - Y), the length of the vector FX -
% Y. The rank k of F is determined from the QR decomposition with column
% pivoting. The computed solution X has at most k nonzero elements per
% column. If k < n, this is usually not the same solution as x = pinv(F)*Y,
% which returns a least squares solution. 
% 
% alternative: regress (Statistics Toolbox)
% least squares solution with the smallest norm: pinv(F)*Y
% 
% See also: regressionstats.m, regressionloo.m
%
% Copyright 2008 Oliver Amft

[ModelOrder DoNorm verbose] = process_options(varargin, ...
	'ModelOrder', 1, 'DoNorm', true, 'verbose', 1);

[nobs nfeatures] = size(XTrain);
if length(YTrain)~=nobs, error('Dimensions of Y and Features do not match.'); end;

RegParams = zeros(1, nfeatures+1);
% RegEstimate = zeros(nobs, 1);
% RegError = zeros(nobs, 1);  

% centering and scaling
if (DoNorm)
	[XTrain fmeans fstds] = mstandardise(XTrain);
	XTest = mstandardise(XTest, fmeans, fstds);
end;

if (ModelOrder==0)
	RegEstimate = repmat(mean(YTrain), size(YTest,1), 1);
	RegError = YTest - RegEstimate;
else
	RegParams = row([ones(size(XTrain,1), 1) XTrain] \ YTrain);  % coefficients
	RegEstimate = [ones(size(XTest,1),1) XTest] * RegParams';  % prediction
	RegError = YTest - RegEstimate;  % residuals
end;

if (ModelOrder>0),  [R2 F p] = regressionstats(RegEstimate, YTest, RegParams); end;

if (verbose)
	if (ModelOrder==0)
		fprintf('\n%s: total abs error:%.3f,  mean rel error: %.2f%%', mfilename, ...
			sum(abs(RegError)), mean(col(abs(RegError)) ./ col(YTest)) *100);
	else
		fprintf('\n%s: total abs error:%.3f,  mean rel error: %.2f%%, R2: %.2f, F: %.1f, p: %.3f', mfilename, ...
			sum(abs(RegError)), mean(col(abs(RegError)) ./ col(YTest)) *100, R2, F, p);
	end;
end;
