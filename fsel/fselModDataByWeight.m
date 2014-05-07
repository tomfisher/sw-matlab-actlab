function [maDataTrain maDataTest] = fselModDataByWeight( maDataTrain, maDataTest, veWeight );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) 20070419 Holger Harms, Wearable Computing Lab., ETH Zurich
%
% fselModDataByWeight modifies the Data Matrices and delets every feature
% with a weight of 0.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get vector with zero weights
zw =( veWeight(:) ~= 0 );

% transpose it to delete columns
zw = zw';

% modify train data
maDataTrain = maDataTrain(:,zw);

% modify test data
maDataTest = maDataTest(:,zw);

