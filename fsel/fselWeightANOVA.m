function veWeight = fselWeightANOVA(maDataTrain,veLabelTrain)
% function veWeight = fselWeightANOVA(maDataTrain,veLabelTrain)
% 
% ANOVA (analysis of variance) for continuous, normal-distributed data.
%
% Copyright 2007 Oliver Amft, ETH Zurich
% Derived from a Semesterthesis SS 07 by Daniel Christen (Feature Selection for body-worn sensors)
% This version is bugfixed, optimised for speed and memory footprint.
%
%                            Sources: 
%"A Signigicance Test Based Feature Selection Method for the Detection 
%           of Prostata Cancer from Proteomic Patterns", 
%            Qianren Xu Waterloo, Ontario,Canada, 2004

%       "Wahrscheinlichkeitsrechnung und Statistik mit MATLAB
%Anwendungsorientierte Einfuehrung fuer Ingenieure und Naturwissenschaftler"
%                        Beucher, Ottmar


%%  Determine the number of Features, Samples, Classes, Samples per class
[NObs, NFeatures] = size(maDataTrain);

Classes = unique(veLabelTrain);
NClasses = length(Classes); 

NClassObs = zeros(1, NClasses);
for c = 1:NClasses
   NClassObs(c) = sum(veLabelTrain == Classes(c));
end;


%%                     Determine the means

% MeanTotal: Mean over all semples of a feature
MeanTotal = mean(maDataTrain);

% MeanClass: Mean of the samples (of one feature) within a class
MeanClass = zeros(NClasses, NFeatures);
for c = 1:NClasses
    MeanClass(c,:) = mean( maDataTrain(veLabelTrain==Classes(c),:), 1 ); 
end


%%              Determine the square deviation sums

% ClassVar: square deviation sum inside classes (measure of variance inside a class)
ClassVar = zeros(1,NFeatures);
for c = 1:NClasses
   ClassVar = ClassVar + var( maDataTrain(veLabelTrain==Classes(c) ,:), [], 1 );
end;
ClassVar(ClassVar==0) = eps;  % OAM REVISIT: originally set to ONE, eps is better, I believe

% FeatureVar: square deviation sum of the means of the classes inside a feature
FeatureVar = zeros(1, NFeatures);
for k=1:NClasses
   FeatureVar = FeatureVar + ( 1/NClassObs(c) * ( (MeanClass(c,:)-MeanTotal) .^2 ) );
end;


%%           Evaluation of the F-coefficient  (Fisher)
% the greater the F-coefficient the more dominant are the FeatureVar compared 
% to the ClassVar (the better classes can be distinguished).

veWeight = ( FeatureVar / (NClasses-1) ) ./ ( ClassVar / (NObs-NClasses) );  % = F

% Norm veWeight
veWeight = veWeight / max(veWeight);
veWeight(isnan(veWeight)) = 0;
veWeight = veWeight';