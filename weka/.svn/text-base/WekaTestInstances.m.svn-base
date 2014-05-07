function [wekaEvaluation, rank] = WekaTestInstances(arffFile, wekaClassifier, wekaTrainInstances, wekaCostMatrix, verbose);
% [wekaEvaluation, rank] = WekaTestInstances(arffFile, wekaClassifier, wekaTrainInstances, costMatrix);
%       Tests the Instances in arffFile against an already trained classifier (trained with wekaTrainInstances)
%       wekaCostMatrix is optional, if not provided the cost are assumed 1 for all missclassification.
%
% rank is a struc with the following fields
%       rank.probability: probability that a feature vector falls into a class [dim: numClasses x N]
%       rank.class: the classlabel of the true class (starting with 0 for first class) [dim: 1 x N]
if (exist('verbose')~=1) verbose = 1; end;

if (~exist(arffFile,'file'))
    error('ARFF file %s not found\n',arffFile);
end

reader=java.io.FileReader(arffFile);
testInstances=weka.core.Instances(reader);
testInstances.setClassIndex(testInstances.numAttributes-1);     % DEFINE WHICH ATTRIBUTE IS CLASS INDEX IN ARFF FILE

% cost matrix in case not provided
if (nargin < 4) | isempty(wekaCostMatrix)
    wekaCostMatrix = weka.classifiers.CostMatrix(testInstances.numClasses);
    wekaCostMatrix.initialize;
end

% to get some header information and prior class distribution information, the training set is needed
wekaEvaluation = weka.classifiers.Evaluation(wekaTrainInstances, wekaCostMatrix);
%wekaEvaluation.setPriors(wekaTrainInstances);  % vermutlich nicht gebraucht, da sich 
                                                % Trainingsset nicht ge�ndert hat seit Konstruktor

wekaEvaluation.evaluateModel(wekaClassifier, testInstances);

if (nargout > 1)
    rank.probability = [];
    rank.trueClass = [];
    % get class distribution
    for i = 0:testInstances.numInstances-1
        inst = testInstances.instance(i);
        rank.probability = [rank.probability, wekaClassifier.distributionForInstance(inst)];
        rank.trueClass   = [rank.trueClass, inst.classValue];
    end
end

% plot some result in nice manner
if (verbose)
    wekaEvaluation.toSummaryString
    wekaEvaluation.toClassDetailsString
    wekaEvaluation.toMatrixString
end;
