function [mFeatures veLabelTrain] = fselPreCreateDummyFeatures(NFeatures, NObs, veLabelTrain)
% function mFeatures = fselPreCreateDummyFeatures(NFeatures, NObs, veLabelTrain)
% 
% Create a dummy feature matrix for evaluation purposes. When called
% without veLabelTrain, creates a description (one class) data set,
% including NULL. Last "feature" is veLabelTrain.
%
% veLabelTrain - Vector containg class ids
% mFeatures - [ 1 0 r*1e6 r ... r L ] ;  (r = rand, L = veLabelTrain)

% Copyright 2007 Oliver Amft, ETH Zurich

if (~exist('NObs', 'var')) || isempty(NObs), NObs = 20; end;
if (~exist('NFeatures', 'var')) || isempty(NFeatures), NFeatures = 10; end;
if NFeatures<5, error('Less than 5 features not supported.'); end;

if (~exist('veLabelTrain', 'var')) || isempty(veLabelTrain), veLabelTrain = [ ones(NObs/2,1); zeros(NObs/2,1) ]; end;

mFeatures = [ ones(NObs, 1) zeros(NObs, 1) rand(NObs,1)*1e6 rand(NObs,NFeatures-4) veLabelTrain ];
