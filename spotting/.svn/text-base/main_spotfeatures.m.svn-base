% main_spotfeatures
%
% Computes features for search/spotting procedures
% Although signals can be processed at modified data rates (using DSSet)
% segment list (SF_fmsectionlist) is returned at the nominal data rate (markersps).
%
% WARNING: Does not support individual features for each class (run separately)
 

% requires
Partlist;
fidx;
% FeatureString;
% forcewrite; % false => will NOT override existing feature files!  

VERSION = 'V038';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit below confidence thres during training
if ~exist('FeatureString', 'var'), error('Variable FeatureString not provided.'); end;
if ~exist('DSSet', 'var'), error('Variable DSSet not provided.'); end;
if ~exist('forcewrite', 'var'), forcewrite = false; end;


% initmain has renumbered classes, this is not what we want for feature
% computation. In this way feature files are more generic.
[seglist thisTargetClasses] = segment_classfilter(MergeClassSpec, labellist_load, 'ClassIDMode', 'keepid');
if isempty(thisTargetClasses), 
	thisTargetClasses = TargetClasses;
	fprintf('\n%s: WARNING: seglist is empty! This happens when no valid labels were found in', mfilename);
	fprintf('\n%s: any PI of Partlist - usually a bogus config!  thisTargetClasses=%s', mfilename, mat2str(thisTargetClasses));
	warning('MATLAB:main_spotfeatures', 'All PIs must be available for spotting - to determine search depth.');
end;
% WARNING: Do not replace labellist here, this may break further scripts run subsequently to this one


% guess segmentation config for each class
initmain_segconfig;


if ~exist('SpottingMode','var'), SpottingMode = 'adaptive'; end;
if ~exist('SpottingSearchWindow','var'), SpottingSearchWindow = 0.3; end;  % in sec
if ~exist('SpottingEval_Params','var'), SpottingEval_Params = {'MergeMethod', 'FrontOfBest'}; end;



% -------------------------------------------------------------------------
% estimate search depth
% WARNING: To estimate the global search depth all parts are used.
% For this reason ALL parts must be computed anew when Partlist or seglist was
% changed. Training, testing will later select from the global list.
%
% SF_searchwindow = [lowerbound upperbound]
% provides: Global_SF_searchwindow
% -------------------------------------------------------------------------
All_SF_searchwindow = cell(length(thisTargetClasses),1);
for classnr = 1:length(thisTargetClasses)
		thisSegmentationMode = SegmentationMode{classnr};
		
        fprintf('\n%s: Class %u: Spotting mode: %s, search depth:', mfilename, thisTargetClasses(classnr), lower(SpottingMode));
        aseglist = repos_getsegmentation(Repository, Partlist, 'SampleRate', SampleRate, 'SegmentationMode', thisSegmentationMode);
        tmp = segment_countoverlap( ...
			segment_findlabelsforclass(seglist(seglist(:,6)>=LabelConfThres,:), thisTargetClasses(classnr)), ...
			aseglist, -inf);

        switch lower(SpottingMode)
%             case 'adaptive'
%                 SF_searchwindow = round([ min(tmp)+(min(tmp)==0)  (max(tmp)+(max(tmp)==0)) ]); % max(tmp) ]);
%                 %SF_searchwindow = round([1 max(tmp)]);
			case { 'fixed', 'adaptive', 'maxtest' }
                %SF_searchwindow = repmat(round(mean(tmp)) + (min(round(mean(tmp)))==0), 1,2);
                SF_searchwindow = [ (min(tmp)+(min(tmp)==0))  (max(tmp)+(max(tmp)==0)) ];
            case 'specified'  % defined spotting size, SpottingSearchWindow is in sec
                tmp = round(SpottingSearchWindow*SampleRate/mean(segment_size(aseglist)));
                if length(tmp)==1, SF_searchwindow = repmat(tmp+(tmp==0), 1,2);
                else SF_searchwindow = [ tmp(1)+(tmp(1)==0) tmp(2) ]; end;
            otherwise
                error('SpottingMode not supported');
        end;
        fprintf(' %s', mat2str(SF_searchwindow));
		All_SF_searchwindow{classnr} = SF_searchwindow;
        clear tmp aseglist SF_searchwindow;
end; % for classnr


% -------------------------------------------------------------------------
% create one feature file for each Partindex and class
% since classes may be completly different and processing intensive
% -------------------------------------------------------------------------
for partnr = 1:length(Partlist)
    Partindex = Partlist(partnr);
    fprintf('\n%s: Process part %u...', mfilename, Partindex);
    
    SampleRate = repos_getmarkersps(Repository, Partindex, 'singlesps', true);
    partsize = repos_getpartsize(Repository, Partindex);
    partseglist = repos_findlabelsforpart(seglist, partnr, partoffsets, 'remove');
    
    usesources = unique(fb_getsources(FeatureString));
    usesystems = unique(repos_getsysfromsensor(Repository, Partindex, usesources));

	doload = true; % mark whether data should be loaded for the PI/class combination

    % compute search features
    for classnr = 1:length(thisTargetClasses)
		% get search depth
		SF_searchwindow = All_SF_searchwindow{classnr};
		
		% determine feature filename        add support for spotfindfeaturefile_priority
		filename = spot_findfeaturefile(Repository, Partindex, thisTargetClasses(classnr), fidx, Subject);


        % check whether it should be overwritten
		if exist(filename,'file') && (forcewrite==false)
            try partdata = load(filename, 'SaveTime', 'SF_searchwindow', 'FullFeatureString');
            catch
                % It may happen that load fails if the file is written in a concurrent process. Wait  and retry.
                pause(5); partdata = load(filename, 'SaveTime', 'SF_searchwindow', 'FullFeatureString');
            end;
			fprintf('\n%s: File %s exist and forcewrite not used, skipping.', mfilename, filename);
			fprintf('\n%s: Features:%u, SearchWin:%s, Date:%s', mfilename, length(partdata.FullFeatureString), mat2str(partdata.SF_searchwindow), datestr(partdata.SaveTime) );
			if isempty(segment_findincluded(partdata.SF_searchwindow, SF_searchwindow)) && (~isempty(partdata.SF_searchwindow))
				fprintf('\n%s: Search window is not covered by this part.', mfilename);
				fprintf('\n%s: SF_searchwindow=%s, this part=%s.', mfilename, mat2str(SF_searchwindow), mat2str(partdata.SF_searchwindow));
				fprintf('\n%s: This may be an error, depending on the configuration.', mfilename);
				error('here');
			end;
            fprintf('\n');	continue;
		end;

		% set semaphore
        if ~exist('allsim_batchmode', 'var') || (allsim_batchmode==false)
            jobdesc = strrep(tasktitle,' ','_');
            semafilename = [filename '.processing.mat'];
            [success jobdesc_read] = semaphorefile(semafilename, jobdesc, 'operation', 'set', 'verbose', 0);
            if ~success
                fprintf('\n%s: File %s is under process at %s, skipping.', mfilename, filename, jobdesc_read);
                %fprintf('\n%s: Interference detected with job %s, skipping part', mfilename, jobdesc_read);
                fprintf('\n');	continue;
            end;
        end;
		% now it should be save to proceed

        
        fprintf('\n%s:   Processing file: %s.', mfilename, filename);

        % create data struct (load data), once for Partindex only
		if doload
			DataStruct = makedatastruct(Repository, Partindex, FeatureString, DSSet);
			actualpartsize = fb_getdatasize(DataStruct, 'SampleRate', SampleRate);
			doload = false;  % not need to load anymore for other classes (this PI)
		end;
		
		thisSegmentationMode = SegmentationMode{classnr};
        
        % search segmentation list for current PI
        aseglist = repos_getsegmentation(Repository, Partindex, 'SampleRate', SampleRate, 'SegmentationMode', thisSegmentationMode);
        
        % determine smallest DataStruct
        aseglist(aseglist(:,2)>min(actualpartsize),:) = []; % omit last (may exceed data size)
        aseglist(end,:) = [aseglist(end,1) min(actualpartsize)];

		
		% verify search depth, e.g. when labeling had been modified during feature processing
		if ~isempty(partseglist) && isempty(strmatch('specified', lower(SpottingMode)))
			fprintf('\n%s:   Check part search depth...', mfilename);
			tmp = segment_countoverlap( ...
				segment_findlabelsforclass(partseglist(partseglist(:,6)>=LabelConfThres,:), thisTargetClasses(classnr)), ...
				aseglist, -inf);
			% OAM REVISIT: This is a hack for fixed and adaptive mode!
			obswindow = [ (min(tmp)+(min(tmp)==0))  (max(tmp)+(max(tmp)==0)) ];
            if isempty(segment_findincluded(SF_searchwindow, obswindow)) && (~isempty(obswindow))
                fprintf('\n%s: Search window is too small.', mfilename);
                fprintf('\n%s: SF_searchwindow=%s, obswindow=%s.', mfilename, mat2str(SF_searchwindow), mat2str(obswindow));
                fprintf('\n%s: Cases smaller: %u, cases larger: %u', mfilename, sum(tmp<SF_searchwindow(1)), sum(tmp>SF_searchwindow(2)));
                fprintf('\n');
                %error('here');
                warning('MATLAB:main_spotfeatures', 'This may happen due to rounding errors - verify that cases are low!.');
            end;
            fprintf(' %s, OK.', mat2str(obswindow));
        end; % if ~isempty(partseglist)

		
        % adapt segmentation list to sampling rate of the data when potentially
        % used as a feature by makefeatures.
        %     [aseglist2 aseglistidx] = segment_sizeprune(aseglist2,4);
        %     aseglist = aseglist(aseglistidx,:);
        DataStruct = fb_modifydatastruct(DataStruct, 'seglist', ...
			segment_resample(aseglist, SampleRate, DataStruct(1).SampleRate));



        %         partseglist = repos_findlabelsforpart(segment_findlabelsforclass(seglist, classnr), partnr, partoffsets, 'remove');
        %         if isempty(partseglist) continue; end;
        fprintf('\n%s:   Process features: class %u...', mfilename, thisTargetClasses(classnr));

		
		% probe feature names, determine FullFeatureString
		fprintf('\n%s:   Probe features names...', mfilename);
		FullFeatureString = {};
		for i = 1:length(DataStruct)
			if ~isempty(partseglist)
				testseg = segment_resample(partseglist(1,:), DataStruct(i).BaseRate, DataStruct(i).SampleRate);
			else
				testseg = segment_resample([1 1+DataStruct(i).BaseRate], DataStruct(i).BaseRate, DataStruct(i).SampleRate);
			end;
			[dummy flist] = makefeatures(testseg, DataStruct(i));
			FullFeatureString = {FullFeatureString{:} flist{:}};
		end;
		fprintf(' %u features.', length(FullFeatureString));

		
		% For conceptual reasons feature files cannot be shared btw
		% spotters. However spotting features can, given that parameters coincide. 
		% Look for 'similar' feature files and check whether they could be reused. 
		fprintf('\n%s:   Find peer feature file that could be reused...', mfilename);
		for testclass = Repository.TargetClasses   % thisTargetClasses %1:20
			[relfilename relfilexists] = spot_findfeaturefile(Repository, Partindex, testclass, fidx, Subject);   % 'priority', 1
			if ~relfilexists, continue; end;

			% search window
			test_searchwindow = loadin(relfilename, 'SF_searchwindow');
			if isempty(test_searchwindow) || isempty(segment_findincluded(SF_searchwindow, test_searchwindow))
				continue;
			end;
			[varnames infostruct] = lsmatfile(relfilename, 'SF_fmatrixsearch', 'SF_fmsectionlist');
			% search obs size
            test_ssize = diff(SF_searchwindow)+1;
			if infostruct(strmatch('SF_fmatrixsearch', varnames, 'exact')).size(1) > size(aseglist,1)*test_ssize, continue; end;
            if infostruct(strmatch('SF_fmatrixsearch', varnames, 'exact')).size(1) < size(aseglist,1)*test_ssize-((test_ssize-1)*test_ssize)-(min(SF_searchwindow)-1), continue; end;
			% feature count
			if infostruct(strmatch('SF_fmatrixsearch', varnames, 'exact')).size(2) ~= length(FullFeatureString), continue; end;
			% feature names
			test_FullFeatureString = loadin(relfilename, 'FullFeatureString');
			if ~all(cellstrmatch(FullFeatureString, test_FullFeatureString, 'exact')), continue; end;
			
			% hit!
			fprintf('\n%s:   Found a match: %s.', mfilename, relfilename);
			break;
		end;
		if ~(relfilexists), fprintf(' nothing found'); end;
		
		
        % training features (isolated)
		% OAM REVISIT: could adapt train labels to closest segmentation points
        classseglist = segment_findlabelsforclass(partseglist, thisTargetClasses(classnr));
		SF_trainlabellist = classseglist;
        fprintf('\n%s:   Process train features on %u labels...', mfilename, size(SF_trainlabellist,1));

        % following line works for empty classseglist too, since Empty matrix: 0-by-6
        %SF_fmatrixtrain = makefeatures_fusion(classseglist(classseglist(:,6)==1,:), DataStruct);
		% do not use here: identify requires full classseglist and selects tentative itself
		SF_fmatrixtrain = makefeatures_fusion(SF_trainlabellist, DataStruct);


		% spotting features
		if (relfilexists)
			% copy search features from peer
            fprintf('\n%s:   Loading search from %s...', mfilename, relfilename);
			%fprintf(' features (%u), featurewin %s', length(FullFeatureString), mat2str(SF_searchwindow));
			[SF_fmatrixsearch SF_fmsectionlist] = loadin(relfilename, 'SF_fmatrixsearch', 'SF_fmsectionlist');
		else
			% compute search features anew
			fprintf('\n%s:   Process search features (%u), featurewin %s...', ...
				mfilename, length(FullFeatureString), mat2str(SF_searchwindow));
			[SF_fmatrixsearch SF_fmsectionlist] = makefeatures_segment(aseglist, SF_searchwindow, @makefeatures_fusion, DataStruct, 1);
		end;
        fprintf('\n%s:   Observations: %u, sections: %u', mfilename, size(SF_fmatrixsearch,1), size(SF_fmsectionlist,1));
        tmp = segment_countoverlap(classseglist, SF_fmsectionlist, section_jitter);
        fprintf('\n%s:   Sections in relevants (%u): %s', mfilename, ...
            size(classseglist,1), strcut(mat2str(tmp)));


        % save
		if exist(filename,'file') && (forcewrite==false)
			fprintf('\n%s: File %s exist and forcewrite not used.', mfilename, filename);
			fprintf('\n%s: Waiting for 60 seconds before continuing.', mfilename);
			countdown(60, 'verbose', 0);
		end;
		if exist(filename,'file') && (forcewrite==false)
			fprintf('\n%s: File %s persists and forcewrite not used, skipping.', mfilename, filename);
			fprintf('\n%s: This is an error - check who has created the file during processing.', mfilename);
            
            if ~exist('allsim_batchmode', 'var') || (allsim_batchmode==false)
                semaphorefile(semafilename, jobdesc, 'operation', 'rm');
            end;
            continue;
		end;

        fprintf('\n%s:   Saving %s...', mfilename, filename);
        SaveTime = clock;
        save(filename, '-v7.3', ...
			'SF_fmatrixsearch', 'SF_fmsectionlist', 'SF_fmatrixtrain', 'SF_searchwindow', 'SF_trainlabellist', ...
            'Partindex', 'FullFeatureString', 'FeatureString', 'DSSet', 'thisSegmentationMode', 'SpottingMode', ...
            'classnr', 'aseglist', 'classseglist', 'partsize', 'actualpartsize', ...
            'TargetClasses', 'thisTargetClasses', 'MergeClassSpec', 'FeatureString', ...
            'usesources', 'usesystems', 'relfilename', 'relfilexists', ...
            'StartTime', 'SaveTime', 'VERSION');
		
        if ~exist('allsim_batchmode', 'var') || (allsim_batchmode==false)
            inprocess = semaphorefile(semafilename, jobdesc, 'operation', 'rm', 'verbose', 0);
            if ~inprocess, error('Something has interfered with the semaphore.'); end;
        end;
    end; % for classnr
end; % for Partindex

fprintf('\n%s: Done.', mfilename);
