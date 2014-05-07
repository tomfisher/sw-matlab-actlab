% main_isoclassstats
%
% Load and print classification results

% requires
SimSetID_List;
% SubjectList;  % or Partlist;
% UserMode;

%initdata;

if (~exist('ClassType','var')),  ClassType = 'CLASS'; end;
% if (~exist('UserMode','var')),  UserMode = 'intrasubject'; end;


% if (~exist('SubjectList','var'))
% 	switch lower(UserMode)
% 		case 'intrasubject', SubjectList = repos_getsubjects(Repository, Repository.UseParts);
% 		case {'intersubject', 'newsubject'}, SubjectList = { 'ALLUSERS' };
% 	end;
% 	fprintf('\n%s: Set SubjectList to: %s', mfilename, cell2str(SubjectList));
% end;
% if ~iscell(SubjectList), SubjectList = {SubjectList}; end;

loadvars = {'cmetrics', 'cmetricslist', 'allfweighting', 'allvariance', 'fm_FeatureString', ...
	'emetrics', 'SaveTime', 'Classlist', 'thisTargetClasses', 'CVFolds'};

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% fidxel = fb_getelements(fidx);
allcmetrics = []; clear subcmetrics subfeatureweights;
% switch lower(UserMode)
% 	case 'intrasubject'
% 		% intrasubject results
		subcmetrics = cell(length(SimSetID_List),1);
		subfeatureweights = []; subvariance = [];  subematrix = cell(length(SimSetID_List),1);

		for snr = 1:length(SimSetID_List)
			
% 			SimSetID = [SubjectList{snr} fidxel{2:end}];


			% load results
			filename = repos_makefilename(Repository, 'prefix', ClassType, 'suffix', SimSetID_List{snr}, 'subdir', 'ISO');
			if (exist(filename, 'file')==0)
				fprintf('\n%s: *** File %s not found, skipping', mfilename, filename);
				continue;
			end;
			clear(loadvars{:}); 	load(filename, loadvars{:});

			fprintf('\n%s: SimSetID: %s', mfilename, SimSetID_List{snr});
			fprintf('\n%s:   File: %s', mfilename, filename);
			fprintf('\n%s:   SaveTime: %s', mfilename, datestr(SaveTime));
			if (length(SimSetID_List)>1), fprintf('\n'); disp(cmetrics_mkstats(cmetrics)); end;

			if isempty(allcmetrics)
				allcmetrics = cmetrics; 
			else
				allcmetrics = allcmetrics + cmetrics;
			end;
			
			subcmetrics{snr} = cmetrics;
            
			subfeatureweights(:,snr) = allfweighting/CVFolds;
% 			subvariance(:,snr) = allvariance;
			if isfield(emetrics, 'ematrix'), subematrix{snr} = emetrics.ematrix; end;
		end;

% 	case {'intersubject', 'newsubject'}
% % 		SimSetID = ['ALLUSERS' fidxel{2:end}];
% 
% 		filename = dbfilename(Repository, 'prefix', ClassType, 'suffix', SimSetID_List, 'subdir', 'ISO');
% 		if (exist(filename, 'file')==0)
% 			fprintf('\n%s: *** File %s not found, skipping', mfilename, filename);
% 			return;
% 		end;
% 		clear(loadvars{:}); 	load(filename, loadvars{:});
% 
% 		fprintf('\n%s: Subject: %s, SimSetID: %s', mfilename, 'ALLUSERS', SimSetID);
% 		fprintf('\n%s:   File: %s', mfilename, filename);
% 		fprintf('\n%s:   SaveTime: %s', mfilename, datestr(SaveTime));
% 		%disp(cmetrics_mkstats(cmetrics));
% 
% 		allcmetrics = cmetrics;
% 		subfeatureweights = allfweighting/CVFolds;
% 		subvariance = allvariance;
% 		
% 	otherwise
% 		error('CVMethod %s not understood.', CVMethod);
% end;  % switch lower(UserMode)



fprintf('\n%s: Total result (allcmetrics) of %s:', mfilename, cell2str(SimSetID_List, ', '));
fprintf('\n\n');
disp(cmetrics_mkstats(allcmetrics));
fprintf('\n%s: Classes: %s => %s', mfilename, mat2str(thisTargetClasses), cell2str(Repository.Classlist(thisTargetClasses),', ') );

% quick accuracy summary
if exist('subcmetrics','var') && (~any(isemptycell(subcmetrics)))
	thisaccn = zeros(length(subcmetrics),1); % accn(:,end+1)
	for s = 1:length(subcmetrics)
		h = cmetrics_mkstats(subcmetrics{s});
		thisaccn(s) = h.normacc; %accn(s,end) 
	end;
else
	% only allcmetrics 
	h = cmetrics_mkstats(allcmetrics);
	try	thisaccn = h.normacc; catch fprintf('\n%s: Incompatible accn list, could not add.', mfilename); end;
end;

if (exist('accn','var')~=1), accn = []; end;
accn(:,end+1) = col(thisaccn);


accncv = zeros(length(cmetricslist),1);
for s = 1:length(cmetricslist)
	h = cmetrics_mkstats(cmetricslist{s});
	accncv(s) = h.normacc;
end;

if (exist('accnmean','var')~=1), accnmean = []; end;
if (exist('accnsd','var')~=1), accnsd = []; end;
if (exist('accnmin','var')~=1), accnmin = []; end;
if (exist('accnmax','var')~=1), accnmax = []; end;
if exist('subcmetrics','var') && (~any(isemptycell(subcmetrics))) && (length(subcmetrics)>1)
	accnmean(end+1) = mean(thisaccn,1);
	accnsd(end+1) = std(thisaccn,0,1);
	accnmin(end+1) = min(thisaccn); 
	accnmax(end+1) = max(thisaccn);
	fprintf('\n%s: Used accn (user-spec. mode) for accnmean, accnsd, accnmin, accnmax.', mfilename);
else
	accnmean(end+1) = mean(accncv,1);
	accnsd(end+1) = std(accncv,0,1);
	accnmin(end+1) = min(accncv); 
	accnmax(end+1) = max(accncv);
	fprintf('\n%s: Used accncv ({all,new}-user mode) for accnmean, accnsd, accnmin, accnmax.', mfilename);
end;

fprintf('\n\n');
fprintf('\n%s: Your options are: allcmetrics, subcmetrics', mfilename);
fprintf('\n%s: Your options are: thisaccn, accncv, accn, accnmean, accnsd, accnmin, accnmax', mfilename);
fprintf('\n%s: fh = cmetrics_plotmap(cmetrics_hist2ratio(allcmetrics));', mfilename);
fprintf('\n');


% 	% confusion heat map
% 	fh = cmetrics_plotmap(cmetrics_hist2ratio(allcmetrics)); %, 'title', fidxel{2:end}); 
% 	plotfmt(fh, 'prjpg', 'OliverF1F1SS_cmetrics.jpg');
% 	plotfmt(fh, 'prpdf', 'OliverF1F1SS_cmetrics.pdf');
