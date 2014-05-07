function [wekaClassifier, wekaTrainInstances] = WekaTrainClassifier(arffFile, ClassifierName, OptionStringCell);
% [wekaClassifier, wekaTrainInstances] = WekaTrainClassifier(arffFile, ClassifierName, OptionStringCell)
%       Trains the classifier with the data in the arffFile.
%       If no OptionStringCell is given, default values are taken.
%       Example: OptionStringCell = {'-U,'-M','2'};
% Valid options are
% 
% C45 (C4.5)
% ===
% -U                Use unpruned tree.
% -C confidence     Set confidence threshold for pruning. (Default: 0.25) 
% -M number         Set minimum number of instances per leaf. (Default: 2) 
% -R                Use reduced error pruning. No subtree raising is performed. 
% -N number         Set number of folds for reduced error pruning. One fold is used as the pruning set. (Default: 3) 
% -B                Use binary splits for nominal attributes.
% -S                Don't perform subtree raising. 
% -L                Do not clean up after the tree has been built. 
% -A                If set, Laplace smoothing is used for predicted probabilites. 
% -Q                The seed for reduced-error pruning.
%
% IBk (k-NN)
% ===
% -K num            Set the number of nearest neighbors to use in prediction (default 3) 
% -W num            Set a fixed window size for incremental train/testing. As new training instances are added, oldest instances are removed to maintain the number of training instances at this size. (default no window) 
% -I                Neighbors will be weighted by the inverse of their distance when voting. (default equal weighting) 
% -F                Neighbors will be weighted by their similarity when voting. (default equal weighting) 
% -X                Select the number of neighbors to use by hold-one-out cross validation, with an upper limit given by the -K option. 
% -E                When k is selected by cross-validation for numeric class attributes, minimize mean-squared error. (default mean absolute error) 
% -N                Turns off normalization.
%
% NaiveBayes
% ==========
% -K                Use kernel estimation for modelling numeric attributes rather than a single normal distribution. (Default)
% -D                Use supervised discretization to process numeric attributes.


if (~exist(arffFile,'file'))
    error('ARFF file %s not found\n',arffFile);
end

reader=java.io.FileReader(arffFile);
instances=weka.core.Instances(reader);
instances.setClassIndex(instances.numAttributes-1);     % DEFINE WHICH ATTRIBUTE IS CLASS INDEX IN ARFF FILE

switch ClassifierName
    case 'C45'
        MYClassifier=weka.classifiers.trees.J48;        %DEFINE CLASSIFIER
        if (nargin == 3)
            MYClassifier.setOptions(OptionStringCell);  %SET CLASSIFIER OPTIONS
        else
            MYClassifier.setOptions({'-C','0.25','-M','2'});%SET CLASSIFIER OPTIONS (default)
        end
        MYClassifier.buildClassifier(instances);        %BUILD CLASSIFIER
    case 'IBk'
        MYClassifier=weka.classifiers.lazy.IBk;         %DEFINE CLASSIFIER
        if (nargin == 3)
            MYClassifier.setOptions(OptionStringCell);  %SET CLASSIFIER OPTIONS
        else
            MYClassifier.setOptions({'-K','3'});        %SET CLASSIFIER OPTIONS (default)
        end
        MYClassifier.buildClassifier(instances);        %BUILD CLASSIFIER
    case 'NaiveBayes'
        MYClassifier=weka.classifiers.bayes.NaiveBayes; %DEFINE CLASSIFIER
        if (nargin == 3)
            MYClassifier.setOptions(OptionStringCell);  %SET CLASSIFIER OPTIONS
        else
            MYClassifier.setOptions({'-K'});            %SET CLASSIFIER OPTIONS (default)
        end
        MYClassifier.buildClassifier(instances);        %BUILD CLASSIFIER
    otherwise
        error('Unknown Classifier');
end

wekaTrainInstances  = instances;
wekaClassifier      = MYClassifier;
