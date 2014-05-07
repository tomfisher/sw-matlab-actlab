function [result, relevant, retrieved, recognised] = ...
    WekaTestFeatures(FeatureMatrix, IndicesToConsider, classifier, wekaTrainInstances, TrueClass);
% result = WekaTestFeatures(FeatureMatrix, IndicesToConsider, classifier, wekaTrainInstances)
%       Tests the FeatureMatrix against an already trained classifier (trained with wekaTrainInstances)
%       FeatureMatrix is NxM with N feature vectors of class ClassLabelStr
%       and each feature vector contains M features, of which only IndicesToConsider are considered.
%       IndicesToConsider can also be 'all', in which case all M features are considered.
%
% result is a struc with the following fields
%       result.class        the classification result for each feature vector (starts with class 0) [dim: 1xN]
%       result.classAsStr   same as above but in String representation
%       result.rank         continuous classifier: probability that a feature vector falls into a class [dim: numClasses x N]
%       result.InfoStr      CellString containing the name of all classes


% test if IndicesToConsider = 'all'
if (ischar(IndicesToConsider))
    if (strcmp(IndicesToConsider,'all') | strcmp(IndicesToConsider,'All'))
        IndicesToConsider = [1:size(FeatureMatrix,2)];
    else
        error('unrecognized type for IndicesToConsider');
    end
end

inst = weka.core.Instance(wekaTrainInstances.numAttributes); % CREATE new instance
inst.setDataset(wekaTrainInstances);

result.class=[];
result.classAsStr=[];
result.rank=[];

for n=1:size(FeatureMatrix,1)
    k=0;
    for m=IndicesToConsider
        inst.setValue(k, FeatureMatrix(n,m));
        k = k+1;
    end
    result.class(n)      = classifier.classifyInstance(inst);
    result.classAsStr{n} = inst.attribute(inst.classIndex).value(result.class(n)).toCharArray';
    result.rank(:,n)     = classifier.distributionForInstance(inst);
end

for i=1:inst.numClasses
    result.InfoStr{i}    = inst.attribute(inst.classIndex).value(i-1).toCharArray';
end

if (exist('TrueClass')==1)
    rank = result.rank;
    for class = 1:length(unique(TrueClass))
        relevant(class) = length(find(TrueClass == class));
        [dummy, recclass] = max(rank);
        retrieved(class) = length(find(recclass == class));
        recognised(class) = length(find(((TrueClass == recclass).*TrueClass) == class));
    end;
else
    relevant = []; retrieved = []; recognised = [];
end;