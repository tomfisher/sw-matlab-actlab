function [NObs, NFeatures, Classes, NClasses, NClassObs, isNULL] = fselPreGetStats(maDataTrain,veLabelTrain)
% function [NObs, NFeatures, Classes, NClasses, NClassObs, isNULL] = fselPreGetStats(maDataTrain,veLabelTrain)
% 
% Prepare often used dataset statistics: number of features, samples, classes, samples per class
%
% 2008, Oliver Amft

isNULL = false;
[NObs, NFeatures] = size(maDataTrain);

Classes = unique(veLabelTrain);

% handle NULL class as special, not a real class
NULLclass = find(Classes==0);
if ~isempty(NULLclass), 
	Classes(NULLclass) = []; 
	isNULL = true;
end;

NClasses = length(Classes); 

NClassObs = zeros(1, NClasses);
for c = 1:NClasses
   NClassObs(c) = sum(veLabelTrain == Classes(c));
end;
