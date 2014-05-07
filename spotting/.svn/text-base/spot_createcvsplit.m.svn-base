function [trainslices, testslices, dotraining] = spot_createcvsplit(CVMethod, CVFolds, classseglist, ...
	Repository, Partlist, varargin)
% function [trainslices, testslices, dotraining] = spot_createcvsplit(CVMethod, CVFolds, classseglist, ...
% 	Repository, Partlist, varargin)
%
% Create CV split slices for spotting routines.
% 
% To get labellists use something like:
% 			trainseglist = classseglist(segment_countoverlap(classseglist, trainslices{cvslice}) > 0, :);
% 			testseglist = classseglist(segment_countoverlap(classseglist, testslices{cvslice}) > 0, :);
% 
% Copyright 2008-2009 Oliver Amft

[mintrainshare LabelConfThres CVSectionBounds MaxPartitionSkew partoffsets verbose] = ...
    process_options(varargin, ...
	'mintrainshare', 0.1, 'LabelConfThres', 1, 'CVSectionBounds', [], 'MaxPartitionSkew', 0.5, ...
    'partoffsets', [], 'verbose', 1);

if isempty(partoffsets)
    partoffsets = repos_getpartsize(Repository, Partlist, 'OffsetMode', true);
end;

switch lower(CVMethod)
	case 'intrasubject'
        if isempty(CVSectionBounds)
            % constant event rate CV folding
            % 1. find CVFolds split for classseglist by reducing/growing section shadows
            s = classseglist;
            for r = 0.1:0.1:1
                if any(segment_countoverlap(segment_enlage(classseglist, r), classseglist) ~= 1), break; end;
                s = segment_enlage(classseglist, r);
            end;
            if size(s,1) < CVFolds,
                fprintf('\n%s: WARNING: Could not find classseglist split for %u sections and CVFolds=%u', mfilename, size(s,1), CVFolds );
                error;
            end;
            % fill CV folds equally, account for fractions
            EpCV = size(s,1)/CVFolds; start = 1; dataslices = cell(1, CVFolds);
            for i = 1:CVFolds
                stop = floor(i*EpCV);
                dataslices{i} = s(start:stop,:);  
                dataslices{i} = segment_distancejoin(dataslices{i},2, 'checklabel', false);
                start = stop+1;
            end;

            % for i = 1:length(dataslices), fprintf('\n%2u:  %u', i, sum(segment_size(dataslices{i}))); end; fprintf('\n');
            % for i = 1:length(tmp), fprintf('\n%2u:  %u', i, sum(segment_size(tmp{i}))); end; fprintf('\n');

            
            % 2. split embedding data into CVFolds and add to respective classseglist splits
            sN = segment_findgaps(s, 'Maxsize', partoffsets(end));
            
            % fill CV folds equally with embedding data
            % OAM REVISIT: may happen that part of inbetween sections arrives in other CV fold than surrounding labels
            sNpCV = sum(segment_size(sN))/CVFolds; start = 1;  tmp = cell(1, CVFolds);
            for i = 1:CVFolds
                stop = floor(i*sNpCV);
                sN = segment_splitsection(sN, stop, 'mode', 'offset');
                %tmp{i} = segment_createlist(sN(isbetween(cumsum(segment_size(sN)), [start stop]), :), 'classlist', 0);
                dataslices{i} = [dataslices{i}; segment_createlist(sN(isbetween(cumsum(segment_size(sN)), [start stop]), :), 'classlist', 0)];  
                dataslices{i} = segment_distancejoin(dataslices{i},2, 'checklabel', false);
                start = stop+1;
            end;
           
            
            % old
%             CVSectionBounds = classseglist(:,1:2);
%             dataslices = segment_createsplit(partoffsets(end), CVFolds, CVSectionBounds);

            % compile cv sets from dataslices
            trainslices = cell(1, CVFolds);  testslices = cell(1, CVFolds);
            for i = 1:CVFolds
                cvset = circshift(1:CVFolds,[1 i]);
                tmp = cell2mat(dataslices(cvset(1:end-1))');
                trainslices{i} = tmp(:,1:2);  testslices{i} = dataslices{cvset(end)}(:,1:2);
            end;
            
        else
            if size(CVSectionBounds,1)==CVFolds || (CVFolds==1 && size(CVSectionBounds,1)==2)
                % this is not an ideal solution: what is good here?
                dataslices = CVSectionBounds;
                fprintf('\n%s: WARNING: Assuming dataslices according to CVSectionBounds: %s', mfilename, mat2str(dataslices));
            else
                dataslices = segment_createsplit(partoffsets(end), CVFolds, CVSectionBounds);
            end;
            dataslices = segment_filterlargesplit(dataslices, classseglist, MaxPartitionSkew);
            % 			trainslices = cell(1, length(dataslices));
            % 			testslices = cell(1, length(dataslices));
            [trainslices, testslices] = prepisocv({dataslices}, CVFolds, 'verbose', 0); % bug: may return some pre-used testlabels
            trainslices = cellsqueeze(trainslices); testslices = cellsqueeze(testslices); % omit class structuring
        end;



	case 'intersubject'
		% atrificial intermediate problem: use observations from all subjects
		% requires much higher CVFolds than number of subjects to aviod
		% same results as 'newsubject'
		subjectnames = repos_getsubjects(Repository, Partlist);
		if (length(subjectnames) >= CVFolds),
			fprintf('\n%s: CVFolds is too low (%u) for %s. ', mfilename, CVFolds, CVMethod);
			CVFolds = length(subjectnames) * 2;
			fprintf('Changing it to %u.', CVFolds);
		end;
        
        if isempty(CVSectionBounds)
            CVSectionBounds = classseglist(:,1:2);
            dataslices = segment_createsplit(partoffsets(end), CVFolds, CVSectionBounds);
        else
            if size(CVSectionBounds,1)==CVFolds || (CVFolds==1 && size(CVSectionBounds,1)==2)
                % this is not an ideal solution: what is good here?
                dataslices = CVSectionBounds;
                fprintf('\n%s: WARNING: Assuming dataslices according to CVSectionBounds: %s', mfilename, mat2str(dataslices));
            else
                dataslices = segment_createsplit(partoffsets(end), CVFolds, CVSectionBounds);
            end;
        end;

        dataslices = segment_filterlargesplit(dataslices, classseglist, MaxPartitionSkew);
		[trainslices, testslices] = prepisocv({dataslices}, CVFolds, 'verbose', 0); % returns some pre-used testlabels
		trainslices = cellsqueeze(trainslices); testslices = cellsqueeze(testslices); % omit class structuring


	case 'newsubject'
		% select (subjects-1) for training, one for testing
        % ignores CVSectionBounds

		% build a list of subject data boundaries
		subjectnames = repos_getsubjects(Repository, Partlist);
		if length(subjectnames)<=1, error('Not enough subjects in Partlist to run CVMethod=''newsubject'''); end;
		CVFolds = length(subjectnames);
		fprintf('\n%s: Changed CVFolds to %u (%s).', mfilename, CVFolds, CVMethod);

		subjectseglist = [];
		for subjectnr = 1:length(subjectnames)
			sparts = repos_getpartsforsubject(Repository, Partlist, subjectnames{subjectnr});
			subjectseglist = [ subjectseglist; ...
				[partoffsets(sparts(1)==Partlist)+1 partoffsets(find(sparts(end)==Partlist)+1)] ];

			% check that Partlist is sorted for each subject (no interleaving of subject recordings!)
			if sum(abs(diff(findn(Partlist, sparts)))) > 2, error('Partlist is incompatible for CVMethod=''newsubject'''); end;
		end;

		%dataslices = segment_createsplit(partoffsets(end), CVFolds, subjectseglist);
		dataslices = subjectseglist;  % CV bounds are given by subjects

		[trainslices, testslices] = prepisocv({dataslices}, CVFolds, 'verbose', 0); % returns some pre-used testlabels
		trainslices = cellsqueeze(trainslices); testslices = cellsqueeze(testslices); % omit class structuring

		
		
	case 'twosvalidation'
		% NStudy validation experiment: train on 1 day, verify using 2nd day
		% Determine CV bound from PI recording date differences

		% OAM REVISIT: use repos_getpartsforevalday instead!
		days = str2num(datestr(repos_getrecdate(Repository, Partlist, 'method', 'keylabel'), 7));  % must stay str2num
		sessionlimit = find(abs(diff(days)) > 1);
		% if there is no break in the sessions try
		if isempty(sessionlimit) || (length(sessionlimit)>1), error('Could not find appropriate session limits.'); end;

		% CV bounds are given by session limits on individual days
		dataslices = [ 1 partoffsets(sessionlimit+1);  partoffsets(sessionlimit+1)+1 partoffsets(end) ];

		CVFolds = 2;
		fprintf('\n%s: Changed CVFolds to %u (%s).', mfilename, CVFolds, CVMethod);

		[trainslices, testslices] = prepisocv({dataslices}, CVFolds, 'verbose', 0); % returns some pre-used testlabels
		trainslices = cellsqueeze(trainslices); testslices = cellsqueeze(testslices); % omit class structuring

	otherwise
		error('CVMethod %s not understood.', CVMethod);
end;


% mark CV whether it includes training labels in each iteration
dotraining = repmat(false, 1, CVFolds);
for cvi = 1:CVFolds
	% find labels within slices
	trainseglist = classseglist(segment_countoverlap(classseglist, trainslices{cvi}) > 0, :);
	trainseglist(trainseglist(:,6)<LabelConfThres,:) = []; % omit tentatives for accouting
	%testseglist = classseglist(segment_countoverlap(classseglist, testslices{cvi}) > 0, :);


	% check whether there are enough training labels
	if size(trainseglist,1) < (size(classseglist,1)*mintrainshare)
		dotraining(cvi) = false;
		if (verbose)
			fprintf('\n%s: WARNING: Not enough training examples (%u, min: %u) for CV %u', ...
				mfilename, size(trainseglist,1), round(size(classseglist,1)*mintrainshare), cvi);
		end;
	else dotraining(cvi) = true;
	end;
end;  % for cvi

if all(~dotraining), error('No feasible training slice found, exiting!'); end;

if ( dotraining(1) == false )  % search/reoder partitions for a suitable solution
	if (verbose),	fprintf('\n%s: Reordering CV partitions...', mfilename); end;
	exchangecv = find(dotraining,1);
	trainslices([1, exchangecv]) = wire(trainslices([exchangecv, 1])); % swap entries
	testslices([1, exchangecv]) = wire(testslices([exchangecv, 1])); % swap entries
	dotraining([1, exchangecv]) = wire(dotraining([exchangecv, 1]));
	if (verbose), fprintf(' swapped CV 1 with CV %u', exchangecv); end;
end;
