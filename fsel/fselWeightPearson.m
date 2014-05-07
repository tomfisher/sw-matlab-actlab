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
%Anwendungsorientierte Einf�hrung f�r Ingenieure und Naturwissenschaftler"
%                        Beucher, Ottmar

%
%
%                statistical Filter Method for:
% 
%           continuous, normal distributed Data : Pearson
%           Idea; choose the ones with the lowest correlation
% 
%..........................................................................
function [veWeight]=fselWeightPearson(maDataTrain,veHelp,veWeight)

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
%                 Determine the first two features                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KoMat: Matrice, which contains the correlation between the features
% 
% IndVek: Help Vector for Weithening

IndVek=zeros(1,AnzFeat);

KoMat=sqrt(1-(corr(maDataTrain,'type','Pearson').*corr(maDataTrain,'type','Pearson')));
KoMat(:,veHelp==0)=0;             % bad features wont be evaluated 
KoMat(veHelp==0,:)=0;             % 


[WertA,IndexA] = max(KoMat);      

[WertB,IndexB] = max(max(KoMat)); 

FeatureA=IndexB ;
FeatureB=IndexA(IndexB) ;

IndVek(FeatureA)=1;
IndVek(FeatureB)=1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Evaluate the rest of the features                      %           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ZwMat: Help-Matrice to determine the Independance between teo features
% EvalMat: Help-Matrice to find the best features

veHelpB=ones(1,AnzFeat);
veHelpB(veHelp==0)=0;

for g=3:AnzFeat
    
    veHelpB(IndVek~=0)=0;
    
    ZwMat=(min(KoMat(:,IndVek~=0),[],2))';
    [WertC,IndC]=max(ZwMat.*veHelpB);
    IndVek(IndC)=1/g;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

veWeight=IndVek/max(IndVek);
