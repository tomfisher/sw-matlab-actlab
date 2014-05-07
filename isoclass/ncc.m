function recognition_rate = ncc(traindata,trainlabels,testdata,testlabels)
% recognition_rate = ncc(traindata,trainlabels,testdata,testlabels)
% is a nearest class center classifier
% 
% INPUTS: 
%    traindata:   N1 x d matrix of feature data (train data)
%    trainlabels: N1 x 1 column vector of classlabels (train classlabels)
%    testdata:    N2 x d matrix of feature data   (test data)
%    testlabels:  N2 x 1 column vector of classlabels (test classlabels)
% 
% OUTPUTS: 
%    recognition_rate:  accuracy (percentage) on the test data for a classifier 
%                       trained on the training data 

N1 = max(trainlabels);   % we determine how many classes we use
[N2,d] = size(testdata); % size of the test data


% compute class means
for j = 1 : N1
    class_mean(j,:) = mean(traindata(trainlabels == j,:));
end

% find the nearest class for each of the test vectors
for i = 1 : N2
   
    for j = 1 : N1
        dist(j) = euclidean(testdata(i,:), class_mean(j,:)); % calculate distance
    end
    [m, predict_class(i)] = min(dist(:));  % find a min distance
end

% calculate the accuracy as the percent of matching predictions
recognition_rate = 100*sum(predict_class == testlabels')/N2;


%---------------------------------------------------------------
function dist = euclidean(x,y)
% Calculates the Euclidean distance between two vectors x and y

% precompute the difference
 diff = x-y;
 dist = sqrt(diff*diff');
