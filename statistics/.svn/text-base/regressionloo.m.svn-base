function [LOORegEstimate LOORegError LOORegParams R2 F p] = regressionloo(Y, Features, varargin)
% function [LOORegEstimate LOORegError LOORegParams R2 F p] = regressionloo(Y, Features, varargin)
%
% Leave-one-out multiple linear regression analysis using least-squares
% 
% Parameters:
%   Y - Variable to estimate 
%   Features - Independent variables in columns, one row per element in Y 
% 
% Options:
%   ModelOrder - Determine model order (degree), values: 1; 0 
%   DoNorm - Centering and scaling (standardise), default: true
%
% Return:
%   LOORegEstimate - Predicted values (Yhat) for each data point in Y
%   LOORegError - Residuals for each prediction (LOORegEstimate-Y)
%   LOORegParams -  Coefficient values for all columns of Features
% 
% Solves X = F\Y, whether it has or has no solution. If it has no solution,
% the least squares solution is returned (mldivide). 
% (X=LOORegParams, F=Features, Y=LOORegEstimate)
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
% See also: regressionstats.m, mregestimate.m

% Copyright 2008 Oliver Amft

[ModelOrder DoNorm DoCV verbose] = process_options(varargin, ...
	'ModelOrder', 1, 'DoNorm', true, 'DoCV', true, 'verbose', 1);

[nobs nfeatures] = size(Features);
if length(Y)~=nobs, error('Dimensions of Y and Features do not match.'); end;

LOORegParams = zeros(nobs, nfeatures+1);
LOORegEstimate = zeros(nobs, 1);
LOORegError = zeros(nobs, 1);  
for cvi = 1:nobs
	YTrain = col(Y);  XTrain = Features;
	if (DoCV)
		YTrain(cvi) = [];  XTrain(cvi,:) = [];  % omit the test sample
		XTest =  Features(cvi,:);
	else
		XTest =  Features;
	end;
		
	% centering and scaling
	if (DoNorm)
		[XTrain fmeans fstds] = mstandardise(XTrain); 
		XTest = mstandardise(XTest, fmeans, fstds);
	end;
	
	
	if (DoCV)
		if (ModelOrder==0)
			LOORegEstimate(cvi) = mean(YTrain);
			LOORegError(cvi) = Y(cvi) - LOORegEstimate(cvi);
		else
			LOORegParams(cvi,:) = [ones(size(XTrain,1), 1) XTrain] \ YTrain;  % coefficients
			LOORegEstimate(cvi) = [ones(size(XTest,1),1) XTest] * LOORegParams(cvi,:)';  % prediction
			LOORegError(cvi) = Y(cvi) - LOORegEstimate(cvi);  % residuals
		end;
	else  % no CV
		if (ModelOrder==0)
			LOORegEstimate = mean(YTrain);
			LOORegError = Y - LOORegEstimate(cvi);			
		else
			LOORegParams = row([ones(size(XTrain,1), 1) XTrain] \ YTrain);  % coefficients
			LOORegEstimate = [ones(size(XTest,1),1) XTest] * LOORegParams';  % prediction
			LOORegError = Y - LOORegEstimate;  % residuals
		end;
		break;
	end;
end; % for cvi

if (ModelOrder>0),  [R2 F p] = regressionstats(LOORegEstimate, Y, LOORegParams); end;

if (verbose)
	if (DoCV==false), fprintf('\n%s: ===> DoCV=false', mfilename); end;
	if (ModelOrder==0)
		fprintf('\n%s: total abs error:%.3f,  mean rel error: %.2f%%', mfilename, ...
			sum(abs(LOORegError)), mean(col(abs(LOORegError)) ./ col(Y)) *100);
	else
		fprintf('\n%s: total abs error:%.3f,  mean rel error: %.2f%%, R2: %.2f, F: %.1f, p: %.3f', mfilename, ...
			sum(abs(LOORegError)), mean(col(abs(LOORegError)) ./ col(Y)) *100, R2, F, p);
	end;
end;