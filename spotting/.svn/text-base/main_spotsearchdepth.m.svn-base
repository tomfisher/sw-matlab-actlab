% main_spotsearchdepth
%

% SegConfig.Name = 'FIX2'; SpottingMode = 'adaptive'; 
% Partlist =  repos_getpartsforsubject(Repository, Repository.UseParts, 'Clemens');
% TargetClasses =  associations.wrist.pickup;
MergeClassSpec = [];
initmain;

% requires
fidx = 'dummy';


VERSION = 'V001';
fprintf('\n%s: %s', mfilename, VERSION);
StartTime = clock;

if ~exist('LabelConfThres','var'), LabelConfThres = 1; end;   % omit below confidence thres during training


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



%% estimate search depth
% WARNING: To estimate the global search depth all parts are used.
% For this reason ALL parts must be computed anew when Partlist or seglist was
% changed. Training, testing will later select from the global list.
%
% SF_searchwindow = [lowerbound upperbound]
% provides: Global_SF_searchwindow

All_SF_searchwindow = cell(length(thisTargetClasses),1);
for classnr = 1:length(thisTargetClasses)
		thisSegConfig = SegConfig(classnr);
		
        fprintf('\n%s: Class %u: Spotting mode: %s, search depth:', mfilename, thisTargetClasses(classnr), lower(SpottingMode));
        aseglist = cla_getsegmentation(Repository, Partlist, 'SampleRate', SampleRate, ...
            'SegType', thisSegConfig.Name, 'SegMode', thisSegConfig.Mode);
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


fprintf('\n%s: Done.', mfilename);
