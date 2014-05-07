% main_spotstats
%
% Load and print spotting results
% disp('main_spotstats');

% requires
% SimSetID;
% SimSetID_List;
% thisTargetClasses;
% SpotType

initdata;

if (~exist('SpotType','var')),  SpotType = 'SIMS'; end;
if (~exist('UseAbsoluteClasses','var')),  UseAbsoluteClasses = true; end;
if (~exist('SimSetID_List','var')),  SimSetID_List = {SimSetID}; end;
if (~exist('DoAnalyseFeatures','var')),  DoAnalyseFeatures = true; end;
if (~exist('DoPrintFeatures','var')),  DoPrintFeatures = false; end;

if ~exist('thisTargetClasses','var'),
	% probing class numbers
	%filename = dbfilename(Repository, 'prefix', SpotType, 'indices', 1, 'suffix', SimSetID_List{1}, 'subdir', 'SPOT');
	filename = spot_isfile(SpotType, SimSetID_List{1});
	load(filename, 'thisTargetClasses');
end;

% -------------------------------------------------------------------------
% (intra-user) results
% -------------------------------------------------------------------------
clear metrics;
allmetrics = []; classmetrics =  prmetrics_mkstruct(0,0,0); submetrics = [];
clear allfweights fselinfo;
for classnr = 1:length(thisTargetClasses)  % will exit when enough classes read (see below)
	classmetrics(classnr) = prmetrics_mkstruct(0,0,0);

	for subjnr = 1:length(SimSetID_List)
		if UseAbsoluteClasses
			filename = repos_makefilename(Repository, 'prefix', SpotType, 'indices', thisTargetClasses(classnr), 'suffix', SimSetID_List{subjnr}, 'subdir', 'SPOT');
		else
			filename = repos_makefilename(Repository, 'prefix', SpotType, 'indices', classnr, 'suffix', SimSetID_List{subjnr}, 'subdir', 'SPOT');
		end;
		if (exist(filename,'file')==0)
			fprintf('\n%s: *** File %s not found, skipping', mfilename, filename);
			continue;
		end;

		load(filename, 'metrics', 'SaveTime');
		try, SaveTime; catch SaveTime = 0; end;
		%org = load(filename, 'thisTargetClasses');

		fprintf('\n%s: File: %s, Date: %s',  mfilename, filename, datestr(SaveTime));
		allmetrics = prmetrics_add(allmetrics, metrics);
		submetrics = [submetrics metrics];
		classmetrics(classnr) = prmetrics_add(classmetrics(classnr), metrics);
		%prmetrics_printstruct(metrics);

		if (subjnr==1) && isempty(lsmatfile(filename, 'fselect'))
			DoAnalyseFeatures = false;
			fprintf('\n%s: No feature information available.', mfilename);
		end;
		if (DoAnalyseFeatures)
            thisfselinfo = load(filename, 'SF_FeatureString', 'FSelFeatureCount', 'FSelMethod', 'fweighting', 'fselect');            
			if (subjnr==1)
                tmp_allfselects = zeros(size(thisfselinfo.fselect{1}));
                tmp_allfweights = zeros(size(thisfselinfo.fweighting{1},1),1);
			else
                % 				thisfselinfo = load(filename, 'fweighting', 'fselect');
				%warning('MATLAB:main_spotstats', 'Multiple spotters/subjects where requested. Use fselinfo.* fields.');
				fprintf('\n%s: Multiple spotters/subjects where requested. Use fselinfo.* fields.', mfilename);                
			end;
            fselinfo(classnr,subjnr).FSelFeatureCount = thisfselinfo.FSelFeatureCount;
            fselinfo(classnr,subjnr).SF_FeatureString = thisfselinfo.SF_FeatureString;
            fselinfo(classnr,subjnr).fselect = zeros(size(thisfselinfo.fselect{1}));
            fselinfo(classnr,subjnr).fweighting = zeros(size(thisfselinfo.fweighting{1}));
            
			for cvi = 1:length(thisfselinfo.fselect)
				fselinfo(classnr,subjnr).fselect = fselinfo(classnr,subjnr).fselect + thisfselinfo.fselect{cvi};
				fselinfo(classnr,subjnr).fweighting = fselinfo(classnr,subjnr).fweighting + thisfselinfo.fweighting{cvi};
				tmp_allfselects = tmp_allfselects + thisfselinfo.fselect{cvi};
                tmp_allfweights = tmp_allfweights + col(sum(thisfselinfo.fweighting{cvi},2));
			end; % for cvi
            allfselects(classnr,:) = tmp_allfselects ./ length(thisfselinfo.fselect);
            allfweights(classnr,:) = tmp_allfweights ./ length(thisfselinfo.fselect);
            
		end; % if (DoAnalyseFeatures)
	end; % for subjnr
	
	if (DoAnalyseFeatures)
		if DoPrintFeatures
			%[dummy idx] = sort(fselinfo(classnr).allfweighting, 'descend'); % using feature weight
			[dummy idx] = sort(fselinfo(classnr,1).fselect, 'descend');  % using feature utilisation
			idx = idx(1:fselinfo(classnr,1).FSelFeatureCount);
			str = strvcat(fselinfo(classnr,1).SF_FeatureString(idx));
			%str = cell2str(fselinfo(classnr,1).SF_FeatureString(idx), ', ');
			fprintf('\n%s: Selected features: \n', mfilename);
			disp(str);
		end;
	end;
    
    
    %  strvcat(fselinfo(1,1).SF_FeatureString(allfselects>=3))
    
    
	% all classes included in one file already
	if (length(allmetrics) >= length(thisTargetClasses)), break; end;

end; % for classnr
classmetrics = prmetrics_mergeclass(classmetrics);

fprintf('\n%s: Total result:', mfilename);
prmetrics_printstruct(allmetrics);
% fprintf('\n%s: Sub result:', mfilename);
% prmetrics_printstruct(submetrics);
fprintf('\n');
fprintf('\n%s: Your optios are: allmetrics, classmetrics, submetrics, fselinfo, allfweights\n', mfilename);

return;



% -------------------------------------------------------------------------
% spotting result analysis tools
% -------------------------------------------------------------------------
CVFolds = 4;

class = 2;
for cvslice = 1:CVFolds
	[trainSL trainSC testSL testSC trainseglist testseglist prmetrics_train prmetrics_test bestthres] = ...
		prepspotresults(Repository, 'DavidT2', class, cvslice, 'BestThresOnly', true);


	if (0) % training
		figure; hold on;
		segment_plotmark(1:trainSL(end,end), trainSL, 'similarity', trainSC, 'width', 2, 'style', 'b-');
		segment_plotmark(1:trainSL(end,end), trainseglist, 'fill', 'style', 'k');
		%xlim([2000 6000]);
	end;
	if (1) && (~isempty(testSL)) % testing
		figure; hold on;
		segment_plotmark(1:testSL(end,end), testSL, 'similarity', testSC, 'width', 2, 'style', 'r-');
		segment_plotmark(1:testSL(end,end), testseglist, 'fill', 'style', 'k');
		title(['Testing: Class: ' num2str(class) ' cvslice: ' num2str(cvslice)]);
		%xlim([2000 6000]);
	end;
end;

