% initmain_trainconfidence
% 
% Changes:  labellist_load
% 
% optional parameters:
%   initmain_onetraintestpartnrs - specify partnrs that are used for training (indices: 1,2,...)
testconf = 0.1;

% to create a useful CV set CVFolds = 1, hence one chunk for training (first one) and rest for testing
% CVFolds = 1;

% determine trainsections
if (~exist('initmain_onetraintestpartnrs', 'var'))  || isempty(initmain_onetraintestpartnrs)
    fprintf('\n%s: WARNING: Parameter initmain_onetraintestpartnrs not set.', mfilename);
    %fprintf('\n%s: Guessing initmain_onetraintestpartnrs from Repository.TrainClasses.', mfilename);
    fprintf('\n%s: Guessing trainsections from Repository.TrainClasses.', mfilename);
    %initmain_onetraintestpartnrs = repos_findpartfromlabels(segment_findlabelsforclass(labellist_load, Repository.TrainClasses), partoffsets);
    trainsection = segment_findlabelsforclass(labellist_load, Repository.TrainClasses);
    %     trainsection = [1 partoffsets(2)];  % assume first PI for training only.
else
    fprintf('\n%s: initmain_onetraintestpartnrs=%s.', mfilename, mat2str(initmain_onetraintestpartnrs));
    trainsection = offsets2segments(partoffsets);
    trainsection = trainsection(initmain_onetraintestpartnrs,:);
end;
trainsection = segment_distancejoin(trainsection,2);
fprintf('\n%s: partoffsets: %s', mfilename, mat2str(partoffsets));
fprintf('\n%s: trainsection: %s', mfilename, mat2str(trainsection));



% adapt labellist
trainlabelmarks = segment_markincluded(trainsection, labellist);
labellist(~trainlabelmarks, 6) = testconf;

% adapt labellist_load
%trainlabelmarks = vec2onehot(segment_findincluded(trainsection, labellist_load), size(labellist_load,1));
trainlabelmarks = segment_markincluded(trainsection, labellist_load);
labellist_load(~trainlabelmarks, 6) = testconf;

fprintf('\n%s: Nr of labels: %u, merged: %u', mfilename, size(labellist_load,1), size(labellist,1));
    
if ~exist('PRLabelConfThres', 'var') || (PRLabelConfThres > testconf)
    fprintf('\n%s: WARNING: PRLabelConfThres is not set according to test label confidence.', mfilename);
end;
