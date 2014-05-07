% main_spotfindfeaturefile
%
% Find best place to store/load feature file using priorities
%
% returns: filename
%
% requires:
fidx;
Repository;
thisTargetClasses;
classnr;
Partindex;
Subject;

if ~exist('spotfindfeaturefile_priority','var') || isempty(spotfindfeaturefile_priority), 
	spotfindfeaturefile_priority = 1; 
end;


filename = '';

% Priority 1: global repos path with subject name subdir
filename = dbfilename(Repository, 'prefix', 'SFeatures' , 'indices', [Partindex thisTargetClasses(classnr)], ...
	'suffix', fb_getelements(fidx,2), 'subdir', Subject, 'globalpath', fullfile(Repository.Path, 'FEATURES'));
if (exist(fileparts(filename),'dir')) && (spotfindfeaturefile_priority<=1), return; end;

% Priority 2: global repos
filename = dbfilename(Repository, 'prefix', 'SFeatures' , 'indices', [Partindex thisTargetClasses(classnr)], ...
	'suffix', fb_getelements(fidx,2), 'subdir', 'FEATURES', 'globalpath', Repository.Path);
if (exist(fileparts(filename),'dir')) && (spotfindfeaturefile_priority<=2), return; end;

% Priority 3: local path (fallback)
filename = dbfilename(Repository, 'prefix', 'SFeatures' , 'indices', [Partindex thisTargetClasses(classnr)], ...
	'suffix', fb_getelements(fidx,2), 'subdir', 'FEATURES');

fprintf('\n'); 
warning('main_spotfeatures:featurefile', 'Using local directory instead of Repository for feature files (if applicable).');