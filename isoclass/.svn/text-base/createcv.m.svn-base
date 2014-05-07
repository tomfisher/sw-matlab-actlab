function [trainSegLabels, testSegLabels, RS] = createcv(allSegLabels, CVFolds, RS)
% function [trainSegLabels, testSegLabels, RS] = createcv(allSegLabels, CVFolds, RS)
%
% Create training/testing classlists
% All segment vectors are expected/returned as cell arrays. 
% 
% CV method:
% - Partition segments into CVFolds equal pieces
% - Select CVFolds-1 pieces for training
% - Select 1 piece for testing
% 
% |---------------------------------------|  => segments = 35
% |-------|-------|-------|-------|-------|  => CVFold = 5
% |  CV1  |  CV2  |  CV3  |  CV4  |  CV5  |
% | Train | Train | Train | Train | Test  |  => Interation 1, Test: CV5 + rem(segments, CVFold)
% | Test  | Train | Train | Train | Train |  => Interation 2
% | Train | Test  | Train | Train | Train |  => Interation 3
% | Train | Train | Test  | Train | Train |  => Interation 4
% | Train | Train | Train | Test  | Train |  => Interation 5
% 
% Copyright 2006 Oliver Amft

CVFolds = CVFolds + (CVFolds==1);

% RS init
if ~exist('RS','var') || isempty(RS) || (RS.iter == 1)
    clear RS;
    RS.segments = cellfun('size', allSegLabels, 1);
    RS.cvunits = floor(RS.segments/CVFolds) + (RS.segments < CVFolds);
    %RS.trainsegs = repmat(min(RS.segments-RS.cvunits), 1, length(RS.segments));
    RS.trainsegs = repmat(min(RS.cvunits) * (CVFolds-1), 1, length(RS.segments));
    RS.testsegs = RS.cvunits;
    RS.iter = 1;
    RS.rem = rem(RS.segments, CVFolds);
    for class = 1:length(RS.segments)
        RS.trainmarks{class} = zeros(RS.segments(class),1);
        RS.trainmarks{class}(1:RS.trainsegs(class)) = 1;
        RS.testmarks{class} = zeros(RS.segments(class),1);
        RS.testmarks{class}(RS.trainsegs(class)+1:RS.trainsegs(class)+RS.testsegs(class)) = 1;
    end; % for class
end;

if (min(RS.segments) < CVFolds), error('Not enough segments for CVFold.'); end;
if (RS.iter > CVFolds), error('Called more often than specified in CVFold.'); end;

% add segments as long as there are some left overs
for class = 1:length(RS.segments)
    testsegs = find(RS.testmarks{class}>0);

    if (RS.rem(class))
        RS.rem(class) = RS.rem(class) - 1;
        if (length(testsegs)) < (RS.testsegs(class)+1)
            pos = mod(testsegs(end),RS.segments(class))+1; %pos = pos * (pos > 0) + (pos == 0);
            %fprintf('\n%s: Debug: iter=%u: Add a test segment at %u.', mfilename, RS.iter,pos);
            RS.testmarks{class}(pos) = 1;
        end;
    else
        % delete one?
        if (length(testsegs)) > RS.testsegs(class)
            %fprintf('\n%s: Debug: iter=%u: Sub a test segment at %u.', mfilename, RS.iter,testsegs(end));
            RS.testmarks{class}(testsegs(end)) = 0;
        end;
    end;
end;


% fprintf('\n%s: Debug: iter=%u', mfilename, RS.iter);
% fprintf('\n%s: Debug: trainmarks=%s', mfilename, mat2str(RS.trainmarks{class}));
% fprintf('\n%s: Debug: testmarks =%s', mfilename, mat2str(RS.testmarks{class}));
% fprintf('\n');

% create label lists per class
for class = 1:length(RS.segments)
    trainSegLabels{class} = allSegLabels{class}(find(RS.trainmarks{class}>0),:);
    testSegLabels{class} = allSegLabels{class}(find(RS.testmarks{class}>0),:);
end; % for class


% update marks modulo segments per class
for class = 1:length(RS.segments)
    RS.trainmarks{class} = circshift(RS.trainmarks{class}, RS.cvunits(class));

    testsegs = find(RS.testmarks{class}>0);
    RS.testmarks{class} = circshift(RS.testmarks{class}, length(testsegs));
end; % for class

RS.iter = RS.iter + 1;
