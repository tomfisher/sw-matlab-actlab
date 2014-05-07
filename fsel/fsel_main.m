error('Old code');
% this is old code and should be reworked and integrated into
% fselEval*-methods. One example is fselEvalFeatures.m. Oliver

% (c) 2007 Holger Harms, Wearable Computing Lab., ETH Zurich

fprintf('\n******************************\n');
fprintf('* Feature Selection Toolbox  *\n');
fprintf('******************************\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load data from (mat) file
% -> Train Data: maDataTrain, veLabelTrain
% -> Test Data: maDataTest, veLableTest
% -> Relevance: veWeight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load( 'data_in/bm_marc_st1.mat');
% load( 'data_in/bm_marc_st1_orig.mat');
% load( 'data_in/bm_holger_st1_nonull.mat');
 load('data_in/bm_holger_st1_nonull_exp.mat');
% load( 'data_in/bm_holger_st2_nonull.mat');
% load('data_in/bm_holger_st2_nonull_exp.mat');
% load('data_in/sport_abdominal.mat');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mode
%
% Mode can be wrapper or filter:
%
% (1) Wrapper are running until _ONE_ criterium is reached:
% -> termSens denotes a sensitivity that shall be reached
% -> termLoop denotes a maximal number of tries
%
% (2) Filter are running one time
% -> termLoop is set to 1
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mode = 'filter';
%mode = 'wrapper';
termLoop = 1000;         % maximal loops
termSens = 0.9;        % desired sensitivity

% if mode is filter, the program runs only once
if ( strcmp(mode, 'filter') == 1 )
    termLoop = 1;
    termSens = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:termLoop

    % make every feature valid
    veWeight(:) = 1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Preselection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % clip train data from range
    [veWeight] = fselPreDismissBounds( maDataTrain, veWeight, 0, 100 );
    

    veHelp=veWeight; % to clip Data in sort-methods
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                    Feature Weighting Methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Weight features (manipulates veWeight)
    %
    %......................................................................
    % Random and Entropy based weighting methods
    %......................................................................
    
    % [maDataTrain veWeight] = fselWeightRandom( maDataTrain, veLabelTrain, veWeight );
    % [maDataTrain veWeight] = fselWeightEntropy( maDataTrain, veLabelTrain, veWeight );
    
    
    %......................................................................
    % statistical weighting methods
    %......................................................................
    
    [veWeight] = fselWeightAnova(maDataTrain,veLabelTrain, veWeight);
    
    %[veWeight] = fselWeightKRUSKAL(maDataTrain,veLabelTrain,veWeight); %
    
    %[veWeight] = fselWeightPearson(maDataTrain,veHelp,veWeight);

    %[veWeight] = fselWeightSpearman(maDataTrain,veHelp,veWeight);

    %[veWeight]=fselWeightCorrB(maDataTrain,veHelp,veWeight,veLabelTrain,'Pearson')

    %......................................................................
    % informationtheoretic weighting methods
    %......................................................................


    %[veWeight] = fselWeightMutualInformation(maDataTrain,veLabelTrain,veWeight);

    %[veWeight] = fselWeightMutualInformationII(maDataTrain,veLabelTrain,veWeight);
    %......................................................................
    % heuristic weighting methods
    %......................................................................
    AnzTree=150;
    NumFeat=8;
    
    
   %[veWeight] = fselWeightRandomForests(maDataTrain,veLabelTrain,AnzTree,'Entropy',1000,NumFeat,0.02,2);
    % optimal for  AnzTree  NumFeat
    %              81        4
    %              729       2
    %              234       8
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Evaltuation and Test loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    maDataTrainA=maDataTrain;
    veWeightA=veWeight;
    maDataTestA=maDataTest;
    hold on



    ACC=[];
    ACC(1)=0;
    D=zeros(12,6);
    Ind=zeros(8,1);
    

    for Beta=0.5
        for N=1:27
            
            maDataTrain=maDataTrainA;
            maDataTest=maDataTestA;
            veWeight=veWeightA;



            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %                    Feature Selection Methods
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Selecting the "best" features after giving them a Weight
            % Idea of correlation-based and information-theoretic-based selection
            % methods is to reject redundant  features

            %......................................................................
            % Selecting Methodes based on veWeight
            %......................................................................
            % - the highest N features hold the weight, the others are set to 0

            [veWeight] = fselSortBestN( maDataTrain, veLabelTrain, veWeight, N );


            %......................................................................
            % correlation-based selection methods
            %......................................................................

            %[veWeight] = fselSortPearson(maDataTrain,veWeight,Beta,N,veHelp);
            % optimal Beta =0.2
            %Beta=0.5
            % [veWeight] = fselSortSpearman(maDataTrain,veWeight,Beta,N,veHelp);
            % no optimal Beta found

            % Beta=0.8;
            %[veWeight] = fselSortCorr(maDataTrain,veWeight,Beta,N,veHelp,'Pearson');
            % optimal Beta = 0.2 (features redundant are redundant if corr(f1;f2)>Beta)
            % optimal Beta=0.15
            % Corr_type == 'Spearman', 'Pearson'

            %......................................................................
            % information-theoretic-based selection methods
            %......................................................................

            %Beta=0.5;
            %[veWeight] = fselSortMIFS(maDataTrain,veWeight,Beta,N,veHelp,'MIFS');
            % MIFS_Type == 'MIFSU' 'MIFS' optimal Beta > 0.1


            %..................................................................
            %     Determine the selected Features
            %..................................................................

            [Wert Ind]=sort(veWeight,'descend');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Modify data by removing the irrelevant features (veWeight == 0)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [maDataTrain maDataTest] = fselModDataByWeight( maDataTrain, maDataTest, veWeight );

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Classifier (NCC)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [ veClassTest dummy ] = ncc( maDataTrain, veLabelTrain, maDataTest);
            %[ veClassTest dummy ] = NaiveBayes( maDataTrain, veLabelTrain, maDataTest)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Evaluation functions of classifier
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % parameter: fselEvalClassification( class real, class classified, nullclass )
            % returns sensitivity, specificity
            [acc] = fselEvalClassification( veLabelTest, veClassTest );
            fprintf('Accuracy = %3.2f percent\n', acc*100 );


            % parameter ( class real, class test )
            % returns plotted confusion matrix
            
            %..............................................................
            % Confusion Matrix
            %..............................................................
            % to determine the confusion matrix you have to uncomment this
            % part !!!!
            
            % figure(2)
            % hold on
            % fselEvalConfMat(veLabelTest, veClassTest,N );
            %..............................................................
            ACC(N+1)=acc;
        end

        figure(1)
        hold on
        plot(0:N,ACC,'b.-')




        fprintf('the selected feautres are:')
        A=Ind(1:N);
        C=[mod(A,3) floor((A+3)/3)];


    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Check for termination
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ( acc >= termSens )
        fprintf('%d of %d features selected.\n', sum(veWeight(:) > 0), length(veWeight) );
        %fprintf('Wrapper found %3.2f sensitivity (termSens=%3.2f)\n', sens, termSens );
        %fprintf('Feature weighting: %1.3f\n', veWeight );
        return;
    end;

end