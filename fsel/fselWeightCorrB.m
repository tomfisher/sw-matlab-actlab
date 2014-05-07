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
function [veWeight]=fselWeightCorrB(maDataTrain,veHelp,veWeight,veLabelTrain,Corr_Type)

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
%     Determine the Correlation between Features and Classes              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KoMat: contains the idependance od every feature to the calss 

switch Corr_Type,
    case 'Pearson'
    KoMat=sqrt((corr(maDataTrain,veLabelTrain','type','Pearson').*corr(maDataTrain,veLabelTrain','type','Pearson')));
    case'Speraman'
    KoMat=sqrt((corr(maDataTrain,veLabelTrain','type','Spearman').*corr(maDataTrain,veLabelTrain','type','Spearman')));
end
KoMat(veHelp==0)=0;             % bad features wont be evaluated
veWeight=KoMat;



