function ok = checkcv(seglist, trainIndices, testIndices, varargin)
% function ok = checkcv(seglist, trainIndices, testIndices, varargin)
%
% Check consistency of a CV split
%
% Parameter seglist is a list of labels, including column 4 with class ids.
% Parameters trainIndices, testIndices are cell arrays with indices to
% seglist. Structure: trainIndices{cviteration}{class} = [idx1 idx2 ...]';
% See code for what checks are performed.
%
% Copyright 2007 Oliver Amft

ok = false;

CVFolds = length(trainIndices);
thisTargetClasses = 1:length(trainIndices{1});

verbose = process_options(varargin, 'verbose', 1);

alltestlabels = cell(length(thisTargetClasses),1);  alltestidx = cell(length(thisTargetClasses),1);
for cviters = 1:CVFolds
    if (verbose), fprintf('\n%s: Checking CV iteration: %u of %u...', mfilename, cviters, CVFolds); end;

    if (verbose>1)
        fprintf('\n%s: Total: %s', mfilename, ...
            mat2str(cellfun('size', segments2classlabels(length(unique(seglist(:,4))), seglist),1)));
        fprintf('\n%s: Train: %s', mfilename, mat2str(cellfun('size',trainIndices{cviters},1)));
        fprintf('\n%s: Test: %s', mfilename, mat2str(cellfun('size',testIndices{cviters},1)));
    end;

    for class = 1:length(thisTargetClasses)
        trainlabels = seglist(trainIndices{cviters}{class},:);
        testlabels = seglist(testIndices{cviters}{class},:);
        alltestlabels{class} = [ alltestlabels{class}; testlabels ];
        alltestidx{class} = [ alltestidx{class}; testIndices{cviters}{class} ];

        if (verbose>2), fprintf('\n%s: Class %u, Train: %u Test: %u', mfilename, class, size(trainlabels,1), size(testlabels,1)); end;

        % check for: trainlabels having wrong class id
        if any(trainlabels(:,4) ~= class), error('Train class error.'); end;
        % check for: testlabels having wrong class id
        if any(testlabels(:,4) ~= class), error('Test class error.'); end;
        % check for: any trainindices that are used aswell for testing in current cviter
        if any(findn(trainIndices{cviters}{class}, testIndices{cviters}{class})), error('Train/Test class error.'); end;
    end;
end;

if (verbose), fprintf('\n%s: Checking test labels...', mfilename); end;
for class = 1:length(thisTargetClasses)
    commonsegs = segment_findidentical(alltestlabels{class});

    % check for: identical labels in testlabels of all cviters
    if ~isempty(commonsegs)
        if (length(commonsegs) > 0.05*size(alltestlabels{class}))
            error('Found %u identical segments in test list', length(commonsegs));
        else
            warning('Found %u identical segments in test list', length(commonsegs));
        end;
    end;

    % check for: full coverage of all labels in test
    if (length(find(seglist(:,4)==class)) ~= size(alltestlabels{class},1)), 
        error('Some labels are not tested for class %u.', class); 
    end;
end;



fprintf('\n');

ok = true;
return;


% visualisation

plot(subjectidlist)
hold on
plot(testIndices{8}{1}, repmat(8, length(testIndices{8}{1}),1), 'g')
plot(trainIndices{8}{1}, repmat(8, length(trainIndices{8}{1}),1), 'r')

plot(testIndices{8}{2}, repmat(8, length(testIndices{8}{2}),1), 'c')
plot(testIndices{8}{3}, repmat(8, length(testIndices{8}{3}),1), 'c')



