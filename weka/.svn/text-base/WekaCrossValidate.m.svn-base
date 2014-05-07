function [wekaEvaluation, rank, relevant, retrieved, recognised] = ...
    WekaCrossValidate(arffFile, numFolds, ClassifierName, OptionStringCell);
% function [wekaEvaluation, rank, relevant, retrieved, recognised] = ...
%     WekaCrossValidate(arffFile, numFolds, ClassifierName, OptionStringCell);
%
%       performs a numFolds (stratified if class is nominal) cross-validation  
%       for a classifier on a set of instances given in arffFile. 
%       ClassifierName and are OptionStringCell the same as in WekaTrainClassifier.m
%
% rank is a struc with the following fields
%       rank.probability: probability that a feature vector falls into a class [dim: numClasses x N]
%       rank.class: the classlabel of the true class (starting with 0 for
%       first class) [dim: 1 x N]

% 2005, 2006 Mathias Staeger, Oliver Amft, Wearable Computing Lab, ETH Zurich

if (~exist(arffFile,'file'))
    error('ARFF file %s not found\n',arffFile);
end

reader=java.io.FileReader(arffFile);
instances=weka.core.Instances(reader);
instances.setClassIndex(instances.numAttributes-1);     % DEFINE WHICH ATTRIBUTE IS CLASS INDEX IN ARFF FILE
rank.probability = [];
rank.trueClass = [];

switch ClassifierName
    case 'C45'
        MYClassifier=weka.classifiers.trees.J48;        %DEFINE CLASSIFIER
        if (nargin == 4)
            MYClassifier.setOptions(OptionStringCell);  %SET CLASSIFIER OPTIONS
        else
            MYClassifier.setOptions({'-C','0.25','-M','2'});%SET CLASSIFIER OPTIONS (default)
        end
    case 'IBk'
        MYClassifier=weka.classifiers.lazy.IBk;         %DEFINE CLASSIFIER
        if (nargin == 4)
            MYClassifier.setOptions(OptionStringCell);  %SET CLASSIFIER OPTIONS
        else
            MYClassifier.setOptions({'-K','3'});        %SET CLASSIFIER OPTIONS (default)
        end
    case 'NaiveBayes'
        MYClassifier=weka.classifiers.bayes.NaiveBayes; %DEFINE CLASSIFIER
        if (nargin == 4)
            MYClassifier.setOptions(OptionStringCell);  %SET CLASSIFIER OPTIONS
        else
            MYClassifier.setOptions({'-K'});            %SET CLASSIFIER OPTIONS (default)
        end
    otherwise
        error('Unknown Classifier');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% follow code for "crossValidateModel" from weka.classifier.Evaluation %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
random = java.util.Random;
%random.setSeed(1);
instances.randomize(random);
wekaEvaluation = weka.classifiers.Evaluation(instances);

if (instances.classAttribute.isNominal)
    instances.stratify(numFolds);
end

% Do the folds
for i=0:numFolds-1
      % build trainings set
      train = instances.trainCV(numFolds, i, random);
      wekaEvaluation.setPriors(train);
      MYClassifier.buildClassifier(train);
      
      % build test set
      test = instances.testCV(numFolds, i);
      wekaEvaluation.evaluateModel(MYClassifier, test);
      if (nargout > 1)       % get class distribution
        for j = 0:test.numInstances-1
            inst = test.instance(j);
            rank.probability = [rank.probability, MYClassifier.distributionForInstance(inst)];
            rank.trueClass =   [rank.trueClass, inst.classValue];
        end
    end
end

wekaEvaluation.toSummaryString 
wekaEvaluation.toClassDetailsString
wekaEvaluation.toMatrixString

for class = 1:size(rank.probability,1)
    relevant(class) = length(find(rank.trueClass == class-1));
    [dummy, recclass] = max(rank.probability, [],1);
    retrieved(class) = length(find(recclass == class));
    recognised(class) = length(find(((rank.trueClass == (recclass-1)).*(rank.trueClass+1)) == class));
end;

