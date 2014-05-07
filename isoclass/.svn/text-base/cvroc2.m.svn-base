function [fpr tpr auc evalu rank] = cvroc2(nfold, ClassifierName, OptionStringCell, lenTest, filename)
%   cvroc2(nfold, ClassifierName, OptionStringCell, plot)

% Oliver Amft, Wearable Computing Lab, ETH Z�rich, Mar 2005

verbose = 1;
if (nargin<5)
    FilenameTest  = 'DATA/cvroc2.arff';
else
    FilenameTest  = filename;
end;
if (nargin<4) lenTest=0; end;

%% nfold cross validation and plotting

if (verbose)
    fprintf('CV Classifier: %s Parameters: %s %s\n', ...
        ClassifierName, OptionStringCell{1}, OptionStringCell{2});
    fprintf('run %u-fold cross-validation...', nfold);
end;
[evalu, rank] = WekaCrossValidate(FilenameTest, nfold, ClassifierName, OptionStringCell);


if (length(lenTest) == 2)
    
    [fpr, tpr, auc] = generateROC(rank.probability(1,:), rank.trueClass);
    if (verbose) fprintf('instances: %u\n', size(rank.trueClass,2)); end;

    precision = tpr*lenTest(1)./(tpr*lenTest(1) + fpr*lenTest(2));

    figure(1); hold on; grid on; axis square;
    xlabel('False positive rate'); ylabel('True positive rate');

    figure(2); hold on; grid on; axis square;
    xlabel('Recall'); ylabel('Precision');

    figure(1); plot(fpr,tpr, 'b', 'LineWidth', 2);
    figure(2); plot(tpr, precision, 'b', 'LineWidth', 2);

    figure(1); legend(sprintf('%s: %s %s, AUC=%0.5g', ...
        ClassifierName, OptionStringCell{1}, OptionStringCell{2}, auc));
end;

% figure(1); legend(sprintf('C4.5, C=0.25, AUC=%0.5g',AUC(1)), sprintf('kNN, k=3, AUC=%0.5g',AUC(2)), sprintf('kNN, k=7, AUC=%0.5g',AUC(3)),'Location','SouthEast');
% figure(2); legend('C4.5, C=0.25', 'kNN, k=3', 'kNN,
% k=7','Location','SouthWest');