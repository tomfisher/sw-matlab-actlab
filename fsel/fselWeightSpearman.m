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
%           continuous, not normal distributed Data : Pearson
%           Idea; choose the ones with the lowest correlation
% 
%..........................................................................
function [maDataTrain,veWeight]=fselWeightSpearman(maDataTrain,veHelp,veWeight)


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
%                         Ranking the Data                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%maDataRanked = Ranked Data


maDataRanked = tiedrank(maDataTrain);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Determine the number of samples and features                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AnzFeat: number of features
% AnzSmp : Anumber of classes

[AnzSmp,AnzFeat]=size(maDataRanked);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Determine the first two features                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IndVek: Help-Vector for Weightening
% rhoMat,KoMat: Helpmatrices to evaluate Spearman-corr.

IndVek=zeros(1,AnzFeat);

rhoMat = corr(maDataRanked, 'type','Spearman');

KoMat=sqrt(1-(rhoMat.*rhoMat));
KoMat(:,veHelp==0)=0;             % Bad features wont be evaluated
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

veHelpB=ones(1,AnzFeat);
veHelpB(veHelp==0)=0;

for g=3:AnzFeat
    
    veHelpB(IndVek~=0)=0;
    ZwMat=(min(KoMat(:,IndVek~=0),[],2))';
    [WertC,IndC]=max(ZwMat.*veHelpB);
    IndVek(IndC)=1/g;

end

veWeight=IndVek/max(IndVek);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     alternativ methode                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       fromhttp://www.mathworks.com/matlabcentral/fileexchange/
%..........................................................................
% 
%  rr=zeros(AnzFeat,1);
%  tt=zeros(AnzFeat,1);
%  pp=zeros(AnzFeat,1);
% for g=3:AnzFeat
%     for f=1:AnzFeat
%         
%         [r,t,p]=spear(maDataRanked(:,f), maDataRanked( : ,IndVek ~= 0));
%         rr(f)=max(r.*r);
%     end
%     [WertC,IndC]=min(rr(IndVek==0));
%     IndVek(IndC)=g;
% end
% 
% veWeight=1-IndVek/max(IndVek);


