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
%       "Wahrscheinlichkeitsrechnung und Statistik mit MATLAB
%Anwendungsorientierte Einführung für Ingenieure und Naturwissenschaftler"
%                        Beucher, Ottmar
%
%
%                statistical Selection Methode for:
% 
%             kontinuous, normal distributed Data : 
% 
%          
%..........................................................................



function[veWeight]=fselSortPearson(maDataTrain,veWeight,Beta,N,veHelp)

%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Determine the number of features, samples, etc.                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AnzFeat: Number of features
% AnzSmp : Number of samples

[AnzSmp,AnzFeat]=size(maDataTrain);



  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Evaluation of the first feature                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

IndVek=zeros(1,AnzFeat);

[WertA, IndA]=max(veWeight.*veHelp);
IndVek(IndA)=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Weightening of the rest  of the features                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ZwMat=corr(maDataTrain,'type','Pearson');
ZwMat(veHelp==0,:)=0;
ZwMat(:,veHelp==0)=0;
EvalMat=sqrt(1-(ZwMat.*ZwMat));

for g=2:N
    
    EvalMatB=(min((EvalMat(:,IndVek~=0)),[],2))';
    EvalMatB=(veHelp.*veWeight)+Beta*(EvalMatB.*veHelp);
    EvalMatB(IndVek~=0)=0;
    [WertC,IndC]=max(EvalMatB);
    IndVek(IndC)=1/g;
    

end

veWeight=IndVek/max(IndVek);


