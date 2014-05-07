% main_spotloadfeatures.m
%
% Load search features (precomputed) and index list (main_spotfeatures.m)
%
% requires:
Partlist;
Repository;
thisTargetClasses;
classnr;
% provides:
providevar = { 'SF_fmatrixsearch', 'SF_fmsectionlist', 'SF_fmatrixtrain', 'SF_searchwindow', 'SF_trainlabellist' };

% scan through feature files to determine required memory sizes
fprintf('\n%s: Scan feature files...', mfilename);
SF_size = zeros(length(Partlist), 3);  memreq = 0;
for partnr = 1:length(Partlist)
	Partindex = Partlist(partnr);  
	
	% determine feature filename
	filename = spot_findfeaturefile(Repository, Partindex, thisTargetClasses(classnr), fidx, Subject);
	
	[varnames infostruct] = lsmatfile(filename, providevar{:});
	SF_size(partnr, 1) = infostruct(strmatch('SF_fmatrixsearch', varnames, 'exact')).size(1);  % search obs size
	SF_size(partnr, 2) = infostruct(strmatch('SF_fmatrixsearch', varnames, 'exact')).size(2);  % feature count
	SF_size(partnr, 3) = infostruct(strmatch('SF_fmatrixtrain', varnames, 'exact')).size(1);  % nr of train obs 

	for i = 1:length(infostruct), memreq = memreq + infostruct(i).bytes; end;
	fprintf(' %u', Partindex);
end;  % for partnr
fprintf('\n%s: Total memory required: %uMB.', mfilename, round(memreq/(1024^2)));
clear(providevar{:});

% load the feature files
SF_fmatrixsearch = zeros(sum(SF_size(:,1)), SF_size(1,2));
SF_fmsectionlist = zeros(sum(SF_size(:,1)), 2);
SF_fmatrixtrain = zeros(sum(SF_size(:,3)), SF_size(1,2));
SF_trainlabellist = zeros(sum(SF_size(:,3)), 6);

tmp_partsize = 0; partdata = [];
for partnr = 1:length(Partlist)
	Partindex = Partlist(partnr);
	
	% determine feature filename
	filename = spot_findfeaturefile(Repository, Partindex, thisTargetClasses(classnr), fidx, Subject);
	
	
	partdata = load(filename, providevar{:}, 'partsize', 'SaveTime', 'thisSegConfig');
	fprintf('\n%s: Loaded: %s', mfilename, filename);
	fprintf('\n%s: Features:%s, SearchWin:%s, Date: %s', mfilename, mat2str(size(partdata.SF_fmatrixsearch)), mat2str(partdata.SF_searchwindow), datestr(partdata.SaveTime) );

	% check segmentation config
	if exist('SegConfig','var')
		if (~strcmpi(SegConfig(classnr).Name, partdata.thisSegConfig.Name)) || (~strcmpi(SegConfig(classnr).Mode, partdata.thisSegConfig.Mode))
			error('Segmentation schemes do not match.');
		end;
	end;

	% append
	if (partnr==1), 
		SF_searchwindow = loadin(filename, 'SF_searchwindow');
		SF_FeatureString_load = loadin(filename, 'FullFeatureString');
		
		SF_fmatrixsearch(1:SF_size(partnr,1),:) = partdata.SF_fmatrixsearch;
		SF_fmsectionlist(1:SF_size(partnr,1),:) = partdata.SF_fmsectionlist;

		if (size(partdata.SF_trainlabellist,1)>0)
			SF_fmatrixtrain(1:SF_size(partnr,3),:) = partdata.SF_fmatrixtrain;
			SF_trainlabellist(1:SF_size(partnr,3),:) = ...
				[ partdata.SF_trainlabellist(:,1:2)+tmp_partsize  partdata.SF_trainlabellist(:,3:end) ];
		end;
	else
		SF_fmatrixsearch(sum(SF_size(1:partnr-1,1))+1:sum(SF_size(1:partnr,1)),:) = partdata.SF_fmatrixsearch;
		SF_fmsectionlist(sum(SF_size(1:partnr-1,1))+1:sum(SF_size(1:partnr,1)),:) = partdata.SF_fmsectionlist+tmp_partsize;

		if (size(partdata.SF_trainlabellist,1)>0)
			SF_fmatrixtrain(sum(SF_size(1:partnr-1,3))+1:sum(SF_size(1:partnr,3)),:) = partdata.SF_fmatrixtrain;
			SF_trainlabellist(sum(SF_size(1:partnr-1,3))+1:sum(SF_size(1:partnr,3)),:) = ...
				[ partdata.SF_trainlabellist(:,1:2)+tmp_partsize  partdata.SF_trainlabellist(:,3:end) ];
		end;
	end; % if (partnr==1)
	
	%tmp_partsize = SF_fmsectionlist(end,2);
	tmp_partsize = tmp_partsize + partdata.partsize;
	clear partdata;
end; % for Partindex

clear tmp_partsize SF_size varnames infostruct filename;
