% 
% 
% 
%                       Semesterthesis SS 07 
%               Feature Selection for body-worn sensors
%
%                          Daniel Christen
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%
%                            Quellen: 
%"A Signigicance Test Based Feature Selection Method for the Detection 
%           of Prostata Cancer from Proteomic Patterns", 
%            Qianren Xu Waterloo, Ontario,Canada, 2004
% 
%   http://en.wikipedia.org/wiki/Pearson_correlation_coefficient

%       "Wahrscheinlichkeitsrechnung und Statistik mit MATLAB
%Anwendungsorientierte Einführung für Ingenieure und Naturwissenschaftler"
%                        Beucher, Ottmar

%
%
%                statistical Filter Method for:
% 
%           continuous, normal distributed Data : Pearson
%           Idea; choose the ones with the lowest correlation
% 
%..........................................................................
function [maDataTrain,veWeight]=fselWeightPearsonB(maDataTrain,veHelp,veWeight,veLabelTrain)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Load of the Data (just for purpose of test)                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% load bm_marc_st1.mat 

% maDataTest: Test Data
% maDataTrain:Train Data
% veLabelTest: Testlabelvector
% veLabelTrain: Trainlabelvector
% veRank: Rank vector

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Determine the number of Features, Samples, Classes, Samples per class  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AnzFeat: Number of features
% AnzSmp : Number of samples
% AnzKl  : Number of classes
% SmpKl  : Number of samples per class

[AnzSmp, AnzFeat]=size(maDataTrain);

maDataTrainA=maDataTrain;

maDataTrainA(:,veWeight==0)=0;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Determine the Correlation between Features and Classes              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KoMat: Matrice, which contains the correlation between the features
% 
% IndVek: Help Vector for Weithening

IndVek=zeros(1,AnzFeat);

KoMat=sqrt(1-(corr(maDataTrain,veLabelTrain,'type','Pearson').*corr(maDataTrain,veLabelTrain,'type','Pearson')));
KoMat(veHelp==0)=0;             % bad features wont be evaluated 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Evaluate the rest of the features                      %           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

